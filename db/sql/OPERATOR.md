# 操作符
## 简介
操作符 | 描述 | 备注 | 案例
-------|------|------|------
`=` | 等于判断，或者赋值操作 | 可用于 WHERE、SET、ON 子句 | WHERE age = 1 或者 SET person.city = city.name
`<>` | 不等于，等价于 != |  可用于 WHERE、ON 子句 | WHERE age `<>` 1
`>` | 大于 | 同 `<>` | WHERE age `>` 2
`<` | 小于 | 同 `<>` | WHERE age `<` 8
`>=` | 大于等于 | 同 `<>` | WHERE age `>=` 5
`<=` | 小于等于 | 同 `<>` | WHERE age `<=` 9
`BETWEEN x AND y`| 在某值范围内 | 值类型可以是数值、文本或日期.根据数据库不同，处理方式可能是 [x, y] 或 [x, y) | WHERE char BETWEEN a AND g
`LIKE` | 模式匹配 | 用于 WHERE 子句，常与通配符 `%` 搭配使用 | 搜索名字以 b 开头的人：WHERE name like 'b%' 
`IN` | 在某数值集合中 | 同 `<>` | 名字是否是规定的三个中的一个：WHERE name in ('bascker', 'paul', 'johnnie')
`AND` | 与运算符 | 同 `<>` | WHERE age = 20 and sex = 'male'
`OR` | 或运算符 | 同 `<>` | WHERE (age `>` 20 OR age `<` 10) OR name = 'bascker'
`NOT` | 非运算符，取反 | 同 `<>` | WHERE name NOT LIKE 'b%' 或者 WHERE char NOT BETWEEN a AND g
`AS` | 别名 | | SELECT p.city as city_name FROM person as p;