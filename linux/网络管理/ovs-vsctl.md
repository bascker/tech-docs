# ovs-vsctl
## 简介
用于管理OpenVswitch桥。需要环境配置。如下：

```
$ yum install -y openvswitch
$ systemctl enable openvswitch
$ systemctl start openvswitch
$ systemctl status openvswitch
```

## 基础

* ovs-vsctl add-br OVS\_NAME：添加 ovs 网桥
* ovs-vsctl add-port DES\__BR SRC\_BR_：将网桥 _SRC\_BR _接到 DES\__BR  _上
* ovs-vsctl del-port：删除 port
* ovs-vsctl show：显示 ovs 网桥