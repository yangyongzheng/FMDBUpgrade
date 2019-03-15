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
    [self.dbQueue asyncConcurrentExecutionBlock:^{
        
    }];
    
    FMDatabaseQueue *dbQueue2 = [FMDatabaseQueue yyz_databaseWithPath:dbPath];
    [dbQueue2 asyncConcurrentExecutionBlock:^{
        
    }];
    
    FMDatabaseQueue *dbQueue3 = [FMDatabaseQueue yyz_databaseWithPath:dbPath];
    [dbQueue3 asyncConcurrentExecutionBlock:^{
        
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
//    static NSInteger count = 0;
//    if (count % 2 == 0) {
//        int64_t st = CFAbsoluteTimeGetCurrent() * 1000;
//        [self.dbQueue barrierAsyncConcurrentExecutionBlock:^{
//            [self.dbQueue yyz_upgradeTables:@[@"PurchaseList", @"SupplyList"]
//                           withResourceFile:@"BrowseRecords"];
//        }];
//        
//        [self.dbQueue barrierAsyncConcurrentExecutionBlock:^{
//            [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
//                for (int i = 0; i < 5000; i++) {
//                    [db executeUpdateWithFormat:@"INSERT INTO SupplyList (userId,uniqueId,title) VALUES (%d,%d,%@)", 1000+i, i, @"标题"];
//                }
//            }];
//        }];
//        
//        int64_t et = CFAbsoluteTimeGetCurrent() * 1000;
//        NSLog(@"update duration: %lld", et - st);
//    } else {
//        int64_t st = CFAbsoluteTimeGetCurrent() * 1000;
//        
//        [self.dbQueue asyncConcurrentExecutionBlock:^{
//            __block int64_t primaryId = 0;
//            [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
//                FMResultSet *resultSet = [db executeQuery:@"select * from SupplyList ORDER BY id DESC limit 1000"];
//                while ([resultSet next]) {
//                    if (primaryId == 0) {
//                        primaryId = [resultSet longLongIntForColumn:@"id"];
//                    }
//                }
//            }];
//            NSLog(@"primaryId %lld %@", primaryId, [NSThread currentThread]);
//        }];
//        
//        int64_t et = CFAbsoluteTimeGetCurrent() * 1000;
//        NSLog(@"fetch duration: %lld", et - st);
//    }
//    
//    count++;
}

- (NSDictionary *)pageLogsTableConfig {
    return @{@"HNWPageLogs" : @{@"id" : @"INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
                                @"userId" : @"TEXT",
                                @"appVersion" : @"TEXT NOT NULL",
                                @"deviceId" : @"TEXT NOT NULL",
                                @"channel" : @"TEXT NOT NULL DEFAULT('App Store')",
                                @"createTime" : @"INTEGER NOT NULL DEFAULT(strftime('%s', 'now'))",
                                @"updateTime" : @"INTEGER NOT NULL DEFAULT(strftime('%s', 'now'))",
                                @"data" : @"BLOB",
                                }
             };
}

@end
