
#import "FMDatabaseUpgradeHelper.h"
#import "FMDB.h"

static NSString * const FMDBUpgradeResourceExtPlist = @"plist";

@implementation FMDatabaseUpgradeHelper

+ (BOOL (^)(id))isNotEmptyForString {
    return ^BOOL(id string) {
        return string && [string isKindOfClass:[NSString class]] && ((NSString *)string).length > 0;
    };
}

+ (BOOL (^)(id))isNotEmptyForArray {
    return ^BOOL(id array) {
        return array && [array isKindOfClass:[NSArray class]] && ((NSArray *)array).count > 0;
    };
}

+ (BOOL (^)(id))isNotEmptyForDictionary {
    return ^BOOL(id dictionary) {
        return dictionary && [dictionary isKindOfClass:[NSDictionary class]] && ((NSDictionary *)dictionary).count > 0;
    };
}

+ (BOOL)isNonEmptyForString:(id)string {
    return string && [string isKindOfClass:[NSString class]] && ((NSString *)string).length > 0;
}

+ (BOOL)isNonEmptyForArray:(id)array {
    return array && [array isKindOfClass:[NSArray class]] && ((NSArray *)array).count > 0;
}

+ (BOOL)isNonEmptyForDictionary:(id)dictionary {
    return dictionary && [dictionary isKindOfClass:[NSDictionary class]] && ((NSDictionary *)dictionary).count > 0;
}

+ (NSString *)statementForCreateTable:(NSString *)tableName withResourceFile:(NSString *)resourceFile {
    NSDictionary *dictionary = [FMDatabaseUpgradeHelper resourceDictionaryForTable:tableName withResourceFile:resourceFile];
    if (dictionary) {
        __block NSMutableString *components = [NSMutableString string];
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *element = [NSString stringWithFormat:@"%@ %@, ", key, obj];// 拼接字段和字段类型
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

+ (NSArray *)statementsForAddColumnsInTable:(NSString *)tableName withDatabase:(FMDatabase *)db resourceFile:(NSString *)resourceFile {
    if (db && [db isKindOfClass:[FMDatabase class]] &&
        [FMDatabaseUpgradeHelper isNonEmptyForString:tableName] &&
        [FMDatabaseUpgradeHelper isNonEmptyForString:resourceFile]) {
        NSDictionary *resourceTableDictionary = nil;
        NSArray *columns = [FMDatabaseUpgradeHelper columnsToAddInTable:tableName
                                                           withDatabase:db
                                                           resourceFile:resourceFile
                                                resourceTableDictionary:&resourceTableDictionary];
        if (columns && resourceTableDictionary) {// 有需要更新的字段
            NSMutableArray *statements = [NSMutableArray arrayWithCapacity:columns.count];
            for (NSString *columnName in columns) {
                NSString *columnType = [resourceTableDictionary objectForKey:columnName];
                NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, columnName, columnType];
                [statements addObject:sql];
            }
            return [FMDatabaseUpgradeHelper isNonEmptyForArray:statements] ? [statements copy] : nil;
        }
    }
    
    return nil;
}

+ (NSArray *)statementsForDeleteColumnsInTable:(NSString *)tableName withDatabase:(FMDatabase *)db resourceFile:(NSString *)resourceFile {
    if (db && [db isKindOfClass:[FMDatabase class]] &&
        [FMDatabaseUpgradeHelper isNonEmptyForString:tableName] &&
        [FMDatabaseUpgradeHelper isNonEmptyForString:resourceFile]) {
        NSDictionary *resourceTableDictionary = nil;
        NSArray *deleteColumns = [FMDatabaseUpgradeHelper columnsToDeleteInTable:tableName
                                                                    withDatabase:db
                                                                    resourceFile:resourceFile
                                                         resourceTableDictionary:&resourceTableDictionary];
        if (deleteColumns && resourceTableDictionary) {
            // 有需要删除的字段时，按照如下步骤间接实现(SQLite暂不支持直接删除数据库表字段)
            NSString *tempTableName = [NSString stringWithFormat:@"COM_YYZ_TEMP_%@", tableName];// 临时表名称
            NSString *columnsStr = [resourceTableDictionary.allKeys componentsJoinedByString:@", "];
            // 1.重命名数据库为临时数据库名称
            NSString *rename = [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@", tableName, tempTableName];
            // 2.重新创建新数据库
            NSString *createTableSql = [self statementForCreateTable:tableName withResourceFile:resourceFile];
            // 3.插入原数据库所有数据
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ SELECT %@ FROM %@", tableName, columnsStr, tempTableName];
            // 4.删除临时数据库
            NSString *dropSql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tempTableName];
            return @[rename, createTableSql, insertSql, dropSql];
        }
    }
    
    return nil;
}

#pragma mark - Private
#pragma mark 需添加的字段集(资源文件有而表里面没有的字段集)
+ (NSArray *)columnsToAddInTable:(NSString *)tableName
                    withDatabase:(FMDatabase *)db
                    resourceFile:(NSString *)resourceFile
         resourceTableDictionary:(NSDictionary **)resourceTableDictionary {
    NSArray *tableColumns = [FMDatabaseUpgradeHelper columnsInTable:tableName withDatabase:db];
    NSArray *resourceColumns = [FMDatabaseUpgradeHelper columnsInTable:tableName
                                                      withResourceFile:resourceFile
                                               resourceTableDictionary:resourceTableDictionary];
    if (tableColumns && resourceColumns) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", tableColumns];
        NSArray *differColumns = [resourceColumns filteredArrayUsingPredicate:predicate];
        return [FMDatabaseUpgradeHelper isNonEmptyForArray:differColumns] ? differColumns : nil;
    }
    
    return nil;
}

#pragma mark 需删除的字段集(表里面有而资源文件没有的字段集)
+ (NSArray *)columnsToDeleteInTable:(NSString *)tableName
                       withDatabase:(FMDatabase *)db
                       resourceFile:(NSString *)resourceFile
            resourceTableDictionary:(NSDictionary **)resourceTableDictionary {
    NSArray *tableColumns = [FMDatabaseUpgradeHelper columnsInTable:tableName withDatabase:db];
    NSArray *resourceColumns = [FMDatabaseUpgradeHelper columnsInTable:tableName
                                                      withResourceFile:resourceFile
                                               resourceTableDictionary:resourceTableDictionary];
    if (tableColumns && resourceColumns) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", resourceColumns];
        NSArray *differColumns = [tableColumns filteredArrayUsingPredicate:predicate];
        return [FMDatabaseUpgradeHelper isNonEmptyForArray:differColumns] ? differColumns : nil;
    }
    
    return nil;
}

#pragma mark 本地数据库表的字段集
+ (NSArray *)columnsInTable:(NSString *)tableName withDatabase:(FMDatabase *)db {
    NSMutableArray *tempArray = [NSMutableArray array];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        NSString *columnName = [resultSet stringForColumn:@"name"];
        if ([FMDatabaseUpgradeHelper isNonEmptyForString:columnName]) {
            [tempArray addObject:columnName];
        }
    }
    return [FMDatabaseUpgradeHelper isNonEmptyForArray:tempArray] ? [tempArray copy] : nil;
}

#pragma mark 资源文件的表对应字段集
+ (NSArray *)columnsInTable:(NSString *)tableName
           withResourceFile:(NSString *)resourceFile
    resourceTableDictionary:(NSDictionary **)resourceTableDictionary {
    NSDictionary *dictionary = [FMDatabaseUpgradeHelper resourceDictionaryForTable:tableName withResourceFile:resourceFile];
    if (resourceTableDictionary) {*resourceTableDictionary = dictionary;}
    return dictionary.allKeys;
}

+ (NSDictionary *)resourceDictionaryForTable:(NSString *)tableName withResourceFile:(NSString *)resourceFile {
    if ([FMDatabaseUpgradeHelper isNonEmptyForString:tableName] && [FMDatabaseUpgradeHelper isNonEmptyForString:resourceFile]) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:resourceFile ofType:FMDBUpgradeResourceExtPlist];
        if (filePath) {
            NSDictionary *rootDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
            if ([FMDatabaseUpgradeHelper isNonEmptyForDictionary:rootDictionary]) {
                NSDictionary *tableDictionary = [rootDictionary objectForKey:tableName];
                if ([FMDatabaseUpgradeHelper isNonEmptyForDictionary:tableDictionary]) {
                    __block NSMutableDictionary *filterTableDictionary = [NSMutableDictionary dictionaryWithCapacity:tableDictionary.count];
                    [tableDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        if ([FMDatabaseUpgradeHelper isNonEmptyForString:key] && [FMDatabaseUpgradeHelper isNonEmptyForString:obj]) {
                            NSString *column = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            NSString *columnType = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if (column && columnType) {
                                [filterTableDictionary setObject:columnType forKey:column];
                            }
                        }
                    }];
                    return filterTableDictionary.count > 0 ? [filterTableDictionary copy] : nil;
                }
            }
        }
    }
    
    return nil;
}

@end
