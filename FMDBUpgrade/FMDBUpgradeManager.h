//
//  FMDBUpgradeManager.h
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "FMDBTable.h"

NS_ASSUME_NONNULL_BEGIN

@class FMDatabase;

@protocol FMDBUpgradeManager <NSObject>

+ (instancetype)yyz_databaseWithName:(NSString *)dbName;

- (void)yyz_upgradeTable:(FMDBTable *)table;

- (void)yyz_upgradeTables:(NSArray<FMDBTable *> *)tables;

- (void)yyz_createTable:(FMDBTable *)table;

- (void)yyz_createTables:(NSArray<FMDBTable *> *)tables;

- (void)yyz_deleteTable:(FMDBTable *)table;

- (void)yyz_deleteTables:(NSArray<FMDBTable *> *)tables;

- (void)yyz_inTransaction:(void (NS_NOESCAPE ^)(FMDatabase *db, BOOL *rollback))block;

@end

NS_ASSUME_NONNULL_END
