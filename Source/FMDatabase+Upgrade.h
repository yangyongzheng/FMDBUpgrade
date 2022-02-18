
#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> * FMDBUpgradeTableDictionary;

@interface FMDatabase (Upgrade)

+ (instancetype)yyz_databaseWithPath:(NSString *)dbPath;

- (void)yyz_upgradeTableWithConfig:(NSArray<FMDBUpgradeTableDictionary> *)tableConfig;

- (void)yyz_createTableWithConfig:(NSArray<FMDBUpgradeTableDictionary> *)tableConfig;

- (void)yyz_deleteTables:(NSArray<NSString *> *)tableNames;

/**
 事务提交sql语句
 注意：sql语句数组中任意一条sql语句执行出错直接回滚.

 @param sqlStatements sql语句数组
 */
- (void)yyz_transactionExecuteStatements:(NSArray<NSString *> *)sqlStatements;

/**
 事务更新

 @param block 事务更新Block
 */
- (void)yyz_inTransaction:(void(^)(FMDatabase *db, BOOL *rollback))block;

@end

NS_ASSUME_NONNULL_END
