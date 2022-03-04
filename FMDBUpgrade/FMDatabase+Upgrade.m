//
//  FMDatabase+Upgrade.m
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "FMDatabase+Upgrade.h"
#import "FMDBUpgradeHelper.h"

@implementation FMDatabase (Upgrade)

+ (instancetype)yyz_databaseWithName:(NSString *)dbName {
    NSAssert(dbName.length > 0, @"Invalid parameter not satisfying: %@", dbName);
    
    NSString *path = [FMDBUpgradeHelper databasePathWithName:dbName];
    return [self databaseWithPath:path];
}

- (void)yyz_upgradeTables:(NSArray<FMDBTable *> *)tables {
    if (tables.count > 0) {/*next*/} else {
        return;
    }
    NSArray<FMDBTable *> *safeTables = [tables copy];
    for (FMDBTable *obj in safeTables) {
        NSAssert(obj.name.length > 0, @"Invalid parameter not satisfying: %@", obj);
        if (obj.name.length > 0) {
            if ([self tableExists:obj.name]) {
                if (obj.columns.count > 0) {
                    NSString *sqls = [self yyz_upgradeStatementsWithTable:obj];
                    if (sqls.length > 0) {
                        const BOOL result = [self executeStatements:sqls];
                        NSAssert(result, @"Upgrade failed: %@", sqls);
                    }
                } else {
                    [self yyz_dropTableNamed:obj.name];
                }
            } else {
                [self yyz_createTable:obj];
            }
        }
    }
}

- (void)yyz_createTable:(FMDBTable *)table {
    NSAssert(table.name.length > 0 && table.columns.count > 0,
             @"Invalid parameter not satisfying: %@", table);
    
    NSString *sql = [FMDBUpgradeHelper createTableStatementBy:table];
    if (sql) { [self executeUpdate:sql]; }
}

- (void)yyz_createTables:(NSArray<FMDBTable *> *)tables {
    NSString *sql = [FMDBUpgradeHelper createTableStatementsBy:tables];
    if (sql) { [self executeStatements:sql]; }
}

- (void)yyz_dropTableNamed:(NSString *)tableName {
    NSAssert(tableName.length > 0, @"Invalid parameter not satisfying: %@", tableName);
    
    NSString *sql = [FMDBUpgradeHelper dropTableStatementBy:tableName];
    if (sql) { [self executeUpdate:sql]; }
}

- (void)yyz_dropTableNames:(NSArray<NSString *> *)tableNames {
    NSString *sql = [FMDBUpgradeHelper dropTableStatementsBy:tableNames];
    if (sql) { [self executeStatements:sql]; }
}

- (void)yyz_inTransaction:(void (NS_NOESCAPE ^)(FMDatabase * _Nonnull, BOOL * _Nonnull))block {
    NSAssert(block, @"Invalid parameter not satisfying: %@", block);
    
    BOOL requiredRollback = NO;
    // 开始事物
    [self beginTransaction];
    block(self, &requiredRollback);
    // 回滚或提交事物
    if (requiredRollback) {
        [self rollback];
    } else {
        [self commit];
    }
}

// MARK: - Private
/// 数据库表升级（调用者已判断 表名、表列 均非空），参考 https://sqlite.org/lang_altertable.html
- (NSString *)yyz_upgradeStatementsWithTable:(FMDBTable *)table {
    // 新表列及其定义映射
    NSMutableDictionary<NSString *,FMDBTableColumn *> *toColumnDictionary = [NSMutableDictionary dictionary];
    for (FMDBTableColumn *obj in table.columns) {
        NSAssert(obj.name.length > 0 && obj.datatype.length > 0, @"Invalid parameter not satisfying: %@", obj);
        if (obj.name.length > 0 && obj.datatype.length > 0) {
            toColumnDictionary[obj.name] = obj;
        }
    }
    // 旧表列和新表列集合
    NSSet<NSString *> *fromColumnSet = [self yyz_columnSetInTable:table.name];
    NSSet<NSString *> *toColumnSet = [NSSet setWithArray:toColumnDictionary.allKeys];
    
    // 1.旧表列和新表列相同，无需升级
    if ([fromColumnSet isEqualToSet:toColumnSet]) {
        return nil;
    }
    
    // 2.旧表无数据时，直接删除旧表，创建新表
    const long totalCount = [self longForQuery:@"SELECT count(*) FROM %@;", table.name];
    if (totalCount <= 0) {
        NSMutableArray<NSString *> *statements = [NSMutableArray array];
        
        NSString *dropTable = [FMDBUpgradeHelper dropTableStatementBy:table.name];
        if (dropTable) { [statements addObject:dropTable]; }
        
        NSString *createTable = [FMDBUpgradeHelper createTableStatementBy:table];
        if (createTable) { [statements addObject:createTable]; }
        
        return statements.count > 0 ? [statements componentsJoinedByString:@" "] : nil;
    }
    
    // 3.旧表列是新表列的子集，仅新增列
    if ([fromColumnSet isSubsetOfSet:toColumnSet]) {
        NSSet<NSString *> *addColumnSet = [self yyz_set:toColumnSet minusSet:fromColumnSet];
        NSMutableArray<NSString *> *statements = [NSMutableArray array];
        for (NSString *obj in addColumnSet) {
            NSString *sql = [FMDBUpgradeHelper addColumnStatementBy:table.name column:toColumnDictionary[obj]];
            if (sql) { [statements addObject:sql]; }
        }
        return statements.count > 0 ? [statements componentsJoinedByString:@" "] : nil;
    }
    /**
     4.1 旧表列和新表列存在交集时，判断是否更改表架构设计
     - 更改表架构设计
     1) Create new table
     2) Copy data
     3) Drop old table
     4) Rename new into old
     - 不更改表架构设计
     1) Drop old column
     2) Add new column
     
     4.2 旧表列和新表列不存在交集时
     1) 删除旧表
     2) 创建新表
     */
    if ([fromColumnSet intersectsSet:toColumnSet]) {
        NSMutableArray<NSString *> *statements = [NSMutableArray array];
        
        if (table.shouldChangesSchema) {
            FMDBTable *tmpTable = [FMDBTable tableWithName:[NSString stringWithFormat:@"com_upgrade_tmp_%@", table.name]
                                                   columns:table.columns
                                       shouldChangesSchema:table.shouldChangesSchema];
            NSString *createTable = [FMDBUpgradeHelper createTableStatementBy:tmpTable];
            if (createTable) { [statements addObject:createTable]; }
            
            NSSet<NSString *> *commonColumnSet = [self yyz_set:toColumnSet intersectSet:fromColumnSet];
            NSString *columnNames = [commonColumnSet.allObjects componentsJoinedByString:@", "];
            NSString *insertData = [NSString stringWithFormat:@"INSERT INTO %@ (%@) SELECT %@ FROM %@;",
                                    tmpTable.name, columnNames, columnNames, table.name];
            [statements addObject:insertData];
            
            NSString *dropTable = [FMDBUpgradeHelper dropTableStatementBy:table.name];
            if (dropTable) { [statements addObject:dropTable]; }
            
            NSString *renameTable = [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@;", tmpTable.name, table.name];
            [statements addObject:renameTable];
        } else {
            NSSet<NSString *> *dropColumnSet = [self yyz_set:fromColumnSet minusSet:toColumnSet];
            for (NSString *obj in dropColumnSet) {
                NSString *sql = [FMDBUpgradeHelper dropColumnStatementBy:table.name column:obj];
                if (sql) { [statements addObject:sql]; }
            }
            
            NSSet<NSString *> *addColumnSet = [self yyz_set:toColumnSet minusSet:fromColumnSet];
            for (NSString *obj in addColumnSet) {
                NSString *sql = [FMDBUpgradeHelper addColumnStatementBy:table.name column:toColumnDictionary[obj]];
                if (sql) { [statements addObject:sql]; }
            }
        }
        
        return statements.count > 0 ? [statements componentsJoinedByString:@" "] : nil;
    } else {
        NSMutableArray<NSString *> *statements = [NSMutableArray array];
        
        NSString *dropTable = [FMDBUpgradeHelper dropTableStatementBy:table.name];
        if (dropTable) { [statements addObject:dropTable]; }
        
        NSString *createTable = [FMDBUpgradeHelper createTableStatementBy:table];
        if (createTable) { [statements addObject:createTable]; }
        
        return statements.count > 0 ? [statements componentsJoinedByString:@" "] : nil;
    }
}

/// 获取已存在表列集合
- (NSSet<NSString *> *)yyz_columnSetInTable:(NSString *)tableName {
    NSMutableSet<NSString *> *outputSet = [NSMutableSet set];
    FMResultSet *resultSet = [self getTableSchema:tableName];
    while ([resultSet next]) {
        NSString *columnName = [resultSet stringForColumn:@"name"];
        if (columnName.length > 0) {
            [outputSet addObject:columnName];
        }
    }
    return outputSet.count > 0 ? [outputSet copy] : nil;
}

/// 两个集合的差集
/// Removes each object in another given set from the receiving set, if present.
- (NSSet<NSString *> *)yyz_set:(NSSet<NSString *> *)receivingSet
                      minusSet:(NSSet<NSString *> *)otherSet {
    if (receivingSet.count > 0) {
        if (otherSet.count > 0) {
            NSMutableSet *resultSet = [NSMutableSet setWithSet:receivingSet];
            [resultSet minusSet:otherSet];
            return [resultSet copy];
        } else {
            return [receivingSet copy];
        }
    } else {
        return nil;
    }
}

/// 两个集合的交集
/// Removes from the receiving set each object that isn’t a member of another given set.
- (NSSet<NSString *> *)yyz_set:(NSSet<NSString *> *)receivingSet
                  intersectSet:(NSSet<NSString *> *)otherSet {
    if (receivingSet.count > 0 && otherSet.count > 0) {
        NSMutableSet *resultSet = [NSMutableSet setWithSet:receivingSet];
        [resultSet intersectSet:otherSet];
        return [resultSet copy];
    } else {
        return nil;
    }
}

@end
