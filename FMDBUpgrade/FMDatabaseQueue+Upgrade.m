//
//  FMDatabaseQueue+Upgrade.m
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "FMDatabaseQueue+Upgrade.h"
#import "FMDBUpgradeHelper.h"

@implementation FMDatabaseQueue (Upgrade)

+ (instancetype)yyz_databaseWithName:(NSString *)dbName {
    NSString *path = [FMDBUpgradeHelper databasePathWithName:dbName];
    return [self databaseQueueWithPath:path];
}

- (void)yyz_upgradeTable:(FMDBTable *)table {
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_upgradeTable:table];
    }];
}

- (void)yyz_upgradeTables:(NSArray<FMDBTable *> *)tables {
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_upgradeTables:tables];
    }];
}

- (void)yyz_createTable:(FMDBTable *)table {
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_createTable:table];
    }];
}

- (void)yyz_createTables:(NSArray<FMDBTable *> *)tables {
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_createTables:tables];
    }];
}

- (void)yyz_deleteTable:(FMDBTable *)table {
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_deleteTable:table];
    }];
}

- (void)yyz_deleteTables:(NSArray<FMDBTable *> *)tables {
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_deleteTables:tables];
    }];
}

- (void)yyz_inTransaction:(void (NS_NOESCAPE ^)(FMDatabase * _Nonnull, BOOL * _Nonnull))block {
    [self inTransaction:block];
}

@end
