//
//  FMDatabase+Upgrade.m
//  FMDBUpgrade
//
//  Created by Young on 2022/2/18.
//  Copyright © 2022 yangyongzheng. All rights reserved.
//

#import "FMDatabase+Upgrade.h"
#import "FMDBUpgradeHelper.h"
#import "FMDBTable.h"

@implementation FMDatabase (Upgrade)

// MARK: Public

+ (instancetype)yyz_databaseWithName:(NSString *)dbName {
    FMDBParameterAssert(dbName.length > 0, dbName);
    
    NSString *path = [FMDBUpgradeHelper databasePathWithName:dbName];
    return [self databaseWithPath:path];
}

- (void)yyz_upgradeTables:(NSArray<FMDBTable *> *)tables {
    if (tables.count > 0) {/*next*/} else { return; }
    NSArray<FMDBTable *> *safeTables = [tables copy];
    for (FMDBTable *obj in safeTables) {
        FMDBParameterAssert(obj.name.length > 0, tables);
        
        [self yyz_upgradeTable:obj];
    }
}

- (void)yyz_createTable:(FMDBTable *)table {
    FMDBParameterAssert(table.name.length > 0 && table.columns.count > 0, table);
    
    NSString *sql = [FMDBUpgradeHelper createTableStatementBy:table];
    if (sql) { [self executeUpdate:sql]; }
}

- (void)yyz_createTables:(NSArray<FMDBTable *> *)tables {
    NSString *sql = [FMDBUpgradeHelper createTableStatementsBy:tables];
    if (sql) { [self executeStatements:sql]; }
}

- (void)yyz_dropTableNamed:(NSString *)tableName {
    FMDBParameterAssert(tableName.length > 0, tableName);
    
    NSString *sql = [FMDBUpgradeHelper dropTableStatementBy:tableName];
    if (sql) { [self executeUpdate:sql]; }
}

- (void)yyz_dropTableNames:(NSArray<NSString *> *)tableNames {
    NSString *sql = [FMDBUpgradeHelper dropTableStatementsBy:tableNames];
    if (sql) { [self executeStatements:sql]; }
}

- (void)yyz_inTransaction:(void (NS_NOESCAPE ^)(FMDatabase * _Nonnull, BOOL * _Nonnull))block {
    FMDBParameterAssert(block != nil, block);
    
    // 开始事务
    BOOL requiredRollback = NO;
    [self beginTransaction];
    block(self, &requiredRollback);
    // 事务提交或回滚
    if (requiredRollback) {
        [self rollback];
    } else {
        [self commit];
    }
}

// MARK: - Private

/// 升级单个表
- (void)yyz_upgradeTable:(FMDBTable *)table {
    if (table.name.length > 0) {/*next*/} else { return; }
    if ([self tableExists:table.name]) {
        if (table.columns.count > 0) {
            NSString *sqls = [self yyz_upgradeStatementsWithTable:table];
            if (sqls.length > 0) {
                const BOOL result = [self executeStatements:sqls];
                NSAssert(result, @"Upgrade failed: %@", sqls);
            }
        } else {
            [self yyz_dropTableNamed:table.name];
        }
    } else {
        [self yyz_createTable:table];
    }
}

/// 数据库表升级（调用者已判断 表名、表列 均非空），参考 https://sqlite.org/lang_altertable.html
- (NSString *)yyz_upgradeStatementsWithTable:(FMDBTable *)table {
    // 新表列及其定义映射
    NSMutableDictionary<NSString *,FMDBTableColumn *> *toColumnDictionary = [NSMutableDictionary dictionary];
    for (FMDBTableColumn *obj in table.columns) {
        NSAssert(obj.name.length > 0 && obj.datatype.length > 0, @"Invalid parameter not satisfying: table.columns");
        if (obj.name.length > 0 && obj.datatype.length > 0) {
            toColumnDictionary[obj.name] = obj;
        }
    }
    // 旧表列和新表列集合
    NSSet<NSString *> *fromColumnSet = [self yyz_columnSetInTable:table.name];
    NSSet<NSString *> *toColumnSet = [NSSet setWithArray:toColumnDictionary.allKeys];
    /// 删除旧表，创建新表
    NSString * (^ dropThenCreateTable)(void) = ^NSString *{
        NSMutableArray<NSString *> *statements = [NSMutableArray array];
        
        NSString *dropTable = [FMDBUpgradeHelper dropTableStatementBy:table.name];
        if (dropTable) { [statements addObject:dropTable]; }
        
        NSString *createTable = [FMDBUpgradeHelper createTableStatementBy:table];
        if (createTable) { [statements addObject:createTable]; }
        
        return statements.count > 0 ? [statements componentsJoinedByString:@" "] : nil;
    };
    /// 仅新增列
    NSString * (^ onlyAddColumns)(void) = ^NSString *{
        NSMutableArray<NSString *> *statements = [NSMutableArray array];
        NSSet<NSString *> *addColumnSet = [self yyz_set:toColumnSet minusSet:fromColumnSet];
        for (NSString *obj in addColumnSet) {
            NSString *sql = [FMDBUpgradeHelper addColumnStatementBy:table.name column:toColumnDictionary[obj]];
            if (sql) { [statements addObject:sql]; }
        }
        return statements.count > 0 ? [statements componentsJoinedByString:@" "] : nil;
    };
    /// 删除多余列，添加新增列
    NSString * (^ dropThenAddColumns)(void) = ^NSString *{
        NSMutableArray<NSString *> *statements = [NSMutableArray array];
        
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
        
        return statements.count > 0 ? [statements componentsJoinedByString:@" "] : nil;
    };
    /// 表架构设计变化时
    NSString *(^ changesTableSchema)(void) = ^NSString *{
        NSMutableArray<NSString *> *statements = [NSMutableArray array];
        // 1) Create new table
        FMDBTable *tmpTable = [FMDBTable tableWithName:[NSString stringWithFormat:@"com_upgrade_tmp_%@", table.name]
                                               columns:table.columns
                                   shouldChangesSchema:table.shouldChangesSchema];
        NSString *createTable = [FMDBUpgradeHelper createTableStatementBy:tmpTable];
        if (createTable) { [statements addObject:createTable]; }
        // 2) Copy data
        NSSet<NSString *> *commonColumnSet = [self yyz_set:toColumnSet intersectSet:fromColumnSet];
        NSString *columnNames = [commonColumnSet.allObjects componentsJoinedByString:@", "];
        NSString *insertData = [NSString stringWithFormat:@"INSERT INTO %@ (%@) SELECT %@ FROM %@;",
                                tmpTable.name, columnNames, columnNames, table.name];
        [statements addObject:insertData];
        // 3) Drop old table
        NSString *dropTable = [FMDBUpgradeHelper dropTableStatementBy:table.name];
        if (dropTable) { [statements addObject:dropTable]; }
        // 4) Rename new into old
        NSString *renameTable = [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@;", tmpTable.name, table.name];
        [statements addObject:renameTable];
        
        return statements.count > 0 ? [statements componentsJoinedByString:@" "] : nil;
    };
    
    // 1.旧表无数据时，直接删除旧表，创建新表
    NSString *queryCountStatement = [NSString stringWithFormat:@"SELECT count(*) FROM %@;", table.name];
    const long totalCount = [self longForQuery:queryCountStatement];
    if (totalCount <= 0) {
        return dropThenCreateTable();
    }
    // 2.旧表列和新表列相同，无需升级
    if ([fromColumnSet isEqualToSet:toColumnSet]) {
        return nil;
    }
    // 3.旧表列是新表列的子集，仅新增列
    if ([fromColumnSet isSubsetOfSet:toColumnSet]) {
        return onlyAddColumns();
    }
    // 4.旧表列和新表列存在交集时
    if ([fromColumnSet intersectsSet:toColumnSet]) {
        if (table.shouldChangesSchema) {
            return changesTableSchema();
        } else {
            return dropThenAddColumns();
        }
    } else {
        return dropThenCreateTable();
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
