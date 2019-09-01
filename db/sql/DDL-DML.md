# DML & DDL
SQL 分为 2 个部分组成，DML + DDL

## 一、DML：数据操作语言
DML 部分定义了 SQL 的查询、更新、删除指令：  
* SELECT: 查询数据, `SELECT column FROM table_name WHERE condition`
* UPDATE：更新数据, `UPDATE table_name SET column = value [, column_2] WHERE condition`
* DELETE：删除数据, `DELETE FROM table_name WHERE condition`
* INSERT INTO：插入数据, `INSERT INTO table_name VALUES(...)`

## 二、DML：数据定义语言
DDL 部分定义了 SQL 的创建或删除表格、索引、约束等指令。不同数据库，语法存在差异。

指令 | 描述 | 示例
---- | ---- | ----
CREATE DATABASE | 创建数据库 | `CREATE DATABASE neutron`
ALTER DATABASE | 修改数据库 | 
CREATE TABLE | 创建数据表 | 
ALTER TABLE | 修改数据表 | `ALTER TABLE vpcs ADD name VARCHAR(255)` 或 `ALTER TABLE vpcs DROP COLUMN name`
DROP TABLE | 删除数据表，包括数据和表结构 | `CREATE TABLE vpcs(name VARCHAR(255) NOT NULL)`
TRUNCATE TABLE | 删除表数据，保留表结构 | `TRUNCATE TABLE vpcs` 
CREATE INDEX | 创建索引 | `CREATE INDEX vpc_index ON vpcs(name desc)` 降序索引 vpcs 表中的 name 
ALTER INDEX | 修改索引 | 
DROP INDEX | 删除索引 | `DROP INDEX vpc_index`
CREATE VIEW | 创建视图 | `CREATE VIEW vpc_view AS SELECT name FROM vpcs WHERE name LIKE 'vpc%'`
DELETE | 删除 | `DELETE FROM vpcs WHERE name LIKE 'vpc%'`
UPDATE | 更新 | `UPDATE vpcs SET updated_at = created_at`


