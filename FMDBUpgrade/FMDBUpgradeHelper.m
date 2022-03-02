//
//  FMDBUpgradeHelper.m
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "FMDBUpgradeHelper.h"
#import "FMDBTable.h"

@implementation FMDBUpgradeHelper

+ (NSString *)databasePathWithName:(NSString *)dbName {
    if (dbName.length > 0) {/*next*/} else {
        return nil;
    }
    NSString *validName = [dbName copy];
    // 确认是否有文件扩展，没有时添加默认扩展
    if (validName.pathExtension.length > 0) {/*next*/} else {
        validName = [validName stringByAppendingPathExtension:@"db"];
    }
    // 二次确认是否有文件扩展
    if (validName.pathExtension.length > 0) {/*next*/} else {
        return nil;
    }
    NSString *fullpath = [self fullPathWithSubpath:validName];
    NSString *dirpath = [fullpath stringByDeletingLastPathComponent];
    BOOL isDir = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:dirpath isDirectory:&isDir] && isDir) {/*next*/} else {
        [fm createDirectoryAtPath:dirpath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
    return fullpath;
}

+ (NSString *)fullPathWithSubpath:(NSString *)subpath {
    NSString *safeSubpath = @"com.sqlite.database.default";
    if (subpath.length > 0) {
        safeSubpath = [safeSubpath stringByAppendingPathComponent:subpath];
    }
    NSString *dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask,
                                                            YES).firstObject;
    if ([dirPath hasSuffix:@"/"]) {
        return [dirPath stringByAppendingString:safeSubpath];
    } else {
        return [dirPath stringByAppendingFormat:@"/%@", safeSubpath];
    }
}

+ (NSString *)createTableStatementWithTable:(FMDBTable *)table {
    if ([table isKindOfClass:[FMDBTable class]]) {/*next*/} else {
        return nil;
    }
    if (table.name.length > 0 && table.columns.count > 0) {/*next*/} else {
        return nil;
    }
    // 表字段定义部分
    NSMutableString *columnDef = [NSMutableString string];
    for (FMDBTableColumn *obj in table.columns) {
        NSMutableString *element = [NSMutableString string];
        if (obj.name.length > 0 && obj.datatype.length > 0) {
            [element appendFormat:@"%@ %@", obj.name, obj.datatype];
            if (obj.constraint.length > 0) {
                [element appendFormat:@" %@", obj.constraint];
            }
        }
        if (element.length > 0) {
            if (columnDef.length > 0) {
                [columnDef appendFormat:@", %@", element];
            } else {
                [columnDef appendString:element];
            }
        }
    }
    // 返回创建表SQL语句
    if (columnDef.length > 0) {
        return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@);", table.name, columnDef];
    } else {
        return nil;
    }
}

+ (NSArray<NSString *> *)createTableStatementsWithTables:(NSArray<FMDBTable *> *)tables {
    if (tables.count > 0) {/*next*/} else {
        return nil;
    }
    NSArray<FMDBTable *> *safeTables = [tables copy];
    NSMutableArray<NSString *> *statements = [NSMutableArray arrayWithCapacity:safeTables.count];
    for (FMDBTable *obj in safeTables) {
        NSString *sql = [self createTableStatementWithTable:obj];
        if (sql.length > 0) {
            [statements addObject:sql];
        }
    }
    return statements.count > 0 ? [statements copy] : nil;
}

+ (NSString *)dropTableStatementWithTable:(FMDBTable *)table {
    return nil;
}

+ (NSArray<NSString *> *)dropTableStatementsWithTables:(NSArray<FMDBTable *> *)tables {
    return nil;
}

@end
