//
//  FMDatabaseUpgradeHelper.h
//  FMDBDemo
//
//  Created by yangyongzheng on 2018/9/11.
//  Copyright © 2018年 yangyongzheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface FMDatabaseUpgradeHelper : NSObject

+ (BOOL)isNonEmptyForString:(id)string;
+ (BOOL)isNonEmptyForArray:(id)array;
+ (BOOL)isNonEmptyForDictionary:(id)dictionary;

+ (NSString *)statementForCreateTable:(NSString *)tableName
                     withResourceFile:(NSString *)resourceFile;

// 注意调用一下方法时需要提前 open db
+ (NSArray *)statementsForAddColumnsInTable:(NSString *)tableName
                               withDatabase:(FMDatabase *)db
                               resourceFile:(NSString *)resourceFile;

+ (NSArray *)statementsForDeleteColumnsInTable:(NSString *)tableName
                                  withDatabase:(FMDatabase *)db
                                  resourceFile:(NSString *)resourceFile;

@end
