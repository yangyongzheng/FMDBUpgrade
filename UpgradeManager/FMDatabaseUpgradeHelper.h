
#import <Foundation/Foundation.h>

@class FMDatabase;

@interface FMDatabaseUpgradeHelper : NSObject

@property (class, nonatomic, readonly, copy) BOOL(^ isNotEmptyForString)(id string);
@property (class, nonatomic, readonly, copy) BOOL(^ isNotEmptyForArray)(id array);
@property (class, nonatomic, readonly, copy) BOOL(^ isNotEmptyForDictionary)(id dictionary);

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
