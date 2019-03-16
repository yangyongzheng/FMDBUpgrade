
#import "FMDatabase+Upgrade.h"
#import "FMDatabaseUpgradeHelper.h"

@implementation FMDatabase (Upgrade)

#pragma mark Init
+ (instancetype)yyz_databaseWithPath:(NSString *)dbPath {
    if (FMDatabaseUpgradeHelper.isNotEmptyForString(dbPath)) {
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
    if (FMDatabaseUpgradeHelper.isNotEmptyForArray(tableConfig)) {
        FMDBUpgradeTableConfigArray newTableConfig = [tableConfig copy];
        
        for (FMDBUpgradeTableDictionary tableDictionary in newTableConfig) {
            if (FMDatabaseUpgradeHelper.isNotEmptyForDictionary(tableDictionary)) {
                __weak typeof(self) weakSelf = self;
                [tableDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary<NSString *,NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if ([strongSelf tableExists:key]) {
                        NSArray *localTableColumns = [strongSelf columnsInTable:key];
                        NSArray *referTableColumns = obj.allKeys;
                        NSPredicate *localPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", localTableColumns];
                        NSPredicate *referPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", referTableColumns];
                        NSArray *differColumnsOne = [referTableColumns filteredArrayUsingPredicate:localPredicate];
                        NSArray *differColumnsTwo = [localTableColumns filteredArrayUsingPredicate:referPredicate];
                        NSLog(@"%@-%@", differColumnsOne, differColumnsTwo);
                    } else {
                        [strongSelf yyz_createTableWithConfig:@[tableDictionary]];
                    }
                }];
            } else {
                NSAssert(NO, @"入参tableConfig结构不对");
            }
        }
    }
}

#pragma mark 创建数据库表
- (void)yyz_createTableWithConfig:(FMDBUpgradeTableConfigArray)tableConfig {
    if (FMDatabaseUpgradeHelper.isNotEmptyForArray(tableConfig)) {
        FMDBUpgradeTableConfigArray newArray = [tableConfig copy];
        
        for (FMDBUpgradeTableDictionary tableDictionary in newArray) {
            if (FMDatabaseUpgradeHelper.isNotEmptyForDictionary(tableDictionary)) {
                __weak typeof(self) weakSelf = self;
                [tableDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary<NSString *,NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (![strongSelf tableExists:key]) {
                        NSString *sql = [strongSelf createTableStatementWithName:key configDictionary:obj];
                        [self executeUpdate:sql];
                    }
                }];
            } else {
                NSAssert(NO, @"入参tableConfig结构不对");
            }
        }
    }
}

#pragma mark 删除数据库表
- (void)yyz_deleteTables:(NSArray<NSString *> *)tableNames {
    if (FMDatabaseUpgradeHelper.isNotEmptyForArray(tableNames)) {
        NSArray *newTableNames = [tableNames copy];
        
        [self yyz_inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            for (NSString *table in newTableNames) {
                NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", table];
                [db executeUpdate:sql];
            }
        }];
    }
}

#pragma mark 事物更新
- (void)yyz_transactionExecuteStatements:(NSArray<NSString *> *)sqlStatements {
    if (FMDatabaseUpgradeHelper.isNotEmptyForArray(sqlStatements)) {
        [self beginTransaction];
        
        BOOL isRollBack = NO;
        for (NSString *sql in sqlStatements) {
            if (![self executeUpdate:sql]) {
                isRollBack = YES;
                break;
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
- (NSString *)createTableStatementWithName:(NSString *)tableName configDictionary:(NSDictionary<NSString *, NSString *> *)configDictionary {
    if (FMDatabaseUpgradeHelper.isNotEmptyForString(tableName) && FMDatabaseUpgradeHelper.isNotEmptyForDictionary(configDictionary)) {
        __block NSMutableString *components = [NSMutableString string];
        [configDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *element = [NSString stringWithFormat:@"%@ %@, ", key, obj];   // 拼接字段和字段类型
            [components appendString:element];
        }];
        if (components.length > 2) {
            [components deleteCharactersInRange:NSMakeRange(components.length-2, 2)];
        }
        if (components.length > 0) {
            return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)", tableName, components];
        }
    }
    
    return nil;
}

#pragma mark 本地数据库表的字段集
- (NSArray *)columnsInTable:(NSString *)tableName {
    NSMutableArray *tempArray = [NSMutableArray array];
    FMResultSet *resultSet = [self getTableSchema:tableName];
    while ([resultSet next]) {
        NSString *columnName = [resultSet stringForColumn:@"name"];
        if (FMDatabaseUpgradeHelper.isNotEmptyForString(columnName)) {
            [tempArray addObject:columnName];
        }
    }
    return FMDatabaseUpgradeHelper.isNotEmptyForArray(tempArray) ? [tempArray copy] : nil;
}

@end
