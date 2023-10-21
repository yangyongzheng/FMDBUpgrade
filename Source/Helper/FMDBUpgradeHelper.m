//
//  FMDBUpgradeHelper.m
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "FMDBUpgradeHelper.h"
#import "FMDBTable.h"

NSString *FMDBSafeString(id value) {
    NSString *result = nil;
    if (value && [value isKindOfClass:[NSString class]]) {
        result = [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
    return result ?: @"";
}


@implementation FMDBUpgradeHelper

+ (NSString *)databasePathWithName:(NSString *)dbName {
    NSString *validName = FMDBSafeString(dbName);
    FMDBGuard(validName.length > 0) else {
        return nil;
    }
    // 确认是否有文件扩展，没有时添加默认扩展
    FMDBGuard(validName.pathExtension.length > 0) else {
        validName = [validName stringByAppendingPathExtension:@"db"];
    }
    NSString *fullPath = [self fullPathWithSubpath:validName];
    NSString *dirPath = [fullPath stringByDeletingLastPathComponent];
    BOOL isDir = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    FMDBGuard([fm fileExistsAtPath:dirPath isDirectory:&isDir] && isDir) else {
        [fm createDirectoryAtPath:dirPath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
    return fullPath;
}

+ (NSString *)fullPathWithSubpath:(NSString *)subpath {
    NSString *safeSubpath = @"com.sqlite.database.default";
    if (subpath && subpath.length > 0) {
        safeSubpath = [safeSubpath stringByAppendingPathComponent:subpath];
    }
    NSString *dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    if ([dirPath hasSuffix:@"/"]) {
        return [dirPath stringByAppendingString:safeSubpath];
    } else {
        return [dirPath stringByAppendingFormat:@"/%@", safeSubpath];
    }
}

+ (NSString *)createTableStatementBy:(FMDBTable *)table {
    FMDBGuard(table && [table isKindOfClass:[FMDBTable class]] &&
              table.name.length > 0 && table.columns.count > 0) else {
        return nil;
    }
    // 表字段定义部分
    NSMutableString *columnDefs = [NSMutableString string];
    for (FMDBTableColumn *obj in table.columns) {
        NSMutableString *element = [NSMutableString string];
        if (obj.isValidObject) {
            [element appendFormat:@"%@ %@", obj.name, obj.datatype];
            if (obj.constraint.length > 0) {
                [element appendFormat:@" %@", obj.constraint];
            }
        }
        if (element.length > 0) {
            if (columnDefs.length > 0) {
                [columnDefs appendFormat:@", %@", element];
            } else {
                [columnDefs appendString:element];
            }
        }
    }
    // 返回创建表SQL语句
    if (columnDefs.length > 0) {
        return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@);", table.name, columnDefs];
    } else {
        return nil;
    }
}

+ (NSString *)createTableStatementsBy:(NSArray<FMDBTable *> *)tables {
    FMDBGuard(tables && tables.count > 0) else {
        return nil;
    }
    NSArray<FMDBTable *> *safeTables = [tables copy];
    NSMutableArray<NSString *> *statements = [NSMutableArray arrayWithCapacity:safeTables.count];
    for (FMDBTable *obj in safeTables) {
        NSString *sql = [self createTableStatementBy:obj];
        if (sql) { [statements addObject:sql]; }
    }
    return statements.count > 0 ? [statements componentsJoinedByString:@" "] : nil;
}

+ (NSString *)dropTableStatementBy:(NSString *)tableName {
    NSString *safeTableName = FMDBSafeString(tableName);
    FMDBGuard(safeTableName.length > 0) else {
        return nil;
    }
    return [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@;", safeTableName];
}

+ (NSString *)dropTableStatementsBy:(NSArray<NSString *> *)tableNames {
    FMDBGuard(tableNames && tableNames.count > 0) else {
        return nil;
    }
    NSArray<NSString *> *safeTableNames = [tableNames copy];
    NSMutableArray<NSString *> *statements = [NSMutableArray arrayWithCapacity:safeTableNames.count];
    for (NSString *name in safeTableNames) {
        NSString *sql = [self dropTableStatementBy:name];
        if (sql) { [statements addObject:sql]; }
    }
    return statements.count > 0 ? [statements componentsJoinedByString:@" "] : nil;
}

+ (NSString *)addColumnStatementBy:(NSString *)table column:(FMDBTableColumn *)column {
    NSString *safeTable = FMDBSafeString(table);
    FMDBGuard(safeTable.length > 0 &&
              [column isKindOfClass:[FMDBTableColumn class]] &&
              column.isValidObject) else {
        return nil;
    }
    NSMutableString *columnDef = [NSMutableString stringWithFormat:@"%@ %@", column.name, column.datatype];
    if (column.constraint.length > 0) {
        [columnDef appendFormat:@" %@", column.constraint];
    }
    return [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@;", safeTable, columnDef];
}

+ (NSString *)dropColumnStatementBy:(NSString *)table column:(NSString *)column {
    NSString *safeTable = FMDBSafeString(table);
    NSString *safeColumn = FMDBSafeString(column);
    FMDBGuard(safeTable.length > 0 && safeColumn.length > 0) else {
        return nil;
    }
    return [NSString stringWithFormat:@"ALTER TABLE %@ DROP COLUMN %@;", safeTable, safeColumn];
}

@end
