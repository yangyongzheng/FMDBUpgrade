//
//  FMDBUpgradeHelper.h
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef FMDBParameterAssert
#define FMDBParameterAssert(condition, desc) NSAssert((condition), @"Invalid parameter not satisfying: %@", @#desc)
#endif

@class FMDBTable, FMDBTableColumn;

@interface FMDBUpgradeHelper : NSObject

/// 根据数据库名称获取路径
+ (nullable NSString *)databasePathWithName:(NSString *)dbName;

/// 创建单个表SQL语句，可参考 https://sqlite.org/lang_createtable.html
+ (nullable NSString *)createTableStatementBy:(FMDBTable *)table;

/// 创建多个表SQL语句，可参考 https://sqlite.org/lang_createtable.html
+ (nullable NSString *)createTableStatementsBy:(NSArray<FMDBTable *> *)tables;

/// 删除单个表SQL语句，可参考 https://sqlite.org/lang_droptable.html
+ (nullable NSString *)dropTableStatementBy:(NSString *)tableName;

/// 删除多个表SQL语句，可参考 https://sqlite.org/lang_droptable.html
+ (nullable NSString *)dropTableStatementsBy:(NSArray<NSString *> *)tableNames;

/// 添加列SQL语句，可参考 https://sqlite.org/lang_altertable.html
+ (nullable NSString *)addColumnStatementBy:(NSString *)table column:(FMDBTableColumn *)column;

/// 删除列SQL语句，可参考 https://sqlite.org/lang_altertable.html
+ (nullable NSString *)dropColumnStatementBy:(NSString *)table column:(NSString *)column;

@end

NS_ASSUME_NONNULL_END
