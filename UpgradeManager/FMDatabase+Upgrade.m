
#import "FMDatabase+Upgrade.h"
#import "FMDatabaseUpgradeHelper.h"

@implementation FMDatabase (Upgrade)

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

- (void)yyz_upgradeTableWithConfig:(FMDBUpgradeTableConfigArray)tableConfig {
    
}

- (void)yyz_createTableWithConfig:(FMDBUpgradeTableConfigArray)tableConfig {
    
}

- (void)yyz_upgradeTable:(NSString *)tableName withResourceFile:(NSString *)resourceFile {
    if ([FMDatabaseUpgradeHelper isNonEmptyForString:tableName] &&
        [FMDatabaseUpgradeHelper isNonEmptyForString:resourceFile]) {
        if ([self tableExists:tableName]) {
            // 已创建表时检查是否需要更新表
            NSArray *deleteColumnsSqls = [FMDatabaseUpgradeHelper statementsForDeleteColumnsInTable:tableName withDatabase:self resourceFile:resourceFile];
            NSArray *addColumnsSqls = [FMDatabaseUpgradeHelper statementsForAddColumnsInTable:tableName withDatabase:self resourceFile:resourceFile];
            NSMutableArray *updateStatements = [NSMutableArray array];
            [updateStatements addObjectsFromArray:addColumnsSqls];
            [updateStatements addObjectsFromArray:deleteColumnsSqls];
            [self yyz_transactionExecuteStatements:updateStatements];
            NSLog(@"update: %@ -> %@", tableName, updateStatements);
        } else {
            // 创建表
            [self yyz_createTable:tableName withResourceFile:resourceFile];
            NSLog(@"create: %@", tableName);
        }
    }
}

- (void)yyz_upgradeTables:(NSArray<NSString *> *)tableNames withResourceFile:(NSString *)resourceFile {
    if ([FMDatabaseUpgradeHelper isNonEmptyForArray:tableNames] &&
        [FMDatabaseUpgradeHelper isNonEmptyForString:resourceFile]) {
        for (NSString *tableName in tableNames) {
            [self yyz_upgradeTable:tableName withResourceFile:resourceFile];
        }
    }
}

- (BOOL)yyz_createTable:(NSString *)tableName withResourceFile:(NSString *)resourceFile {
    if ([FMDatabaseUpgradeHelper isNonEmptyForString:tableName] &&
        [FMDatabaseUpgradeHelper isNonEmptyForString:resourceFile]) {
        if ([self tableExists:tableName]) {
            return YES; // 已存在表时直接返回 YES
        } else {
            NSString *sql = [FMDatabaseUpgradeHelper statementForCreateTable:tableName withResourceFile:resourceFile];
            if (sql) {
                return [self executeUpdate:sql];
            }
        }
    }
    return NO;
}

- (void)yyz_deleteTables:(NSArray<NSString *> *)tableNames {
    if (FMDatabaseUpgradeHelper.isNotEmptyForArray(tableNames)) {
        for (NSString *table in tableNames) {
            NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", table];
            [self executeUpdate:sql];
        }
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

@end
