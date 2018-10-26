# Libvirt

## 简介
Libvirt 是一套开源的虚拟化管理工具，主要由 3 部分组成：

1. API库：支持主流编程语言，如C、Python、Ruby等
2. Libvirtd服务
3. 命令行工具 virsh

libvirt官网：[http://libvirt.org/?cm\_mc\_uid=73616920076614742707798&cm\_mc\_sid\_50200000=1488518533](http://libvirt.org/?cm_mc_uid=73616920076614742707798&cm_mc_sid_50200000=1488518533)

## virsh 命令

1.查看虚拟网络：_**virsh net-list**_

```
$ virsh net-list
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 br-data              active     yes           yes
 br-ex                active     yes           yes
 br-internal          active     yes           yes
 default              active     yes           yes
 jp-br-api            active     no            no
 jp-br-pxe            active     no            no
```

2.编辑网络：_**virsh net-edit**_

```
$ virst net-edit jp-br-pxe
<network>
  <name>jp-br-pxe</name>
  <uuid>f0aeed74-a178-46fa-9112-d3c1dddca7e1</uuid>
  <forward mode='bridge'/>
  <bridge name='jp-br-pxe'/>
  <virtualport type='openvswitch'/>
</network>
```

3.创建网络： _**virsh net-create **_和 _**virsh net-define**_

\(1\) _**virsh net-create**_

```
$ vim br-test.xml
<network>
  <name>br-test</name>
  <forward mode='bridge'/>
  <bridge name='br-test'/>
  <virtualport type='openvswitch'/>
</network>

$ virsh net-create br-test.xml
$ virsh net-list
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 br-test              active     no            no
```

> 注：使用 virsh net-create 创建的网络，无法使用 virsh net-start 或 virsh net-autostart 命令启动它

\(2\) _**virsh net-define**_

```
# 创建
$ net_name="auto-br-api"
# xml 同上
$ virsh net-define --file ${net_name}.xml
$ virsh net-start ${net_name}
$ virsh net-autostart ${net_name}
$ virsh net-list
virsh net-list
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 auto-br-api          active     yes           yes
```

4.删除网络： _**virsh net-destroy **_和 _** virsh net-undefine**_

_virsh net-destroy _只是让该网络不可用，但还是存在。彻底删除需要使用 _virsh net-undefine_

```
# 让网络不可用
$ virsh net-destroy auto-br-api
Network auto-br-api destroyed

$ virsh net-list --all
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 auto-br-api          inactive   yes           yes

# 彻底删除
$ virsh net-undefine auto-br-api
Network auto-br-api has been undefined
```

5.查看KVM虚机：_**virsh list --all**_

```
$ virsh list --all
  Id    Name                           State
----------------------------------------------------
 229   33-cdvm-9033                   running
 230   33-work1-8331                  running
 231   33-work2-8332                  running
 232   33-work3-8333                  running
 233   33-work4-8334                  running
 234   33-work5-8335                  running
 235   33-work6-8336                  running
 245   22-cdvm-9022                   running
 -     jp-cdvm-8001                   shut off
```

6.停止KVM虚机：_**virsh destroy Id/Name**_

```
$ virsh destroy 88
$ virsh list --all
 Id    Name                           State
----------------------------------------------------
 -     jp-controller1-6002            shut off
```

7.启动KVM虚机：_**virsh start Id/Name**_

8.删除KVM虚机：_**virsh undefine Id/Name**_

```
$ virsh undefine jp-controller1-6002
Domain jp-controller1-6002 has been undefined
```

9.获取虚机内存信息：virsh dommemstat Id/Name

```
$ virsh dommemstat instance-66d18e94-8312-472a-87d3-a0bac352c0de
actual 2097152
swap_in 0
swap_out 0
major_fault 349
minor_fault 2435591
unused 1936056
available 2056352
rss 469276
```

> 注：要想获取虚机的详细内存信息，必须使用带 virtio 驱动的镜像创建虚机，否则信息不详细。

## libvirt-python  的使用

1.官方文档：[https://libvirt.org/python.html](https://libvirt.org/python.html)

2.API官方：[http://libvirt.org/html/index.html?cm\_mc\_uid=73616920076614742707798&cm\_mc\_sid\_50200000=1488439995](http://libvirt.org/html/index.html?cm_mc_uid=73616920076614742707798&cm_mc_sid_50200000=1488439995)

### 安装

libvirt-python api 的使用需要进行 pip 安装

```
# 安装依赖
$ yum install -y gcc gcc-c++ ibxml2-devel gnutls-devel device-mapper-devel python-devel libnl-devel

# yum
$ yum install -y libvirt-python

# pip install libvirt-python
Collecting libvirt-python
  Downloading http://pypi.doubanio.com/packages/4d/22/b415c2b690.../libvirt-python-3.0.0.tar.gz (174kB)
    100% |████████████████████████████████| 174kB 1.5MB/s
Installing collected packages: libvirt-python
  Running setup.py install for libvirt-python ... done
Successfully installed libvirt-python-3.0.0
```

### libvirt API

1.open\(\)：获取 hypervisor 的连接

2.openReadOnly\(\)：同 open\(\)，获得连接后允许以普通用户身份执行命令

3.lookupByName\(\)：获取虚机实例对象

### 案例

官方案例

```
import libvirt
import sys

conn = libvirt.openReadOnly(None)
if conn == None:
    print 'Failed to open connection to the hypervisor'
    sys.exit(1)

try:
    dom0 = conn.lookupByName("Domain-0")
except:
    print 'Failed to find the main domain'
    sys.exit(1)

print "Domain 0: id %d running %s" % (dom0.ID(), dom0.OSType())
print dom0.info()
```

获取虚拟机信息

```
>>> import libvirt
>>>
>>> conn = libvirt.open("qemu:///system")
>>> conn
<libvirt.virConnect object at 0x7ff4d159d610>
>>>
>>> domain = conn.lookupByName("22-cdvm-9022")
>>> print "22-cdvm-9022: id %d running %s" % (domain.ID(), domain.OSType())
22-cdvm-9022: id 245 running hvm
>>>
>>> conn.close()
1
```

获取虚机内存信息

```
>>> import libvirt
>>> import time

>>> conn = libvirt.open("qemu:///system")
>>> for id in conn.listDomainsID():
....    domain = conn.lookupByID(id)
....    t1 = time.time()
....    c1 = int (domain.info()[4])
....    time.sleep(1);

....    t2 = time.time();
....    c2 = int (domain.info()[4])
....    c_nums = int (domain.info()[3])
....    usage = (c2-c1)*100/((t2-t1)*c_nums*1e9)
....    print "%s Cpu usage %f" % (domain.name(),usage)

# 输出
instance-00000002 Cpu usage 3.996507
```

创建 kvm 虚机的 python 脚本

```
$ vim empty-vm.py

#!/bin/python2.7
import commands
import os
import sys

# 接受2个参数
_name = sys.argv[1]        # 虚机名前缀
_port = sys.argv[2]        # vnc port
__name=_name+'-'+_port     # 最终虚机名称
print "create dir",  _name
commands.getoutput("cp -r /ssd/empty /ssd/%s"%_name)
print "running..."
_install = "virt-install --connect qemu:///system \
    --name %s --ram 8194 --vcpus 8 \
    --disk path=/ssd/%s/1.qcow2,format=qcow2,device=disk,bus=virtio \
    --disk path=/ssd/%s/2.qcow2,format=qcow2,device=disk,bus=virtio \
    --disk path=/ssd/%s/3.qcow2,format=qcow2,device=disk,bus=virtio \
    --disk path=/ssd/%s/4.qcow2,format=qcow2,device=disk,bus=virtio \
    --network network=jp-br-pxe,model=virtio \
    --network network=jp-br-pxe,model=virtio \
    --network network=br-ex,model=virtio \
    --network network=br-ex,model=virtio \
    --network network=jp-br-api,model=virtio \
    --network network=jp-br-api,model=virtio \
    --accelerate --vnc --vnclisten=0.0.0.0 --vncport=%s --import \
    --noautoconsole \
    --cpu host \
    --boot hd,network" %(__name, _name, _name, _name, _name, _port)
print commands.getoutput(_install)
```

创建完的虚机可以用 vnc viewer 连接，获取 ip

## FAQ

1.编写 python 脚本不上 qemu

场景：编写 python 脚本，使用 open\(\) 方法连接 qemu，报错_AttributeError: 'module' object has no attribute 'open' _，但直接在 python 中却没问题

```
$ vim libvirt.py
#!/usr/bin/env python

import libvirt

conn = libvirt.open("qemu:///system")
conn.close()

$ python libvirt.py
Traceback (most recent call last):
  File "libvirt.py", line 3, in <module>
    import libvirt
  File "/root/libvirt.py", line 5, in <module>
    conn = libvirt.open("qemu:///system")
AttributeError: 'module' object has no attribute 'open'
```