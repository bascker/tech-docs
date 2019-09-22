# tcpdump
## 一、简介
网络抓包工具，可以将网络中传送的数据包完全截获下来提供分析
```
$ yum install -y tcpdump
```

## 二、操作
* `tcpdump -i INTERFACE`：监视指定网络接口的数据包，默认是第一个网卡 eth0（相当于直接使用 tcpdump 命令），any 表示任一接口
* `tcpdump host HOSTNAME`：监视指定主机的数据包
* `tcpdump PROTOTYPE`：监视指定协议的数据包
* `tcpdump tcp port 80 and host 10.158.113.161`：监视指定主机 10.158.113.161 上 HTTP 数据包。

> **Note**: 设置 tcp/udp + 指定端口，就是对于的网络协议。如 tcp port 443，就是抓取 HTTPS 数据包

### 2.1 选项
选项 | 描述 | 示例
-----|------|------
`-n` | 不把ip解析成域名 | 
`-i` | 抓取哪个网络接口的数据 | 
`port` | 指定抓取哪个端口的数据包 | `tcpdump tcp -i eth0 port 53`：抓取 DNS 包(DNS使用53端口)
`src` | 指定抓取来自哪个主机/IP地址的数据包 | `tcpdump tcp -i eth0 src host ${hostname}`
`dst` | 指定抓取发送到哪个主机/IP地址的数据包 | `tcpdump tcp -i eth0 dst host ${hostname}`
`-w` | 输出文件位置 | `tcp -i eth0 -w all.pcap`
`-v`和`-vv` | 详细显示指令执行过程 |
`-c` | 指定抓取几个数据包 | 


### 2.2 逻辑运算
操作 | 描述 | 示例
-----|------|------
`and` | 逻辑与 | `tcpdump tcp port 80 and host 10.123.0.2`：获取主机 10.230.0.2 接收和发出的数据包
`or` | 逻辑或 | `` 