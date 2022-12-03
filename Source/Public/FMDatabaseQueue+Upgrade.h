//
//  FMDatabaseQueue+Upgrade.h
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import <FMDB/FMDB.h>

NS_ASSUME_NONNULL_BEGIN

@class FMDBTable;

@interface FMDatabaseQueue (Upgrade)

/// 根据数据库名称创建管理对象
/// @param dbName 数据库名称
+ (instancetype)yyz_databaseWithName:(NSString *)dbName;

/// 升级数据库表，参考 [ALTER TABLE](https://sqlite.org/lang_altertable.html)
/// @param tables 待升级表对象数组
/// @discussion 表对象 FMDBTable.columns.count == 0 时会删除其对应表
- (void)yyz_upgradeTables:(NSArray<FMDBTable *> *)tables;

/// 创建单个表，参考 [CREATE TABLE](https://sqlite.org/lang_createtable.html)
/// @param table 待创建表对象
- (void)yyz_createTable:(FMDBTable *)table;

/// 创建多个表，参考 [CREATE TABLE](https://sqlite.org/lang_createtable.html)
/// @param tables 待创建表对象数组
- (void)yyz_createTables:(NSArray<FMDBTable *> *)tables;

/// 删除单个表，参考 [DROP TABLE](https://sqlite.org/lang_droptable.html)
/// @param tableName 待删除表名称
- (void)yyz_dropTableNamed:(NSString *)tableName;

/// 删除多个表，参考 [DROP TABLE](https://sqlite.org/lang_droptable.html)
/// @param tableNames 待删除表名称数组
- (void)yyz_dropTableNames:(NSArray<NSString *> *)tableNames;

@end

NS_ASSUME_NONNULL_END
