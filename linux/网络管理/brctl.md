# brctl
## 简介
用于 Linux Bridge 网桥的管理，需要安装

```
$ yum install -y bridge-utils
```

## 基础

* _brtcl show_：列出当前主机网桥
* _brctl addbr_：添加网桥
* _brctl delbr BR\_BNAME_：删除Linux bridge。需要先让网卡down，即 _ip link set BR\_BNAME down_

## 案例
添加网桥并配置 ip

```
$ brctl addbr br0
$ ip a add 192.168.0.0/24 dev br0
$ ip link set br0 up
```