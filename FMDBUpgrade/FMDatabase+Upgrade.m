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
    
}

- (void)yyz_createTables:(NSArray<FMDBTable *> *)tables {
    
}

- (void)yyz_deleteTable:(FMDBTable *)table {
    
}

- (void)yyz_deleteTables:(NSArray<FMDBTable *> *)tables {
    
}

- (void)yyz_inTransaction:(void (NS_NOESCAPE ^)(FMDatabase * _Nonnull, BOOL * _Nonnull))block {
    
}

@end
