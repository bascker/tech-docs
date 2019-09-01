# 表复制
## 一、简介
将数据从一个表复制到另一张表中，有 2 种方式.

1、SELECT INTO 语句
```
SELECT column_name
INTO tb_2 IN db_name
FROM tb1
WHERE condition
```
> 使用 IN 将数据复制到另一个数据库

2、INSERT INTO 语句
```
INERT INTO tb2
SELECT column_name FROM tb1
WHERE condition
```