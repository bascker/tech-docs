# traceroute
## 简介

用于路由跟踪，需要安装扩展包

```
$ yum -y install traceroute
```

## 案例

从内网 100.1.0.254/8 访问外网 10.158.113.161

```
$ traceroute 10.158.113.161
traceroute to 10.158.113.161 (10.158.113.161), 30 hops max, 60 byte packets
 1  lo0-100.BSTNMA-VFTTP-361.verizon-gni.net (100.0.0.1)  0.268 ms  0.238 ms  0.195 ms
 2  bogon (10.158.113.161)  1.289 ms  1.287 ms  1.262 ms

# 当前内网节点路由情况
$ ip r
default via 100.0.0.1 dev eth1         # eth1 的默认路由
100.0.0.0/8 dev eth1  proto kernel  scope link  src 100.1.0.254

$ ip a
eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether xxxxxxxxxxx brd ff:ff:ff:ff:ff:ff
    inet 100.1.0.254/8 brd 100.255.255.255 scope global dynamic eth1
       valid_lft 38181sec preferred_lft 38181sec
    inet6 xxxxxxxxxxx scope link
       valid_lft forever preferred_lft forever

# 外网路由节点
$ ip r
default via 10.158.113.1 dev eth1
10.158.113.0/24 dev eth1  proto kernel  scope link  src 10.158.113.211
100.0.0.0/8 dev eth0  proto kernel  scope link  src 100.0.0.1

$ ip a
eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:cf:5f:be brd ff:ff:ff:ff:ff:ff
    inet 10.158.113.211/24 brd 10.158.113.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fecf:5fbe/64 scope link
       valid_lft forever preferred_lft forever

# 外网路由节点做了一个 SNAT，将源地址为 100.0.0.0/8 的数据包改成自己的 ip
$ iptables -t nat -vnL
Chain POSTROUTING (policy ACCEPT 351 packets, 23617 bytes)
 pkts bytes target     prot opt in     out     source               destination
 4830  318K MASQUERADE  all  --  *      *       100.0.0.0/8          0.0.0.0/0
```

分析：从输出可知，从内网 100.1.0.254/8 连接 10.158.113.161 的路由情况为：_100.1.0.254 --&gt; 100.0.0.1 --&gt; 10.158.113.1 --&gt; 10.158.113.161_。即从内网节点 100.1.0.254 发送的数据包，经过默认路由 100.0.0.1 转发到外网路由节点, 该数据包匹配到外网路由节点的 iptables 规则，做了一次 SNAT，将该数据包的源地址 100.1.0.254 改为自己的ip\(10.158.113.211\)，然后通过路由 10.158.113.1 转发到 10.158.113.161