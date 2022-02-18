//
//  FMDBTable.m
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "FMDBTable.h"

@implementation FMDBTableColumn

+ (instancetype)columnWithName:(NSString *)name
                      datatype:(NSString *)datatype
                    constraint:(NSString *)constraint {
    FMDBTableColumn *tableColumn = [[self alloc] init];
    tableColumn.name = name;
    tableColumn.datatype = datatype;
    tableColumn.constraint = constraint;
    return tableColumn;
}

@end



@implementation FMDBTable

+ (instancetype)tableWithName:(NSString *)name
                      columns:(NSArray<FMDBTableColumn *> *)columns {
    FMDBTable *table = [[self alloc] init];
    table.name = name;
    table.columns = columns;
    return table;
}

@end
