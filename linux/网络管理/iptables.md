# iptables
## 简介
用于防火墙管理

## 选项

* -t：即--table，指定使用那个表。如 iptables -t nat 指定使用 nat 表
* -A：即--append, 添加一条新规则到规则链\(POSTROUTING,PREROUTING\)的最后
* -D：删除规则
* -s：即--source, 指定源地址
* -d：指定目的地址
* -p：指定协议类型
* --sport：源端口
* --dport：目的端口
* -j：即--jump, 指定动作。如 SNAT,DNAT,MASQUERADE\(源地址伪装\),DROP等
* -v：显示详细信息
* -n：以数字形式显示 ip，不加 -n 就显示主机名
* -L：列表形式显示
* --line-numbers：显示规则在规则链中的行号

## 基础
### 表名：4种表

* raw：高级功能，如网址过滤
* mangle：数据包修改\(QOS\)，用于实现服务质量
* nat：网络地址转换，用于网关路由器
* filter：包过滤，用于防火墙规则

### 规则链：5种

* INPUT：处理输入数据包
* OUTPUT：处理输出数据包
* PORWARD：处理转发数据包
* PREROUTING：DNAT
* POSTROUTING：SNAT

### 动作

* accept：接受
* DROP：丢弃
* REDIRECT：重定向，映射，代理
* SNAT
* DNAT
* MASQUERADE：IP伪装
* LOG：日志记录

## 案例
1.查看iptables nat 表的内容

```
$ iptables -t nat -vnL --line-numbers
```

2.删除 nat 表中的一个规则

```
$ iptables -vnL -t nat --line-numbers
Chain PREROUTING (policy ACCEPT 8616 packets, 380K bytes)
num   pkts bytes target     prot opt in     out     source               destination
1       78  4128 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:2280 to:100.22.0.241:80
2        0     0 DNAT       tcp  --  *      *       0.0.0.0/0            10.158.113.211       tcp dpt:2280 to:100.22.0.241:80

Chain INPUT (policy ACCEPT 67 packets, 7379 bytes)
num   pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 20 packets, 1400 bytes)
num   pkts bytes target     prot opt in     out     source               destination

Chain POSTROUTING (policy ACCEPT 32 packets, 2016 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1    41964 2734K MASQUERADE  all  --  *      *       100.0.0.0/8          0.0.0.0/0
2        0     0 MASQUERADE  all  --  *      *       100.0.0.0/8          0.0.0.0/0

# 删除 nat 表中 PREROUTING 链中编号为 2 的规则
$ iptables -t nat -D PREROUTING 2
```

3.SNAT

```
# 1. 更改所有来自 100.0.0.0/8 网段的数据包为当前机器的 ip
$ iptables -t nat -A POSTROUTING -s 100.0.0.0/8 -j MASQUERADE

# 2. 更改所有来自 192.168.1.0/24 的数据包的源ip地址为 100.0.0.2
$ iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j SNAT --to 100.0.0.2
```

4.DNAT

```
# 将访问目的地址 http://10.158.113.211:2280 的数据包转发到 100.22.0.241 的 80 监听端口
$ iptables -t nat -A PREROUTING -d 10.158.113.211 -p tcp --dport 2280 -j DNAT --to-destination 100.22.0.241:80
$ iptables -t nat -vnL
Chain PREROUTING (policy ACCEPT 74673 packets, 3205K bytes)
 pkts bytes target     prot opt in     out   source       destination
   33  1764 DNAT       tcp  --  *      *     0.0.0.0/0    0.0.0.0/0            tcp dpt:2280 to:100.22.0.241:80
    0     0 DNAT       tcp  --  *      *     0.0.0.0/0    10.158.113.211       tcp dpt:2280 to:100.22.0.241:80
```

> 注：系统是先进行DNAT，然后才进行路由及过虑的，因此使用的是 \`PREROUTING\` 规则链

5.配置外网路由

```
1. 开启路由转发功能
$ echo 1 >/proc/sys/net/ipv4/ip_forward     # 临时生效，重启失效
$ sysctl -a | grep "ip_forward"
net.ipv4.ip_forward = 1

# 设置永久生效
$ echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf
$ sysctl -p                                    # 使配置生效

2. 配置 SNAT
# (1)若是动态ip，则使用 MASQUERADE
$ iptables -t nat -A POSTROUTING -s 100.0.0.0/8 -j MASQUERADE

# (2)若是静态 ip，可使用
$ iptables -t nat -A POSTROUTING -s 100.0.0.0/8 -j SNAT --to-source 10.158.113.1

3.
```

> 问题：若有多个 vRouter 连接同一个 br 桥，则有可能造成 SNAT 失败，不通外网。因为同一个 br 桥上，同时存在多个 vRouter 提供路由转发功能，但若每个 vRouter 的 iptables nat 配置不一致，则可能造成随机挑选转发数据包的一个 vRouter 其上并没有对应的 SNAT，从而导致不通外网。**因此，一个桥上最好只存在一个提供路由转发Router**