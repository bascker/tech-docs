# 约束
## 一、简介
约束是表数据的规则，分为表约束和列约束 2 种，用于保证数据的准确性和可靠性。

约束 | 描述 | 示例
---- | ---- | ----
NOT NULL | 非空约束，列数据不能存在空值 | CREATE TABLE vpcs(name VARCHAR(255) NOT NULL);
DEFAULT | 默认值约束，列数据未指定时采用的默认值 |  CREATE TABLE vpcs(created_at TIMESTAMP DEFAULT CURRENT_STAMP());
UNIQUE | 唯一约束，保证列数据不重复 | CREATE TABLE vpcs(id CHAR(32) NOT NULL UNIQUE);
PRIMARY KEY | 主键约束，主键必须唯一，不能为 NULL，一张表只能有一个主键 | CREATE TABLE vpcs(id CHAR(32) PRIMARY KEY);
FOREIGN KEY | 外键约束，指向另一张表的主键，用于预防破坏表间连接关系，防止非法数据插入外键列 | CREATE TABLE vpcs(id CHAR(32) PRIMARY KEY, subnet_id CHAR(32), FORENGIN KEY (subnet_id) REFERENCES subnet(id));
CHECK | 值约束，限制列中值范围 | CREATE TABLE person(age INTEGER NOT NULL, CHECK(age > 0 AND age < 100))