# 视图
## 一、简介
视图 view 是基于 SQL 结果集的可视化表，包含行和列。其字段是真实表中的字段。
* 视图总是显示**最新**数据
* 每次查询视图，引擎会**重新执行**视图的 SQL 构建数据

创建或更新视图
```
CREATE OR REPLACE VIEW view_name AS
SELECT column_name FROM table_name
WHERE condition
```
> 可以使用 OR REPLACE 来更新视图

删除视图
```
DROP VIEW view_name;
```

## 二、案例
```
CREATE VIEW view_hz_persons AS
SELECT
    id, CONCAT(first_name, last_name) as name
FROM
    person
WHERE city = '杭州';
```
![view_hz_persons](../assert/view_hz_persons.png)

```
SELECT * FROM view_hz_persons;
```
![sample_view](../assert/sample_view.png)