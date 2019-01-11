//
//  FMDatabaseQueue+Upgrade.m
//  FMDBDemo
//
//  Created by yangyongzheng on 2018/9/11.
//  Copyright © 2018年 yangyongzheng. All rights reserved.
//

#import "FMDatabaseQueue+Upgrade.h"
#import "FMDatabaseUpgradeHelper.h"
#import "FMDatabase+Upgrade.h"
#import <objc/runtime.h>

static NSString * const FMDBQueueIdentifierUpgrade = @"com.fmdb.queue.identifier.upgrade";
static const void * YYZFMDBQueueDictionaryAssociationKey = (void *)&YYZFMDBQueueDictionaryAssociationKey;

@implementation FMDatabaseQueue (Upgrade)

+ (instancetype)yyz_databaseWithPath:(NSString *)dbPath {
    if ([FMDatabaseUpgradeHelper isNonEmptyForString:dbPath]) {
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

- (void)yyz_upgradeTable:(NSString *)tableName withResourceFile:(NSString *)resourceFile {
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        [db yyz_upgradeTable:tableName withResourceFile:resourceFile];
    }];
}

- (BOOL)yyz_createTable:(NSString *)tableName withResourceFile:(NSString *)resourceFile {
    __block BOOL result = NO;
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db yyz_createTable:tableName withResourceFile:resourceFile];
    }];
    
    return result;
}

- (BOOL)yyz_deleteTable:(NSString *)tableName {
    __block BOOL result = NO;
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db  yyz_deleteTable:tableName];
    }];
    
    return result;
}

- (void)yyz_transactionExecuteStatements:(NSArray *)sqlStatements {
    if ([FMDatabaseUpgradeHelper isNonEmptyForArray:sqlStatements]) {
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

- (void)asyncAddToSerialQueueWithTableName:(NSString *)tableName executionBlock:(void (^)(void))block {
    if (block) {
        dispatch_async([self yyz_serialQueueWithTableName:tableName], block);
    }
}

#pragma mark - Misc
- (dispatch_queue_t)yyz_serialQueueWithTableName:(NSString *)tableName {
    dispatch_queue_t queue = nil;
    
    NSString *label = nil;
    if (tableName && [tableName isKindOfClass:[NSString class]] && tableName.length > 0) {
        label = [NSString stringWithFormat:@"%@.%@", FMDBQueueIdentifierUpgrade, tableName];
    } else {
        label = [NSString stringWithFormat:@"%@.%@", FMDBQueueIdentifierUpgrade, self];
    }
    
    NSMutableDictionary *queueDictionary = objc_getAssociatedObject(self, YYZFMDBQueueDictionaryAssociationKey);
    if (queueDictionary) {
        queue = [queueDictionary objectForKey:label];
        if (!queue) {
            queue = dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_SERIAL);
            [queueDictionary setObject:queue forKey:label];
            objc_setAssociatedObject(self, YYZFMDBQueueDictionaryAssociationKey, queueDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    } else {
        queue = dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_SERIAL);
        queueDictionary = [NSMutableDictionary dictionary];
        [queueDictionary setObject:queue forKey:label];
        objc_setAssociatedObject(self, YYZFMDBQueueDictionaryAssociationKey, queueDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return queue;
}

@end
