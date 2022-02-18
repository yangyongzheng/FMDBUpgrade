
#import "FMDatabase+Upgrade.h"

NS_ASSUME_NONNULL_BEGIN

@interface FMDatabaseQueue (Upgrade)

+ (instancetype)yyz_databaseWithPath:(NSString *)dbPath;

- (void)yyz_upgradeTableWithConfig:(NSArray<FMDBUpgradeTableDictionary> *)tableConfig;

- (void)yyz_createTableWithConfig:(NSArray<FMDBUpgradeTableDictionary> *)tableConfig;

- (void)yyz_deleteTables:(NSArray<NSString *> *)tableNames;

/**
 事务更新sql语句
 注意：sql语句数组中任意一条sql语句执行出错直接回滚.
 
 @param sqlStatements sql语句数组
 */
- (void)yyz_transactionExecuteStatements:(NSArray<NSString *> *)sqlStatements;

/**
 添加异步并发执行任务，一般用于查询操作

 @param block 任务Block
 */
- (void)asyncConcurrentExecutionBlock:(dispatch_block_t)block;

/**
 Submits a barrier block for asynchronous execution and returns immediately.
 一般用于增/删/改操作

 @param block 任务Block
 */
- (void)barrierAsyncConcurrentExecutionBlock:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
