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

- (instancetype)initWithName:(NSString *)name
                    datatype:(NSString *)datatype
                  constraint:(NSString *)constraint {
    self = [super init];
    if (self) {
        NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        self.name = [name stringByTrimmingCharactersInSet:characterSet];
        self.datatype = [datatype stringByTrimmingCharactersInSet:characterSet];
        self.constraint = [constraint stringByTrimmingCharactersInSet:characterSet];
    }
    return self;
}

+ (instancetype)columnWithName:(NSString *)name
                      datatype:(NSString *)datatype
                    constraint:(NSString *)constraint {
    return [[self alloc] initWithName:name
                             datatype:datatype
                           constraint:constraint];
}

- (BOOL)isValidObject {
    return self.name && self.name.length > 0 && self.datatype && self.datatype.length > 0;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> %@",
            NSStringFromClass([self class]), self, @{
        @"name": self.name ?: @"",
        @"datatype": self.datatype ?: @"",
        @"constraint": self.constraint ?: @""
    }];
}

@end



@interface FMDBTable ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray<FMDBTableColumn *> *columns;
@property (nonatomic) BOOL shouldChangesSchema;
@end

@implementation FMDBTable

- (instancetype)initWithName:(NSString *)name
                     columns:(NSArray<FMDBTableColumn *> *)columns {
    return [self initWithName:name
                      columns:columns
          shouldChangesSchema:NO];
}

+ (instancetype)tableWithName:(NSString *)name
                      columns:(NSArray<FMDBTableColumn *> *)columns {
    return [self tableWithName:name
                       columns:columns
           shouldChangesSchema:NO];
}

- (instancetype)initWithName:(NSString *)name
                     columns:(NSArray<FMDBTableColumn *> *)columns
         shouldChangesSchema:(BOOL)shouldChangesSchema {
    self = [super init];
    if (self) {
        self.name = [name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        self.columns = columns;
        self.shouldChangesSchema = shouldChangesSchema;
    }
    return self;
}

+ (instancetype)tableWithName:(NSString *)name
                      columns:(NSArray<FMDBTableColumn *> *)columns
          shouldChangesSchema:(BOOL)shouldChangesSchema {
    return [[self alloc] initWithName:name
                              columns:columns
                  shouldChangesSchema:shouldChangesSchema];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> %@",
            NSStringFromClass([self class]), self, @{
        @"shouldChangesSchema": @(self.shouldChangesSchema),
        @"name": self.name ?: @"",
        @"columns": self.columns ?: @[]
    }];
}

@end
