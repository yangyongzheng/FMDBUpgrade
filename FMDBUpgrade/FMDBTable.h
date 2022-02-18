//
//  FMDBTable.h
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMDBTableColumn : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *datatype;
@property (nullable, nonatomic, copy) NSString *constraint;

+ (instancetype)columnWithName:(NSString *)name
                      datatype:(NSString *)datatype
                    constraint:(nullable NSString *)constraint;
@end

@interface FMDBTable : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray<FMDBTableColumn *> *columns;

+ (instancetype)tableWithName:(NSString *)name
                      columns:(NSArray<FMDBTableColumn *> *)columns;
@end

NS_ASSUME_NONNULL_END
