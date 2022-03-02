//
//  FMDatabase+Upgrade.m
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "FMDatabase+Upgrade.h"
#import "FMDBUpgradeHelper.h"

@implementation FMDatabase (Upgrade)

+ (instancetype)yyz_databaseWithName:(NSString *)dbName {
    NSString *path = [FMDBUpgradeHelper databasePathWithName:dbName];
    return [self databaseWithPath:path];
}

- (void)yyz_upgradeTable:(FMDBTable *)table {
    
}

- (void)yyz_upgradeTables:(NSArray<FMDBTable *> *)tables {
    
}

- (void)yyz_createTable:(FMDBTable *)table {
    NSString *sql = [FMDBUpgradeHelper createTableStatementWithTable:table];
    [self executeUpdate:sql];
}

- (void)yyz_createTables:(NSArray<FMDBTable *> *)tables {
    NSArray *sqls = [FMDBUpgradeHelper createTableStatementsWithTables:tables];
    NSString *fullSql = [sqls componentsJoinedByString:@" "];
    [self executeStatements:fullSql];
}

- (void)yyz_deleteTable:(FMDBTable *)table {
    NSString *sql = [FMDBUpgradeHelper dropTableStatementWithTable:table];
    [self executeUpdate:sql];
}

- (void)yyz_deleteTables:(NSArray<FMDBTable *> *)tables {
    NSArray *sqls = [FMDBUpgradeHelper dropTableStatementsWithTables:tables];
    NSString *fullSql = [sqls componentsJoinedByString:@" "];
    [self executeStatements:fullSql];
}

- (void)yyz_inTransaction:(void (NS_NOESCAPE ^)(FMDatabase * _Nonnull, BOOL * _Nonnull))block {
    BOOL requiredRollback = NO;
    // 开始事物
    [self beginTransaction];
    block(self, &requiredRollback);
    // 回滚或提交事物
    if (requiredRollback) {
        [self rollback];
    } else {
        [self commit];
    }
}

@end
