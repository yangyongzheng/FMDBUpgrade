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

- (void)yyz_dropTableNamed:(NSString *)tableName {
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_dropTableNamed:tableName];
    }];
}

- (void)yyz_dropTableNames:(NSArray<NSString *> *)tableNames {
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_dropTableNames:tableNames];
    }];
}

- (void)yyz_inTransaction:(void (NS_NOESCAPE ^)(FMDatabase * _Nonnull, BOOL * _Nonnull))block {
    [self inTransaction:block];
}

@end
