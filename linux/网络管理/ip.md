# ip
## 简介

* 和ifconfig类似，但是功能更加强大
* 利用 ip 命令添加的ip、网关等都是**临时生效**的, 重启失效
* **永久生效**：修改网卡配置文件，添加 **IPADDR、NETMASK、GATEWAY** 后重启网络

## 常用命令
### ip addr
用于对 ip 进行管理\(添加、删除等\)，可简写为 _ip a_

```
$ ip a show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:fd:d4:ad brd ff:ff:ff:ff:ff:ff
    inet 10.20.0.1/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fefd:d4ad/64 scope link
       valid_lft forever preferred_lft forever

$ ip a list eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:fd:d4:ad brd ff:ff:ff:ff:ff:ff
    inet 10.20.0.1/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fefd:d4ad/64 scope link
       valid_lft forever preferred_lft forever

$ ip addr add 172.16.9.10 dev eno16777728
$ ip addr del 172.16.9.10 dev eno16777728
```

### ip router

对路由/网关进行管理\(添加、删除等\), 可简写为 _ip r_

```
$ ip route show
$ ip route add 172.16.200.51 via 172.16.0.1 dev eno16777728    # 添加默认网关
$ ip route del 172.16.200.51
```

> 注：默认网关只能有 1 个

### ip link
网络设备管理

```
$ ip link show
$ ip link list
# 断开网卡
$ ip link set eno16777728 down
# 恢复网卡
$ ip link set eno16777728 up
# 修改网卡名称: 临时修改，要永久生效，还是要更改网卡配置文件
$ ip link set eno16777728 name eth0
```

> CentOS 下网卡配置目录：**/etc/sysconfig/network-scripts/**