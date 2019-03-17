//
//  TwoViewController.m
//  FMDBUpgrade
//
//  Created by yangyongzheng on 2019/1/11.
//  Copyright © 2019 yangyongzheng. All rights reserved.
//

#import "TwoViewController.h"
#import "FMDBUpgradeHeader.h"

@interface TwoViewController ()
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@end

@implementation TwoViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self.dbQueue close];
}

+ (TwoViewController *)twoViewController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
    TwoViewController *controller = [sb instantiateViewControllerWithIdentifier:@"TwoViewController"];
    controller.hidesBottomBarWhenPushed = YES;
    
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Upgrade";
    NSString *dbPath = [NSString stringWithFormat:@"%@/Documents/Database/BrowseRecords.db", NSHomeDirectory()];
    self.dbQueue = [FMDatabaseQueue yyz_databaseWithPath:dbPath];
}

- (IBAction)upgradeButtonAction:(UIButton *)sender {
    [self upgradeText];
}

- (void)upgradeText {
    static NSInteger count = 0;
    if (count % 2 == 0) {
        int64_t st = CFAbsoluteTimeGetCurrent() * 1000;
        
        int repeat = 0;
        while (repeat < 2) {
            repeat++;
            __weak typeof(self) weakSelf = self;
            [self.dbQueue barrierAsyncConcurrentExecutionBlock:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
                    for (int i = 0; i < 100000; i++) {
                        [db executeUpdateWithFormat:@"INSERT INTO HNWPageLogs (userId, businessId) VALUES (%@, %@)", @(1000+i).stringValue, @"标题"];
                    }
                }];
                
                int64_t et = CFAbsoluteTimeGetCurrent() * 1000;
                NSLog(@"插入 duration: %lld->%@", et - st, [NSThread currentThread]);
            }];
        }
    } else {
        int64_t st = CFAbsoluteTimeGetCurrent() * 1000;
        
        for (int count = 0; count < 10; count++) {
            __weak typeof(self) weakSelf = self;
            [self.dbQueue asyncConcurrentExecutionBlock:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                __block int64_t primaryId = 0;
                [strongSelf.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
                    FMResultSet *resultSet = [db executeQuery:@"select * from HNWPageLogs ORDER BY id DESC"];
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

@end
