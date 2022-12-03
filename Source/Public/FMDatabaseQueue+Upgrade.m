//
//  FMDatabaseQueue+Upgrade.m
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "FMDatabaseQueue+Upgrade.h"
#import "FMDatabase+Upgrade.h"
#import "FMDBUpgradeHelper.h"
#import "FMDBTable.h"

@implementation FMDatabaseQueue (Upgrade)

+ (instancetype)yyz_databaseWithName:(NSString *)dbName {
    FMDBParameterAssert(dbName.length > 0, dbName);
    
    NSString *path = [FMDBUpgradeHelper databasePathWithName:dbName];
    return [self databaseQueueWithPath:path];
}

- (void)yyz_upgradeTables:(NSArray<FMDBTable *> *)tables {
    if (tables.count > 0) {/*next*/} else { return; }
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_upgradeTables:tables];
    }];
}

- (void)yyz_createTable:(FMDBTable *)table {
    FMDBParameterAssert(table.name.length > 0 && table.columns.count > 0, table);
    
    if (table.name.length > 0 && table.columns.count > 0) {/*next*/} else {
        return;
    }
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_createTable:table];
    }];
}

- (void)yyz_createTables:(NSArray<FMDBTable *> *)tables {
    if (tables.count > 0) {/*next*/} else { return; }
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_createTables:tables];
    }];
}

- (void)yyz_dropTableNamed:(NSString *)tableName {
    FMDBParameterAssert(tableName.length > 0, tableName);
    
    if (tableName.length > 0) {/*next*/} else { return; }
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_dropTableNamed:tableName];
    }];
}

- (void)yyz_dropTableNames:(NSArray<NSString *> *)tableNames {
    if (tableNames.count > 0) {/*next*/} else { return; }
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_dropTableNames:tableNames];
    }];
}

@end
