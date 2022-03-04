//
//  FMDBTable.m
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "FMDBTable.h"

@interface FMDBTableColumn ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *datatype;
@property (nullable, nonatomic, copy) NSString *constraint;
@end

@implementation FMDBTableColumn

+ (instancetype)columnWithName:(NSString *)name
                      datatype:(NSString *)datatype
                    constraint:(NSString *)constraint {
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    FMDBTableColumn *tableColumn = [[self alloc] init];
    tableColumn.name = [name stringByTrimmingCharactersInSet:characterSet];
    tableColumn.datatype = [datatype stringByTrimmingCharactersInSet:characterSet];
    tableColumn.constraint = [constraint stringByTrimmingCharactersInSet:characterSet];
    return tableColumn;
}

- (NSString *)description {
    NSString * (^ safeString)(NSString *) = ^NSString *(NSString *value) {
        return value.length > 0 ? value : @"";
    };
    return [NSString stringWithFormat:@"<%@: %p> %@",
            NSStringFromClass([self class]), self, @{
        @"name": safeString(self.name),
        @"datatype": safeString(self.datatype),
        @"constraint": safeString(self.constraint)
    }];
}

- (NSString *)debugDescription {
    return self.description;
}

@end



@interface FMDBTable ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray<FMDBTableColumn *> *columns;
@property (nonatomic) BOOL shouldChangesSchema;
@end

@implementation FMDBTable

+ (instancetype)tableWithName:(NSString *)name
                      columns:(NSArray<FMDBTableColumn *> *)columns {
    return [self tableWithName:name
                       columns:columns
           shouldChangesSchema:NO];
}

+ (instancetype)tableWithName:(NSString *)name
                      columns:(NSArray<FMDBTableColumn *> *)columns
          shouldChangesSchema:(BOOL)shouldChangesSchema {
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    FMDBTable *table = [[self alloc] init];
    table.name = [name stringByTrimmingCharactersInSet:characterSet];
    table.columns = columns;
    table.shouldChangesSchema = shouldChangesSchema;
    return table;
}

@end
