# 简介
etcd 和 consul 一样，也是一个高可用的 key/value 存储系统。可以用于分享配置和服务发现。其特点如下：
* 简单：支持 curl 方式的 API ---&gt;  RESTFul API
* 安全：可选 SSL 客户端证书认证
* 快速：单实例可达每秒 10000 次写操作
* 可靠：使用 Raft 实现分布式

etcd 的监听端口为 4001
```
$ netstat -anp | grep 4001
tcp6       0      0 :::4001                 :::*                    LISTEN      14313/etcd
tcp6       0      0 ::1:34787               ::1:4001                ESTABLISHED 14313/etcd
tcp6       0      0 ::1:34785               ::1:4001                ESTABLISHED 14313/etcd
...
```

> 下载地址：[https://github.com/coreos/etcd/releases/](https://github.com/coreos/etcd/releases/)