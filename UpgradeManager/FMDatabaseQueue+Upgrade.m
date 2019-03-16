
#import "FMDatabaseQueue+Upgrade.h"
#import "FMDatabaseUpgradeHelper.h"
#import <objc/runtime.h>

@implementation FMDatabaseQueue (Upgrade)

+ (instancetype)yyz_databaseWithPath:(NSString *)dbPath {
    if (FMDatabaseUpgradeHelper.isNotEmptyForString(dbPath)) {
        if (dbPath.pathExtension.length == 0) {// 无扩展时添加扩展
            dbPath = [dbPath stringByAppendingPathExtension:@"db"];
        }
        NSString *directoryPath = [dbPath stringByDeletingLastPathComponent];
        if (directoryPath.length > 0) {
            if (![NSFileManager.defaultManager fileExistsAtPath:directoryPath isDirectory:NULL]) {// 不存在就创建目录
                [NSFileManager.defaultManager createDirectoryAtPath:directoryPath
                                        withIntermediateDirectories:YES
                                                         attributes:nil
                                                              error:nil];
            }
        }
    }
    return [FMDatabaseQueue databaseQueueWithPath:dbPath];
}

- (void)yyz_upgradeTableWithConfig:(FMDBUpgradeTableConfigArray)tableConfig {
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_upgradeTableWithConfig:tableConfig];
    }];
}

- (void)yyz_createTableWithConfig:(FMDBUpgradeTableConfigArray)tableConfig {
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_createTableWithConfig:tableConfig];
    }];
}

- (void)yyz_deleteTables:(NSArray<NSString *> *)tableNames {
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_deleteTables:tableNames];
    }];
}

- (void)yyz_transactionExecuteStatements:(NSArray *)sqlStatements {
    if (FMDatabaseUpgradeHelper.isNotEmptyForArray(sqlStatements)) {
        [self inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            for (NSString *sql in sqlStatements) {
                if (![db executeUpdate:sql]) {
                    *rollback = YES;
                    break;
                }
            }
        }];
    }
}

- (void)asyncConcurrentExecutionBlock:(void (^)(void))block {
    if (block) {
        dispatch_async([self yyz_currentConcurrentQueue], block);
    }
}

- (void)barrierAsyncConcurrentExecutionBlock:(void (^)(void))block {
    if (block) {
        dispatch_barrier_async([self yyz_currentConcurrentQueue], block);
    }
}

#pragma mark - Misc
- (dispatch_queue_t)yyz_currentConcurrentQueue {
    static const void * const associationKey = (void *)&associationKey;
    dispatch_queue_t queue = objc_getAssociatedObject(self, associationKey);
    if (!queue) {
        NSString *label = [NSString stringWithFormat:@"com.fmdb.upgrade.queue.%@", self];
        queue = dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_CONCURRENT);
        objc_setAssociatedObject(self, associationKey, queue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return queue;
}

@end
