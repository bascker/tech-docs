# 数据类型
## 简介
数据类型 | 描述 | 案例 | 备注
-------- | ---- | ---- | -----
character | 字符、字符串 | | 固定长度 n
varchar | 字符、字符串 | | 可变长度, 最大长度为 n
text | 字符串 | | 最大长度 65535 字节
tinytext | 字符串 | | 最大长度 255 字节
binary | 二进制串 | | 固定长度 n  
varbinary | 二进制串 | | 可变长度，最大为 n
boolean | 布尔数据，TRUE or FALSE | |
integer | 整数 | | |
smallint | 整数 | | |
bigint | 整数 | | |
decimal(size, d) | 字符串形式存储 double 类型, 精确到小数点后 d 位 | decimal(5, 2)，小数点前有3位，小数点后有 2 位 |
float(size, d) | float 类型 | |
double(size, d) | double 类型 | |
blob | binary large object | | 最多 16777215 字节 |
enum | 枚举列表，允许输入可能值列表 | enum('a', 'b', 'c') | 若不存在插入的值，则插入空值
set | 无序列表，最多 64 个值
date | 日期, 格式为 YYYY-MM-DD | 2019-09-01 |
datetime | 日期时间，格式为 YYYY-MM-DD HH:MM:SS | 2019-09-01 21:00:00
timestamp | 时间戳，格式为 YYYY-MM-DD HH:MM:SS| | UTC时间
time | 时间，格式为 HH:MM:SS | | 
year | 年份，2 位或 4 位格式 | | 2 位格式：70（1970）~69（2069）   

