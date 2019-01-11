//
//  FMDatabaseQueue+Upgrade.h
//  FMDBDemo
//
//  Created by yangyongzheng on 2018/9/11.
//  Copyright © 2018年 yangyongzheng. All rights reserved.
//

#import <FMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMDatabaseQueue (Upgrade)

+ (instancetype)yyz_databaseWithPath:(NSString *)dbPath;

- (void)yyz_upgradeTable:(NSString *)tableName withResourceFile:(NSString *)resourceFile;

- (BOOL)yyz_createTable:(NSString *)tableName withResourceFile:(NSString *)resourceFile;

- (BOOL)yyz_deleteTable:(NSString *)tableName;

/**
 事务更新sql语句
 注意：sql语句数组中任意一条sql语句执行出错直接回滚.
 
 @param sqlStatements sql语句数组
 */
- (void)yyz_transactionExecuteStatements:(NSArray *)sqlStatements;

/**
 异步添加任务到串行队列, 建议在主线程调用此API

 @param tableName 待执行任务的数据库表
 @param block 任务Block
 */
- (void)asyncAddToSerialQueueWithTableName:(NSString *)tableName executionBlock:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
