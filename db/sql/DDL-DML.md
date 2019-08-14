# DML & DDL
SQL 分为 2 个部分组成，DML + DDL

## 一、DML：数据操作语言
DML 部分定义了 SQL 的查询、更新、删除指令：  
* SELECT: 查询数据, `SELECT column FROM table_name WHERE condition`
* UPDATE：更新数据, `UPDATE table_name SET column = value [, column_2] WHERE condition`
* DELETE：删除数据, `DELETE FROM table_name WHERE condition`
* INSERT INTO：插入数据, `INSERT INTO table_name VALUES(...)`

## 二、DML：数据定义语言
DDL 部分定义了 SQL 的创建或删除表格、索引、约束等指令。举例如：
* CREATE DATABASE: 创建数据库
* ALTER DATABASE: 修改数据库
* CREATE TABLE: 创建数据表
* ALTER TABLE: 修改数据表
* DROP TABLE: 删除数据表
* CREATE INDEX: 创建索引
* ALTER INDEX: 修改索引
* DROP INDEX: 删除索引
