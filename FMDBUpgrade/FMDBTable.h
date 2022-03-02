//
//  FMDBTable.h
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 数据库表列定义类
@interface FMDBTableColumn : NSObject
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *datatype;
@property (nullable, nonatomic, readonly, copy) NSString *constraint;

/// 表列对象初始化
/// @param name 列名称
/// @param datatype 列数据类型，可参考 https://sqlite.org/datatype3.html
/// @param constraint 列约束，可参考 https://sqlite.org/syntax/column-constraint.html
+ (instancetype)columnWithName:(NSString *)name
                      datatype:(NSString *)datatype
                    constraint:(nullable NSString *)constraint;
@end

/// 数据库表定义类
@interface FMDBTable : NSObject
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSArray<FMDBTableColumn *> *columns;

+ (instancetype)tableWithName:(NSString *)name
                      columns:(NSArray<FMDBTableColumn *> *)columns;
@end

NS_ASSUME_NONNULL_END
