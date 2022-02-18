//
//  AppLogDatabase.m
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "AppLogDatabase.h"

@implementation AppLogDatabase

+ (FMDBTable *)startTable {
    FMDBTableColumn *cid = [FMDBTableColumn columnWithName:@"id"
                                                  datatype:@""
                                                constraint:@""];
    return [FMDBTable tableWithName:@"start" columns:@[cid]];
}

@end
