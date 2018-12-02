# 反射
## 一、简介
反射机制指的是程序在运行时可以获取自身的信息。给定类名，可以通过反射来获取该类的所有信息。很多开源框架，如 Hibernate、Struts 都使用到了反射机制。
**反射机制专用于处理那些重复的有规则的事情**，如数据库不同表的操作，所以很多自动生成代码的软件就是运用反射机制来完成的。

反射具有高灵活性，可实现动态创建对象和编译，降低耦合性。但使用反射是一种解释操作，告诉 JVM 需要做什么，这种操作速度比较慢，会对性能造成一定影响。

| 特性 | 反射机制创建对象 | new 创建对象
| ---- | -------------- | -----------
| 编译方式 | **动态编译**，在**运行时**才确定类型，绑定对象, 降低耦合 | **静态编译**，在**编译时**就确定了类型，绑定对象

## 二、使用
使用反射可以获取某个类的所有信息，基本使用如下。
```
# className 是全类名，即包名 + 类名
Class clazz = Class.forName("className");   // 加载类，并进行类初始化操作
Object obj = clazz.newInstance()            // 创建类实例
```
> Class.forName(String, boolean, ClassLoader) 的第二个参数可以设置仅仅加载类，但不执行类初始化操作

1.获取构造函数
```
Constructor getConstructor(Class[] params);     // 根据指定参数获得 public 构造器
Constructor[] getConstructors();                // 获得 public 的所有构造器
Constructor[] getDeclaredConstructors();        // 获取所有(public/private)构造器
...
```

2.获取类方法
```
Method getMethod(String name, Class[] params);  // 根据方法名，参数类型获得方法
Method[] getMethods();                          // 获得所有 public 方法
Method[] getDeclaredMethods();                  // 获得所有方法
...
```

3.获取类属性
```
Field getField(String name);
Field[] getFields();
Field[] getDeclaredFields();
...
```

## 三、FAQ
### 3.1 JDBC 中第一步中 Class.forName() 获取的对象，在后面有没有用到？
JDBC连接数据库的一般步骤如下：
```
// JDBC 连接数据库
Class.forName("com.mysql.jdbc.Driver");                          // 注册 JDBC driver，打开与数据库的通信通道
Connection conn = DriverManager.getConnection(DB_URL,USER,PASS); // 获取连接
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery(sql);                           // 执行SQL
while(rs.next()){                                                // 获取数据
 int id  = rs.getInt("id");
 System.out.print("ID: " + id);
}
rs.close();                                                      // 关闭连接
stmt.close();
conn.close();
```

从上面可知道，JDBC连接数据库时第一个步骤获得的 clazz 对象貌似在后面没有用到，那么之后是 DriverManager 如何取得驱动类的信息，从而获取数据库连接 conn 的呢？
```
# com.mysql.jdbc.Driver 静态代码
static {
    try {
        java.sql.DriverManager.registerDriver(new Driver());
    } catch (SQLException E) {
        throw new RuntimeException(“Can’t register driver!”);
    }
}
```

在执行 Class.forName() 后，会执行静态初始化代码，创建了一个 new Driver() 对象，并注册到 DriverManager 中，因此 DriverManager 可以获取到该 MySQL 驱动信息，
从而获取与数据库的连接。即这一步的操作，在后台实际上执行了 3 步操作：
```
Class.forName("com.mysql.jdbc.Driver");                    // 加载类并初始化
# 执行 jdbc.Driver 类静态代码
Driver driver = new Driver();
DriverManager.register(driver);
```

### 3.2 Class.forName() 和 ClassLoader.loadClass() 的区别
`Class.forName()` 默认动作是**先加载类，然后进行类初始化**。当然也可以使用其重载函数控制仅仅加载类信息，但不执行类初始化。
`ClassLoader.loadClass()`是只加载类，并不进行类初始化。