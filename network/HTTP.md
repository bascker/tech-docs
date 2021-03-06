# HTTP
* [简介](#简介)
* [HTTP请求头](#HTTP请求头)
* [HTTP状态码](#HTTP状态码)
* [FAQ](#FAQ)

## 简介
HTTP协议是**基于TCP**协议实现的**属于应用层**的**面向对象**的协议，其主要特点如下：
* 支持C/S模式
* 简单快速
* 灵活：允许传输任意类型的数据对象，使用 _**Content-Type **_指定数据类型
* **无连接**：限制**每次连接只处理一个请求**，服务器**处理完**客户请求，并收到客户的应答后，**即刻断开连接--&gt;短链接**
  > **请求时建立连接，请求完释放连接**的无连接设置，其目的是为了尽快释放资源以服务其他客户端
* **无状态**：无状态指协议**对于事务处理没有记忆能力**，意味着若后续处理需要前面的信息，则它必须重传
  * 优势：在服务器不需要之前的信息时，应答快
  * 劣势：若需要之前的信息，则导致每次连接传送数据流增大

## HTTP请求头
HTTP head字段

字段       | 头部   | 说明          | 示例
-----------|-------|---------------|----------------
Connection | 请求头 | 是否保持连接   | Connection: Keep-Alive
Keep-Alive | 响应头 | 保持连接的时间 | Keep-Alive: timeout=5,max=120
Expiress   | 响应头 | 缓存超时时间 | Expires: Wed, 17 Oct 2018 13:28:00 GMT
Cache-Control | 通用头部 | 被用于在http 请求和响应中通过指定指令来实现缓存机制（较高优先级） |

若在Cache-Control响应头设置了 "max-age" 或者 "s-max-age" 指令，那么 Expires 头会被忽略

## 长连接 & 短连接
**短链接**：建立socket连接后，处理完请求就断开连接，下一个请求到来时，重新建立连接。**短链接一般比较安全，银行大都是短链接**
**长连接**：建立socket连接后，一直保持连接。**长连接安全性低，但由于连接可重用，因此性能较高，资源消耗低**
那么按照HTTP协议无连接无状态的特性，HTTP协议应该是短链接的。由于短链接的缺陷，因此在**HTTP1.1版本**，HTTP协议通过设置`keep-alive`来**支持**持续连接，即**长连接**，实现一个TCP连接持续处理多个HTTP请求，**实现HTTP连接重用**，提高 HTTP 请求与相应的性能。

实现HTTP长连接的好处：
* 更少的建立和关闭tcp连接，可以减少网络流量
* 一直保持TCP连接，后续请求无需再次进行3次握手，减少后续请求的延时
* 尤其在使用HTTPS时，减少多次握手，可以有效减少SSL/TSL的消耗
因此 **HTTP1.1 默认使用的是长连接模式**！

## 请求方法
HTTP协议的请求方法有很多种，常见如下：
1. **GET**：请求**获取**`Request-URI`所标识的资源
2. **POST**：在`Request-URI`所标识的资源后**附加**新的数据
3. **DELETE**：请求服务器**删除**`Request-URI`所标识的资源
4. **PUT**：请求服务器**存储**一个资源，并用`Request-URI`作为其标识
5. **HEAD**：请求**获取**由`Request-URI`所标识的资源的**响应消息报头**

## GET与POST的区别

| **特征** | _**GET**_ | _**POST**_ |
| :--- | :--- | :--- |
| **描述** | 用于向服务器获取资源 | 用于附加新的数据 |
| **数据上限** | 提交的数据**最多1024byte = 1k** | 理论上无上限 |
| **安全性** | 低，数据在URL上可见 | 高 |

## HTTP状态码
HTTP常见状态码

错误码 | 说明
------| --------------
200   | 客户端请求成功
302   | 临时跳转到 location 指定地址
400   | 客户端请求存在语法错误，服务端无法解析
401   | 未授权，需要认证
403   | 服务端收到请求，但拒绝服务
404   | 请求资源不存在
409   | 资源冲突
500   | 服务器内部错误

## FAQ
### 1、请求处理流程
地址栏输入 url 直到页面加载完毕，都会发生什么?
1. DNS 域名解析
2. TCP 建立连接（三次握手）
3. 发送 HTTP 请求
4. 服务端处理请求
5. 服务端返回 Http 响应
6. 浏览器页面渲染
7. 关闭 TCP 连接