//
//  FMDatabase+Upgrade.h
//  FMDBDemo
//
//  Created by yangyongzheng on 2018/9/11.
//  Copyright © 2018年 yangyongzheng. All rights reserved.
//

#import <FMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMDatabase (Upgrade)

+ (instancetype)yyz_databaseWithPath:(NSString *)dbPath;

- (void)yyz_upgradeTable:(NSString *)tableName withResourceFile:(NSString *)resourceFile;

- (void)yyz_upgradeTables:(NSArray<NSString *> *)tableNames withResourceFile:(NSString *)resourceFile;

- (BOOL)yyz_createTable:(NSString *)tableName withResourceFile:(NSString *)resourceFile;

- (BOOL)yyz_deleteTable:(NSString *)tableName;

/**
 事务提交sql语句
 注意：sql语句数组中任意一条sql语句执行出错直接回滚.

 @param sqlStatements sql语句数组
 */
- (void)yyz_transactionExecuteStatements:(NSArray *)sqlStatements;

/**
 事务更新

 @param block 事务更新Block
 */
- (void)yyz_inTransaction:(void(^)(FMDatabase *db, BOOL *rollback))block;

@end

NS_ASSUME_NONNULL_END