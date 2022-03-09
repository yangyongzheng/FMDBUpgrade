//
//  FMDatabase+Upgrade.h
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import <FMDB/FMDB.h>
#import "FMDBUpgradeManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FMDatabase (Upgrade) <FMDBUpgradeManager>

@end

NS_ASSUME_NONNULL_END
