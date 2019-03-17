//
//  ViewController.m
//  FMDBUpgrade
//
//  Created by yangyongzheng on 2019/1/11.
//  Copyright © 2019 yangyongzheng. All rights reserved.
//

#import "ViewController.h"
#import "TwoViewController.h"
#import "FMDBUpgradeHeader.h"

@interface ViewController ()
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@end

@implementation ViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self.dbQueue close];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setRightNextItem];
    
    NSString *dbPath = [NSString stringWithFormat:@"%@/Documents/Database/BrowseRecords.db", NSHomeDirectory()];
    self.dbQueue = [FMDatabaseQueue yyz_databaseWithPath:dbPath];
    
    int64_t st = CFAbsoluteTimeGetCurrent() * 1000;
    [self.dbQueue barrierAsyncConcurrentExecutionBlock:^{
        [self.dbQueue yyz_upgradeTableWithConfig:@[self.pageLogsTableConfig, self.eventLogsTableConfig]];
        
        int64_t et = CFAbsoluteTimeGetCurrent() * 1000;
        NSLog(@"update duration: %lld", et - st);
    }];
}

- (void)setRightNextItem {
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(nextActionItem:)];
    self.navigationItem.rightBarButtonItem = nextItem;
}

- (void)nextActionItem:(UIBarButtonItem *)item {
    TwoViewController *controller = TwoViewController.twoViewController;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)upgradeButtonAction:(UIButton *)sender {
    [self upgradeText];
}

- (void)upgradeText {
    static NSInteger count = 1;
    if (count % 2 == 0) {
        int64_t st = CFAbsoluteTimeGetCurrent() * 1000;
        
        int repeat = 0;
        while (repeat < 2) {
            repeat++;
            __weak typeof(self) weakSelf = self;
            [self.dbQueue barrierAsyncConcurrentExecutionBlock:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
                    for (int i = 0; i < 100; i++) {
                        [db executeUpdateWithFormat:@"INSERT INTO HNWPageLogs (userId, businessId) VALUES (%@, %@)", @(1000+i).stringValue, @"标题"];
                    }
                }];
                
                int64_t et = CFAbsoluteTimeGetCurrent() * 1000;
                NSLog(@"插入 duration: %lld->%@", et - st, [NSThread currentThread]);
            }];
        }
    } else {
        int64_t st = CFAbsoluteTimeGetCurrent() * 1000;
        
        for (int count = 0; count <= 10; count++) {
            __weak typeof(self) weakSelf = self;
            [self.dbQueue asyncConcurrentExecutionBlock:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                __block int64_t primaryId = 0;
                [strongSelf.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
                    FMResultSet *resultSet = [db executeQuery:@"select * from HNWPageLogs ORDER BY id DESC LIMIT 10000"];
                    while ([resultSet next]) {
                        if (primaryId == 0) {
                            primaryId = [resultSet longLongIntForColumn:@"id"];
                        }
                    }
                }];
                
                int64_t et = CFAbsoluteTimeGetCurrent() * 1000;
                NSLog(@"查询%d duration: %lld，primaryId %lld->%@", count, et - st, primaryId, [NSThread currentThread]);
            }];
        }
    }
    
    count++;
}

- (NSDictionary *)pageLogsTableConfig {
    return @{@"HNWPageLogs" : @{@"id" : @"INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
                                @"userId" : @"TEXT",
                                @"appVersion" : @"TEXT NOT NULL DEFAULT('unknown')",
                                @"deviceId" : @"TEXT NOT NULL DEFAULT('unknown')",
                                @"channel" : @"TEXT NOT NULL DEFAULT('App Store')",
                                @"createTime" : @"INTEGER NOT NULL DEFAULT(strftime('%s', 'now'))",
                                @"updateTime" : @"INTEGER NOT NULL DEFAULT(strftime('%s', 'now'))",
                                @"jsonData" : @"BLOB",
                                @"businessId" : @"TEXT",
                                },
             @"HNWCrashLogs" : @{@"id" : @"INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
                                 @"userId" : @"TEXT",
                                 @"appVersion" : @"TEXT NOT NULL DEFAULT('unknown')",
                                 @"deviceId" : @"TEXT NOT NULL DEFAULT('unknown')",
                                 @"channel" : @"TEXT NOT NULL DEFAULT('App Store')",
                                 @"createTime" : @"INTEGER NOT NULL DEFAULT(strftime('%s', 'now'))",
                                 @"updateTime" : @"INTEGER NOT NULL DEFAULT(strftime('%s', 'now'))",
                                 @"data" : @"BLOB",
                                 },
             };
}

- (NSDictionary *)eventLogsTableConfig {
    return @{@"HNWEventLogs" : @{@"id" : @"INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
                                 @"userId" : @"TEXT",
                                 @"appVersion" : @"TEXT NOT NULL DEFAULT('unknown')",
                                 @"deviceId" : @"TEXT NOT NULL DEFAULT('unknown')",
                                 @"channel" : @"TEXT NOT NULL DEFAULT('App Store')",
                                 @"createTime" : @"INTEGER NOT NULL DEFAULT(strftime('%s', 'now'))",
                                 @"updateTime" : @"INTEGER NOT NULL DEFAULT(strftime('%s', 'now'))",
                                 @"data" : @"BLOB",
                                 },
             };
}

@end
