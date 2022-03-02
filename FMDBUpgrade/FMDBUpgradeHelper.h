//
//  FMDBUpgradeHelper.h
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FMDBTable;

@interface FMDBUpgradeHelper : NSObject

+ (nullable NSString *)databasePathWithName:(NSString *)dbName;

/// 创建表SQL语句，可参考 https://sqlite.org/lang_createtable.html
+ (nullable NSString *)createTableStatementWithTable:(FMDBTable *)table;

+ (nullable NSArray<NSString *> *)createTableStatementsWithTables:(NSArray<FMDBTable *> *)tables;

/// 删除表SQL语句，可参考 https://sqlite.org/lang_droptable.html
+ (nullable NSString *)dropTableStatementWithTable:(FMDBTable *)table;

+ (nullable NSArray<NSString *> *)dropTableStatementsWithTables:(NSArray<FMDBTable *> *)tables;

@end

NS_ASSUME_NONNULL_END
