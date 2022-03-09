//
//  ViewController.m
//  FMDBUpgrade
//
//  Created by yangyongzheng on 2019/1/11.
//  Copyright © 2019 yangyongzheng. All rights reserved.
//

#import "ViewController.h"
#import "TwoViewController.h"
#import "AppLogDatabase.h"
#import "FMDatabaseQueue+Upgrade.h"

@interface ViewController ()
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) dispatch_queue_t taskQueue;
@end

@implementation ViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self.dbQueue close];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setRightNextItem];
    
    self.dbQueue = [FMDatabaseQueue yyz_databaseWithName:@"AppLog.db"];
    self.taskQueue = dispatch_queue_create("com.sqlite.applog.queue", DISPATCH_QUEUE_SERIAL);
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
    dispatch_async(self.taskQueue, ^{
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            const BOOL result = [db executeUpdateWithFormat:@"INSERT INTO start (data, detail, detail2) VALUES (%@, %@, %@);",
                                 [self dataWithDictionary:@{@"class": @1, @"age": @22}],
                                 @"张三", @"安卓工程师"];
            NSAssert(result, @"<1>插入失败");
        }];
    });
    dispatch_async(self.taskQueue, ^{
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            const BOOL result = [db executeUpdateWithFormat:@"INSERT INTO start (data, detail, detail2) VALUES (%@, %@, %@);",
                                 [self dataWithDictionary:@{@"class": @2, @"age": @23}],
                                 @"李四", @"iOS工程师"];
            NSAssert(result, @"<2>插入失败");
        }];
    });
    dispatch_async(self.taskQueue, ^{
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            const BOOL result = [db executeUpdateWithFormat:@"INSERT INTO start (data, detail, detail2) VALUES (%@, %@, %@);",
                                 [self dataWithDictionary:@{@"class": @3, @"age": @24}],
                                 @"王五", @"前端工程师"];
            NSAssert(result, @"<3>插入失败");
        }];
    });
}

- (NSData *)dataWithDictionary:(NSDictionary<NSString *,id> *)dictionary {
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        return [NSJSONSerialization dataWithJSONObject:dictionary
                                               options:kNilOptions
                                                 error:nil];
    }
    return nil;
}

@end
