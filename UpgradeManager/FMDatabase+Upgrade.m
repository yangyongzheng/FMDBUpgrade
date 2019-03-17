
#import "FMDatabase+Upgrade.h"

@implementation FMDatabase (Upgrade)

static BOOL FMDBUpgradeAssertStringNotEmpty(id string) {
    return string && [string isKindOfClass:[NSString class]] && ((NSString *)string).length > 0;
}

static BOOL FMDBUpgradeAssertArrayNotEmpty(id array) {
    return array && [array isKindOfClass:[NSArray class]] && ((NSArray *)array).count > 0;
}

static BOOL FMDBUpgradeAssertDictionaryNotEmpty(id dictionary) {
    return dictionary && [dictionary isKindOfClass:[NSDictionary class]] && ((NSDictionary *)dictionary).count > 0;
}

#pragma mark Init
+ (instancetype)yyz_databaseWithPath:(NSString *)dbPath {
    if (FMDBUpgradeAssertStringNotEmpty(dbPath)) {
        if (dbPath.pathExtension.length == 0) {// 无扩展时添加扩展
            dbPath = [dbPath stringByAppendingPathExtension:@"db"];
        }
        NSString *directoryPath = [dbPath stringByDeletingLastPathComponent];
        if (directoryPath.length > 0) {
            if (![NSFileManager.defaultManager fileExistsAtPath:directoryPath isDirectory:NULL]) {// 不存在就创建目录
                [NSFileManager.defaultManager createDirectoryAtPath:directoryPath
                                        withIntermediateDirectories:YES
                                                         attributes:nil
                                                              error:nil];
            }
        }
    }
    return [FMDatabase databaseWithPath:dbPath];
}

#pragma mark 升级数据库表
- (void)yyz_upgradeTableWithConfig:(FMDBUpgradeTableConfigArray)tableConfig {
    if (FMDBUpgradeAssertArrayNotEmpty(tableConfig)) {
        FMDBUpgradeTableConfigArray newTableConfig = [tableConfig copy];
        
        for (FMDBUpgradeTableDictionary tableDictionary in newTableConfig) {
            if (FMDBUpgradeAssertDictionaryNotEmpty(tableDictionary)) {
                __weak typeof(self) weakSelf = self;
                [tableDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull tableName, NSDictionary<NSString *,NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
                    if (FMDBUpgradeAssertStringNotEmpty(tableName) && FMDBUpgradeAssertDictionaryNotEmpty(obj)) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        if ([strongSelf tableExists:tableName]) {
                            NSArray *upgradeStatements = [strongSelf yyz_upgradeStatementsWithTableName:tableName tableAttributes:obj];
                            if (upgradeStatements.count > 0) {
                                NSString *sql = [upgradeStatements componentsJoinedByString:@" "];
                                [strongSelf executeStatements:sql];
                            }
                        } else {
                            [strongSelf yyz_createTableWithConfig:@[@{tableName : obj}]];
                        }
                    } else {
                        NSAssert(NO, @"入参`tableConfig`数组中元素(`FMDBUpgradeTableDictionary`类型实例)，其`key`必须为`NSString`类型且非空，其`value`必须为`NSDictionary`类型且非空。");
                    }
                }];
            } else {
                NSAssert(NO, @"入参`tableConfig`数组中元素必须为`FMDBUpgradeTableDictionary`类型且非空。");
            }
        }
    }
}

#pragma mark 创建数据库表
- (void)yyz_createTableWithConfig:(FMDBUpgradeTableConfigArray)tableConfig {
    if (FMDBUpgradeAssertArrayNotEmpty(tableConfig)) {
        FMDBUpgradeTableConfigArray newArray = [tableConfig copy];
        
        __block NSMutableArray *sqlStatements = [NSMutableArray array];
        for (FMDBUpgradeTableDictionary tableDictionary in newArray) {
            if (FMDBUpgradeAssertDictionaryNotEmpty(tableDictionary)) {
                __weak typeof(self) weakSelf = self;
                [tableDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull tableName, NSDictionary<NSString *,NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
                    if (FMDBUpgradeAssertStringNotEmpty(tableName) && FMDBUpgradeAssertDictionaryNotEmpty(obj)) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        if (![strongSelf tableExists:tableName]) {
                            NSString *sql = [strongSelf yyz_createTableStatementWithName:tableName tableAttributes:obj];
                            if (sql) {
                                [sqlStatements addObject:sql];
                                NSLog(@"创建表 <%@>", tableName);
                            }
                        }
                    } else {
                        NSAssert(NO, @"入参`tableConfig`数组中元素(`FMDBUpgradeTableDictionary`类型实例)，其`key`必须为`NSString`类型且非空，其`value`必须为`NSDictionary`类型且非空。");
                    }
                }];
            } else {
                NSAssert(NO, @"入参`tableConfig`数组中元素必须为`FMDBUpgradeTableDictionary`类型且非空。");
            }
        }
        if (sqlStatements.count > 0) {
            NSString *sql = [sqlStatements componentsJoinedByString:@" "];
            [self executeStatements:sql];
        }
    }
}

#pragma mark 删除数据库表
- (void)yyz_deleteTables:(NSArray<NSString *> *)tableNames {
    if (FMDBUpgradeAssertArrayNotEmpty(tableNames)) {
        NSArray *newTableNames = [tableNames copy];
        
        [self yyz_inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            for (NSString *table in newTableNames) {
                if (FMDBUpgradeAssertStringNotEmpty(table)) {
                    NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@;", table];
                    [db executeUpdate:sql];
                } else {
                    NSAssert(NO, @"入参`tableNames`数组中元素必须为`NSString`类型。");
                }
            }
        }];
    }
}

#pragma mark 事物更新
- (void)yyz_transactionExecuteStatements:(NSArray<NSString *> *)sqlStatements{
    if (FMDBUpgradeAssertArrayNotEmpty(sqlStatements)) {
        NSArray *sqls = [sqlStatements copy];
        [self beginTransaction];
        
        BOOL isRollBack = NO;
        for (NSString *sql in sqls) {
            if ([sql isKindOfClass:[NSString class]] && sql.length > 0) {
                if (![self executeUpdate:sql]) {
                    isRollBack = YES;
                    break;
                }
            }
        }
        
        if (isRollBack) {
            [self rollback];
        } else {
            [self commit];
        }
    }
}

- (void)yyz_inTransaction:(void (^)(FMDatabase * _Nonnull, BOOL * _Nonnull))block {
    if (block) {
        [self beginTransaction];
        
        BOOL isRollBack = NO;
        block(self, &isRollBack);
        
        if (isRollBack) {
            [self rollback];
        } else {
            [self commit];
        }
    }
}

#pragma mark - Misc
#pragma mark 获取创建表sql语句
/**
 获取创建表sql语句

 @param tableName 表名
 @param attributes 需创建表的所有属性
 @return 创建表sql语句 或 nil
 */
- (NSString *)yyz_createTableStatementWithName:(NSString *)tableName tableAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    if (FMDBUpgradeAssertStringNotEmpty(tableName) && FMDBUpgradeAssertDictionaryNotEmpty(attributes)) {
        __block NSMutableString *components = [NSMutableString string];
        [attributes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            if (FMDBUpgradeAssertStringNotEmpty(key) && FMDBUpgradeAssertStringNotEmpty(obj)) {
                NSString *element = [NSString stringWithFormat:@"%@ %@, ", key, obj];   // 拼接字段和字段类型
                [components appendString:element];
            }
        }];
        if (components.length > 2) {
            [components deleteCharactersInRange:NSMakeRange(components.length-2, 2)];
        }
        if (components.length > 0) {
            return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@);", tableName, components];
        }
    }
    
    return nil;
}

#pragma mark 获取本地数据库表的所有列
- (NSArray *)yyz_columnsInTable:(NSString *)tableName {
    NSMutableArray *tempArray = [NSMutableArray array];
    FMResultSet *resultSet = [self getTableSchema:tableName];
    while ([resultSet next]) {
        NSString *columnName = [resultSet stringForColumn:@"name"];
        if (FMDBUpgradeAssertStringNotEmpty(columnName)) {
            [tempArray addObject:columnName];
        }
    }
    return FMDBUpgradeAssertArrayNotEmpty(tempArray) ? [tempArray copy] : nil;
}

#pragma mark 获取表升级sql语句
/**
 获取表升级sql语句

 @param tableName 表名
 @param attributes 新表所有列属性
 @return 表升级sql语句 或 nil
 */
- (NSArray *)yyz_upgradeStatementsWithTableName:(NSString *)tableName tableAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    if (FMDBUpgradeAssertStringNotEmpty(tableName) && FMDBUpgradeAssertDictionaryNotEmpty(attributes)) {
        NSArray *filterColumns = [self yyz_columnsInTable:tableName];
        NSArray *columns = attributes.allKeys;
        
        NSPredicate *addPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", filterColumns];
        NSPredicate *deletePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", columns];
        NSPredicate *commonPredicate = [NSPredicate predicateWithFormat:@"SELF in %@", filterColumns];
        NSArray *columnsToAdd = [columns filteredArrayUsingPredicate:addPredicate];             // 需添加的列
        NSArray *columnsToDelete = [filterColumns filteredArrayUsingPredicate:deletePredicate]; // 需删除的列
        NSArray *commonColumns = [columns filteredArrayUsingPredicate:commonPredicate];         // 相同列
        NSLog(@"升级表 <%@>：\nadd->%@\ndelete->%@", tableName, columnsToAdd, columnsToDelete);
        
        if (commonColumns.count > 0 && columnsToAdd.count >= 0 && columnsToDelete.count > 0) {
            // 新表和旧表有相同列，并且存在需要删除的列
            return [self yyz_deleteColumnsStatementsWithTableName:tableName
                                               newTableAttributes:attributes
                                                    commonColumns:commonColumns];
        } else if (commonColumns.count == 0 && columnsToAdd.count > 0 && columnsToDelete.count > 0) {
            // 新表和旧表无相同列，直接删除旧表，创建新表
            NSString *dropSql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@;", tableName];
            NSString *createSql = [self yyz_createTableStatementWithName:tableName tableAttributes:attributes];
            return createSql ? @[dropSql, createSql] : nil;
        } else if (commonColumns.count > 0 && columnsToAdd.count > 0 && columnsToDelete.count == 0) {
            // 新表和旧表有相同列，并且只存在需要添加的列
            return [self yyz_addColumnsStatementsWithTableName:tableName
                                                    attributes:[attributes dictionaryWithValuesForKeys:columnsToAdd]];
        }
    }
    
    return nil;
}

#pragma mark 获取添加列sql语句
/**
 获取添加列sql语句

 @param tableName 表名
 @param attributes 需添加的列属性
 @return 添加列sql语句 或 nil
 */
- (NSArray *)yyz_addColumnsStatementsWithTableName:(NSString *)tableName attributes:(NSDictionary<NSString *, NSString *> *)attributes {
    if (FMDBUpgradeAssertStringNotEmpty(tableName) && FMDBUpgradeAssertDictionaryNotEmpty(attributes)) {
        __block NSMutableArray *statements = [NSMutableArray arrayWithCapacity:attributes.count];
        [attributes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            if (FMDBUpgradeAssertStringNotEmpty(key) && FMDBUpgradeAssertStringNotEmpty(obj)) {
                NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@;", tableName, key, obj];
                [statements addObject:sql];
            }
        }];
        
        return FMDBUpgradeAssertArrayNotEmpty(statements) ? [statements copy] : nil;
    }
    
    return nil;
}

#pragma mark 获取删除列sql语句
/**
 获取删除列sql语句

 @param tableName 表名
 @param attributes 新表所有列属性
 @param commonColumns 新表和旧表的相同列
 @return 删除列sql语句 或 nil
 */
- (NSArray *)yyz_deleteColumnsStatementsWithTableName:(NSString *)tableName
                                   newTableAttributes:(NSDictionary<NSString *, NSString *> *)attributes
                                        commonColumns:(NSArray<NSString *> *)commonColumns {
    if (FMDBUpgradeAssertStringNotEmpty(tableName) &&
        FMDBUpgradeAssertDictionaryNotEmpty(attributes) &&
        FMDBUpgradeAssertArrayNotEmpty(commonColumns)) {
        NSString *tempTableName = [NSString stringWithFormat:@"UPGRADE_TEMP_%@", tableName]; // 临时表名称
        NSString *columnsString = [commonColumns componentsJoinedByString:@", "];
        // 1.重命名旧表
        NSString *renameSql = [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@;", tableName, tempTableName];
        // 2.创建新表
        NSString *createSql = [self yyz_createTableStatementWithName:tableName tableAttributes:attributes];
        // 3.插入老数据
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) SELECT %@ FROM %@;", tableName, columnsString, columnsString, tempTableName];
        // 4.删除临时表
        NSString *dropSql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@;", tempTableName];
        
        return createSql ? @[renameSql, createSql, insertSql, dropSql] : nil;
    }
    
    return nil;
}

@end
