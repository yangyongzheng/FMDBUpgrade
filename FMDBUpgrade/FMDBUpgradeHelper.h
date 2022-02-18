//
//  FMDBUpgradeHelper.h
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMDBUpgradeHelper : NSObject

+ (NSString *)databasePathWithName:(NSString *)dbName;

@end

NS_ASSUME_NONNULL_END
