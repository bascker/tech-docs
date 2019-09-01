# 索引
## 一、简介
索引 index 用于快速创建或检索数据，是指向表数据的指针。
* 提高了 SELECT 和 WHERE 子句的速度
* 降低了 UPDATE 和 INSERT 语句的速度

```
CREATE INDEX 
    index_name 
ON 
    table_name (column_name1, column_name2);
```
建立索引的原则
* 小表不应使用索引
* 频繁大量插入更新的表不应使用索引
* 列中包含大数或 NULL 值，不宜使用索引

索引类别 | 描述 | 示例
-------- | ---- | ----
单列索引 | 基于单一字段创建 | CREATE INDEX index_name ON vpcs(name);
唯一索引 | 使用 CREATE UNIQUE INDEX 创建, 唯一索引不允许向表插入重复值 | CREATE UNIQUE INDEX index_name ON vpcs(name);
聚簇索引 | 基于两个及以上字段创建 | CREATE INDEX index_id_name ON vpcs(id, name);
隐式索引 | 数据库在创建某些对象的时候自动生成，如主键约束、唯一约束，就会自动创建索引 | 

> 创建单列索引还是聚簇索引，要看每次查询中，哪些列在作为过滤条件的 WHERE 子句中最常出现。