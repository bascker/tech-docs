# 临时表
## 一、简介
用于保存临时数据，它只在会话期间存在，会在当前终端结束后被删除。
* 若是在脚本中操作的DB，则在脚本执行完毕后，删除临时表
* 客户端程序操作，则客户端关闭时删除

## 二、示例
```
CREATE TEMPORARY TABLE products (name VARCHAR(20) NOT NULL );
```
使用 `SHOW TABLES` 是看不到临时表的。