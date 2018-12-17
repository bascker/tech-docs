# I/O
## 同步 VS. 异步IO
| 特征 | BIO | NIO | AIO |
| :--- | :--- | :--- | :--- |
| 包 | java.io | jva.nio | java.nio.channels |
| 描述 | 阻塞IO | 非阻塞IO，异步IO | 异步IO，称作 nio2.0 |
| IO操作 | 普通的io读写操作 | 用于执行非阻塞IO操作 | 用于异步IO操作 |
| 版本 | 一直有 | jdk1.4+ | jdk1.7+ |
| 原理 |  | 基于**事件驱动**思想，用于解决BIO的并发问题 | **windows**上是通过**IOCP**实现的，在**linux**上还是通过**epoll**来实现 |
| 组成 |  | Buffers(缓冲区) + Channels + 非阻塞IO核心类 | 4个异步通道：AsynchronousSocketChannel + AsynchronousServerSocketChannel + AsynchronousFileChannel + AsynchronousDatagramChannel |
| 速度 | 慢 | 较快 | 快 |
| 场景 | 适用于并发数比较小且固定的架构 | 高并发且短连接(轻操作)的架构, 如聊天服务器 | 高并发且长连接(重操作)的架构, 如相册服务器 |