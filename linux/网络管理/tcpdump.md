# tcpdump
## 简介

网络抓包工具，可以将网络中传送的数据包完全截获下来提供分析

```
$ yum install -y tcpdump
```

## 操作

* _tcpdump -i INTERFACE_：监视指定网络接口的数据包，默认是第一个网卡 eth0
* _tcpdump host HOSTNAME_：监视指定主机的数据包
* _tcpdump PROTOTYPE_：监视指定协议的数据包
* _tcpdump tcp port 80 and host 10.158.113.161_：监视指定主机和协议端口的数据包