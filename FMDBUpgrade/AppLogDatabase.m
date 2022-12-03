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
    return [self tableWithName:@"start"];
}

+ (FMDBTable *)pageTable {
    return [self tableWithName:@"page"];
}

+ (FMDBTable *)eventTable {
    return [self tableWithName:@"event"];
}

+ (FMDBTable *)crashTable {
    return [self tableWithName:@"crash"];
}

+ (FMDBTable *)tableWithName:(NSString *)name {
    FMDBTableColumn *cid = [FMDBTableColumn columnWithName:@"id"
                                                  datatype:@"INTEGER"
                                                constraint:@"PRIMARY KEY AUTOINCREMENT"];
    
    FMDBTableColumn *cdata = [FMDBTableColumn columnWithName:@"data"
                                                    datatype:@"BLOB"
                                                  constraint:@"NOT NULL"];
    
    FMDBTableColumn *ccreateTime = [FMDBTableColumn columnWithName:@"createTime"
                                                          datatype:@"INTEGER"
                                                        constraint:@"DEFAULT(strftime('%s','now'))"];
    
    FMDBTableColumn *ctitle = [FMDBTableColumn columnWithName:@"title"
                                                     datatype:@"TEXT"
                                                   constraint:nil];
    
    return [FMDBTable tableWithName:name columns:@[cid, cdata, ccreateTime, ctitle]];
}

@end
