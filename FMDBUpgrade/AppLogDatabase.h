//
//  AppLogDatabase.h
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "FMDBTable.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppLogDatabase : NSObject
@property (class, nonatomic, readonly, strong) FMDBTable *startTable;
@property (class, nonatomic, readonly, strong) FMDBTable *pageTable;
@property (class, nonatomic, readonly, strong) FMDBTable *eventTable;
@property (class, nonatomic, readonly, strong) FMDBTable *crashTable;
@end

NS_ASSUME_NONNULL_END
