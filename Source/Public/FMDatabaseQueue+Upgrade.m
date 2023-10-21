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
    NSString *path = [FMDBUpgradeHelper databasePathWithName:dbName];
    FMDBParameterAssert(path != nil, dbName);
    return [self databaseQueueWithPath:path];
}

- (void)yyz_upgradeTables:(NSArray<FMDBTable *> *)tables {
    FMDBGuard(tables && tables.count > 0) else {
        FMDBParameterAssert(NO, tables);
        return;
    }
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_upgradeTables:tables];
    }];
}

- (void)yyz_createTable:(FMDBTable *)table {
    FMDBGuard(table && [table isKindOfClass:[FMDBTable class]] &&
              table.name.length > 0 && table.columns.count > 0) else {
        FMDBParameterAssert(NO, table);
        return;
    }
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_createTable:table];
    }];
}

- (void)yyz_createTables:(NSArray<FMDBTable *> *)tables {
    FMDBGuard(tables && tables.count > 0) else {
        FMDBParameterAssert(NO, tables);
        return;
    }
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_createTables:tables];
    }];
}

- (void)yyz_dropTableNamed:(NSString *)tableName {
    FMDBGuard(tableName && tableName.length > 0) else {
        FMDBParameterAssert(NO, tableName);
        return;
    }
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_dropTableNamed:tableName];
    }];
}

- (void)yyz_dropTableNames:(NSArray<NSString *> *)tableNames {
    FMDBGuard(tableNames && tableNames.count > 0) else {
        FMDBParameterAssert(NO, tableNames);
        return;
    }
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_dropTableNames:tableNames];
    }];
}

@end
