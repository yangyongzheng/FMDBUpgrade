//
//  FMDBTable.h
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 数据库表列封装
@interface FMDBTableColumn : NSObject
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *datatype;
@property (nullable, nonatomic, readonly, copy) NSString *constraint;
/// 当 self.name、self.datatype 非空时返回YES，否则返回NO。
@property (nonatomic, readonly) BOOL isValidObject;

/// 表列初始化
/// - Parameters:
///   - name: 列名称
///   - datatype: 列数据类型，可参考 https://sqlite.org/datatype3.html
///   - constraint: 列约束，可参考 https://sqlite.org/syntax/column-constraint.html
+ (instancetype)columnWithName:(NSString *)name
                      datatype:(NSString *)datatype
                    constraint:(nullable NSString *)constraint;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end



/// 数据库表封装
@interface FMDBTable : NSObject
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSArray<FMDBTableColumn *> *columns;
/// 添加或删除表列时，是否需要更改表结构，默认值 NO。
@property (nonatomic, readonly) BOOL shouldChangesSchema;

/// 表初始化，相当于 [self tableWithName:name columns:columns shouldChangesSchema:NO];
/// - Parameters:
///   - name: 表名称
///   - columns: 表列数组
+ (instancetype)tableWithName:(NSString *)name
                      columns:(NSArray<FMDBTableColumn *> *)columns;

/// 表初始化
/// - Parameters:
///   - name: 表名称
///   - columns: 表列数组
///   - shouldChangesSchema: 添加或删除表列时，是否需要更改表结构
+ (instancetype)tableWithName:(NSString *)name
                      columns:(NSArray<FMDBTableColumn *> *)columns
          shouldChangesSchema:(BOOL)shouldChangesSchema;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END


/** FMDBTable.shouldChangesSchema
 删除表列包含以下情况时设为YES，否则设为NO。
 1.The column is a PRIMARY KEY or part of one.
 2.The column has a UNIQUE constraint.
 3.The column is indexed.
 4.The column is named in the WHERE clause of a partial index.
 5.The column is named in a table or column CHECK constraint not associated with the column being dropped.
 6.The column is used in a foreign key constraint.
 7.The column is used in the expression of a generated column.
 8.The column appears in a trigger or view.
 */
