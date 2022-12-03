//
//  FMDBNavigationController.m
//  FMDBUpgrade
//
//  Created by yangyongzheng on 2022/12/3.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "FMDBNavigationController.h"

@interface FMDBNavigationController ()

@end

@implementation FMDBNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *titleTextAttributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightMedium],
        NSForegroundColorAttributeName: UIColor.blackColor
    };
    self.navigationBar.barTintColor = UIColor.whiteColor;
    self.navigationBar.translucent = YES;
    [self.navigationBar setBackgroundImage:[self imageWithColor:UIColor.whiteColor]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationBar.titleTextAttributes = titleTextAttributes;
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *sa = self.navigationBar.standardAppearance;
        sa.backgroundEffect = nil;
        sa.backgroundImage = nil;
        sa.backgroundColor = UIColor.whiteColor;
        sa.shadowImage = nil;
        sa.shadowColor = UIColor.clearColor;
        sa.titleTextAttributes = titleTextAttributes;
        self.navigationBar.standardAppearance = sa;
        self.navigationBar.scrollEdgeAppearance = sa;
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    const CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [resultImage resizableImageWithCapInsets:UIEdgeInsetsZero
                                       resizingMode:UIImageResizingModeStretch];
}

@end
