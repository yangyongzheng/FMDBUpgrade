//
//  TwoViewController.m
//  FMDBUpgrade
//
//  Created by yangyongzheng on 2019/1/11.
//  Copyright © 2019 yangyongzheng. All rights reserved.
//

#import "TwoViewController.h"
#import "FMDatabaseQueue+Upgrade.h"

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
    self.dbQueue = [FMDatabaseQueue yyz_databaseWithName:@"AppLog.db"];
}

- (IBAction)upgradeButtonAction:(UIButton *)sender {
    [self upgradeText];
}

- (void)upgradeText {
    
}

@end
