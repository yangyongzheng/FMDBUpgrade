#### 数据类型及其亲和类型

INTEGER/INT
REAL/FLOAT/DOUBLE
BLOB
TEXT/CHAR/VARCHAR(255)
DATETIME
BOOLEAN

#### 以下对`Student`表进行增删改查操作

##### 1. 删除

- 删除表

```sqlite
DROP TABLE IF EXISTS Student;
```

- 删除表所有数据，但是不会删除表

```sqlite
DELETE FROM Student;
```

##### 2. 创建表

```sqlite
CREATE TABLE IF NOT EXISTS Student (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name CHAR(50) NOT NULL,
    age INT NOT NULL,
    address TEXT,
    height REAL,
    weight FLOAT,
    distance DOUBLE,
    ext BLOB,
    createTime DATETIME DEFAULT(datetime('now', 'localtime')),
    interval INTEGER DEFAULT(strftime('%s', 'now')),
    isCer BOOLEAN
);

CREATE TABLE IF NOT EXISTS Teacher (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(50) NOT NULL,
    age INT NOT NULL,
    address TEXT,
    height REAL,
    timeInterval INTEGER DEFAULT(strftime('%s', 'now'))
);
```

##### 3. 插入数据

- 插入一条数据

```sqlite
INSERT INTO Student (name, age, height, weight, isCer)
VALUES ("张三", 18, 1.67, 60.5, 1);
```

- 从一个表往另一个表插数据

```sqlite
INSERT INTO Teacher (name, age, address, height, timeInterval)
SELECT name, age, address, height, interval
FROM Student;
```

##### 4. 查询

- 查询数据总条数

```sqlite
SELECT count(*) FROM Student;
```

- 查询所有数据

```sqlite
SELECT * FROM Student;
```

- 查询指定的字段数据

```sqlite
SELECT id, name FROM Student;
```

- 按照条件查询

```sqlite
// 查询age在18-21之间的数据, 包括18和21, 区间查询
SELECT * FROM Student WHERE age BETWEEN 18 AND 21;
// 查询age为指定值集数据
SELECT * FROM Student WHERE age IN(18, 19, 21);
// 查询name以li开头的数据（大小写不敏感），百分号（%）代表零个、一个或多个数字或字符，下划线（_）代表一个单一的数字或字符。
SELECT * FROM Student WHERE name LIKE 'li%';
// 查询name以Li开头的数据（大小写敏感），星号（*）代表零个、一个或多个数字或字符，问号（?）代表一个单一的数字或字符。
SELECT * FROM Student WHERE name GLOB 'Li*';
```

- 限制由`SELECT`语句返回的数据数量(分页查询)

```sqlite
SELECT * FROM Student LIMIT pageSize;
SELECT * FROM Student LIMIT pageSize OFFSET pageNumber*pageSize;
🌰:
SELECT * FROM Student LIMIT 10;
SELECT * FROM Student LIMIT 10 OFFSET 1*10;
```

- `ORDER BY`排序查询

```sqlite
SELECT * FROM Student ORDER BY id DESC LIMIT 200 OFFSET 0*10;
```

- `GROUP BY`分组查询，`GROUP BY` 子句放在 `WHERE` 子句之后，放在 `ORDER BY` 子句之前

```sqlite
SELECT * FROM Student GROUP BY name ORDER BY id ASC LIMIT 200 OFFSET 0*10;
```

- `HAVING`子句

```sqlite
SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT
🌰：
SELECT * FROM Student GROUP BY name HAVING count(name) > 2;
```

##### 5. 修改表中已有记录

```sqlite
UPDATE Student SET distance = 123.4356 WHERE age = 18;
UPDATE Student SET ext = "二进制数据" WHERE age = 18;
UPDATE Student SET address = '湖南省长沙市' WHERE age = 18;
```

##### 6. `ALTER TABLE` 命令

- 用来重命名已有的表的`ALTER TABLE`的基本语法如下：

```sqlite
ALTER TABLE Student RENAME TO TempStudent;
```

- 用来在已有的表中添加一个新的列的`ALTER TABLE`的基本语法如下：

```sqlite
ALTER TABLE Student ADD COLUMN sid INTEGER;
```