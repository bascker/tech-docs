# dnsmasq
## 简介
一个小巧且方便地用于配置DNS和DHCP的工具，适用于小型网络，它提供了DNS功能和可选择的DHCP功能。还提供tftp服务，让网络启动\(PXE\)也得以实现

## 安装

```
$ yum install -y dnsmasq
$ systemctl enable dnsmasq
$ systemctl start dnsmasq
$ systemctl status dnsmasq
```

## 配置文件
dnsmasq的配置文件`/etc/dnsmasq.conf`，其内的部分配置项如下：

* _listen-address_：若想让安装有 dnsmasq 的主机为局域网提供默认 DNS 和 DHCP 服务，则应该修改 _listen-address=局域网地址_，如_listen-address=100.0.0.1_
* _dhcp-range_：设置 dhcp 的范围，如_100.0.0.2,100.254.254.254,12h_，表示从 100.0.0.2 开始分配，分到 100.254.254.254，其中 12h 表示该 dhcp 地址的租期是 12h，12h后会重新分配ip。**若不想重新分配，则可以设置租期为 infinite,该12h 为 infinite 即无限租期**
* _dhcp-host_：用于固定某台主机的ip。如：_dhcp-host=52:54:00:00:00:01,01-cdvm,100.1.0.254,12h_ 表示 dhcp 服务器只会将 100.1.0.254 这个 ip 分给 MAC 为 52:54:00:00:00:01 的主机并设置其主机名为 01-cdvm ，不会给别的主机
* _dhcp-lease-max_：默认租期，默认为 150
* _dhcp-sequential-ip_：顺序分配ip, 将_dhcp-sequential-ip_直接写入 /etc/dnsmasq.conf 即可