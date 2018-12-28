# SQL 注入
## 一、简介
通过构建特殊的输入作为参数传入Web应用程序，最终达到欺骗服务器执行恶意的SQL命令。实例如下：
```
$ String sql = "select * from user where name= '"+varname+"' and passwd='"+varpasswd+"'"

# SQL 注入：将用户名 123 和 ' or '1' = '1 作为密码传入，将成功入侵
$ sql = "select * from user where name= '123' and passwd='' or '1' = '1'"
```

## 二、Statement vs. PrepareStatement
| **特征** | **Statement** | **PrepareStatement** |
| -------- | ------------- | -------------------- |
| 创建 | `Statement stmt = conn.CreateStatement();` | `PrepareStatement ptmt = conn.PreparedStatement(sql);` |
| 参数 | 用于执行静态sql语句，不能携带参数 | 预编译的sql语句对象，sql语句被预编译并保存在对象中，可以携带参数 |
| 安全 | 不安全，容易发生SQL注入 | 安全，防止SQL注入 |
| 可读性 | 低，不易维护 | 高，易维护 |
| 性能 | 低，每次都要编译 | 高，sql语句编译后存入缓存，可以减少编译次数提高性能 |
