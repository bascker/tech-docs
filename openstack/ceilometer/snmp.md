# Ceilometer + SNMP 监控物理机
## snmp简介
snmp 即简单网络管理协议\(simple network management protocol\)，是**基于TCP/IP协议族**的网络管理标准，是一种在IP网络中管理网络节点\(如服务器、工作站、路由器、交换机等\)的标准协议。用以监测连接到网络上的设备是否有任何引起管理上关注的情况

## 配置 snmp
1.安装 snmp：在各被监控结点上安装
```
$ yum install -y net-snmp net-snmp-utils
$ systemctl enable snmpd
$ systemctl start snmpd
$ systemctl status snmpd
```

2.测试 snmp 是否正常：使用 _**snmpwalk **_命令
```
# snmpwalk：用于获取系统各种信息
# -v：指定 SNMP 协议的版本号，取值为 1, 2c, 3
# -c：指定 snmpd.conf 文件中定义的 community 名
$ snmpwalk -v 2c -c public 10.20.0.5
SNMPv2-MIB::sysDescr.0 = STRING: Linux computer1-33 3.10.0-229.el7.x86_64 #1 SMP Fri Mar 6 11:36:42 UTC 2015 x86_64
SNMPv2-MIB::sysObjectID.0 = OID: NET-SNMP-MIB::netSnmpAgentOIDs.10
...
SCTP-MIB::sctpValCookieLife.0 = Gauge32: 0 milliseconds
SCTP-MIB::sctpMaxInitRetr.0 = Gauge32: 0

# 也可以指定 oid 获取对应数据: 获取 oid 为 .1.3.6.1.2.1.2.2.1.11(接口收到的数据包个数) 的值
$ snmpwalk -v 2c -c public 10.20.0.5 .1.3.6.1.2.1.2.2.1.11
IF-MIB::ifInUcastPkts.1 = Counter32: 25632319
IF-MIB::ifInUcastPkts.2 = Counter32: 7590903
IF-MIB::ifInUcastPkts.3 = Counter32: 780764
IF-MIB::ifInUcastPkts.4 = Counter32: 10428
IF-MIB::ifInUcastPkts.5 = Counter32: 4041
IF-MIB::ifInUcastPkts.6 = Counter32: 55625361
IF-MIB::ifInUcastPkts.7 = Counter32: 261
IF-MIB::ifInUcastPkts.8 = Counter32: 18784
IF-MIB::ifInUcastPkts.9 = Counter32: 8370693
IF-MIB::ifInUcastPkts.10 = Counter32: 14000
IF-MIB::ifInUcastPkts.11 = Counter32: 55624932
IF-MIB::ifInUcastPkts.12 = Counter32: 55625157
IF-MIB::ifInUcastPkts.13 = Counter32: 16
IF-MIB::ifInUcastPkts.14 = Counter32: 1706152
IF-MIB::ifInUcastPkts.16 = Counter32: 18784
IF-MIB::ifInUcastPkts.17 = Counter32: 0
IF-MIB::ifInUcastPkts.18 = Counter32: 0
IF-MIB::ifInUcastPkts.19 = Counter32: 0
IF-MIB::ifInUcastPkts.20 = Counter32: 461
```

> OID 概念：即 snmp 协议采集到的某个资源数据，对应 ceilometer 中的某个 meter 项

3.配置 /etc/snmp/snmpd.conf
```
$ vi /etc/snmp/snmpd.conf
# Make at least  snmpwalk -v 1 localhost -c public system fast again.
#       name           incl/excl     subtree         mask(optional)
#view    systemview    included   .1.3.6.1.2.1.1
view    systemview    included   .1                  80

####
# Finally, grant the group read-only access to the systemview view.
#       group          context sec.model sec.level prefix read   write  notif
access  notConfigGroup ""      any       noauth    exact  systemview all none
```

4.配置 ceilometer 的 pipeline.yml
```
$ vim pipeline.yml
sources:
    ...
    - name: hardware_source
          interval: 300
          meters:
              - "hardware.*"
          resources:
              - snmp://10.20.0.5
              - snmp://10.20.0.6
              - snmp://10.20.0.7
          sinks:
              - meter_sink
 sinks:
     - name: meter_sink
       transformers:
       publishers:
           - notifier://
     - name: cpu_sink
     ...
```

5.重启 ceilometer 服务
```
$ ceilometer meter-list | grep hardware
hardware.cpu.load.15min    | gauge      | process   | 10.20.0.5    | None       | None  |
hardware.cpu.load.15min    | gauge      | process   | 10.20.0.6    | None       | None  |
hardware.cpu.load.15min    | gauge      | process   | 10.20.0.7    | None       | None  |

...

$ ceilometer resource-list
...
| 10.20.0.5.bond0       | hardware  | None   | None  |
| 10.20.0.6.bond0       | hardware  | None   | None  |
| 10.20.0.7.bond0       | hardware  | None   | None  |
```

## 附录：snmpd.conf
snmp 的配置文件 /etc/snmp/snmpd.conf，配置分如下 4 步骤：

1.安全名定义：将名为 public  的 community 纳入名为 notConfigUser 的安全名内
```
####
# First, map the community name "public" into a "security name"

#       sec.name       source        community
com2sec notConfigUser  default       public
```

2.安全组定义：将 notConfigUser 添加到安全组 notConfigGroup  中
```
####
# Second, map the security name into a group name:
#       groupName      securityModel securityName
group   notConfigGroup v1            notConfigUser
group   notConfigGroup v2c           notConfigUser
```

3.定义 snmp 爬取信息的范围：创建一个 view，设置该 view 下 snmpwalk 可以获取的信息范围
```
# Third, create a view for us to let the group have rights to:
# Make at least  snmpwalk -v 1 localhost -c public system fast again.
#       name           incl/excl     subtree              mask(optional)
view systemview        included      .1.3.6.1.2.1.1
view systemview        included      .1.3.6.1.2.1.25.1.1
```

> 值为 included 且 subtree 值为 .1.3.6.1.2.1.1 表示可以获取 OID 为 .1.3.6.1.2.1.1.\* \(系统参数：如基本信息，机器名等\) 的所有信息。**可以设置 subtree 为 .1**，**即获取所有信息**

4.组权限定义：定义 notConfigGroup 组对 systemview  的操作权限
```
####
# Finally, grant the group read and write access to the systemview view.

#       group          context sec.model sec.level prefix read       write  notif
access  notConfigGroup ""      any       noauth    exact  systemview all    none
```

## ceilometer 对  snmp 监控项的定义
我们在 pipeline.yaml 中可以定义 ceilometer 去收集云下资源的哪些信息，那么这些在 pipeline.yaml 中定义的信息在源码中如何体现的呢？那就是 ceilometer 源码目录下的 **entry_points.txt**

在源码安装路径 /usr/lib/python2.7/site-packages/ceilometer-2015.1.1-py2.7.egg-info 中看到 entry_points.txt_文件，该文件记录了各服务的采集项.
```
$ vim entry_points.txt
# ceilometer-notification 可以收集的信息
[ceilometer.notification]
...
role_assignment = ceilometer.identity.notifications:RoleAssignment
instance_flavor = ceilometer.compute.notifications.instance:InstanceFlavor
volume_crud = ceilometer.volume.notifications:VolumeCRUD
...

# ceilometer-compute
[ceilometer.poll.compute]
disk.write.requests.rate = ceilometer.compute.pollsters.disk:WriteRequestsRatePollster
...
cpu_util = ceilometer.compute.pollsters.cpu:CPUUtilPollster
network.incoming.bytes.rate = ceilometer.compute.pollsters.net:IncomingBytesRatePollster
network.incoming.packets = ceilometer.compute.pollsters.net:IncomingPacketsPollster
disk.write.bytes.rate = ceilometer.compute.pollsters.disk:WriteBytesRatePollster
memory.usage = ceilometer.compute.pollsters.memory:MemoryUsagePollster
...


# ceilometer-central
[ceilometer.poll.central]
hardware.memory.total = ceilometer.hardware.pollsters.memory:MemoryTotalPollster
storage.cluster.pool.volume.free = ceilometer.volume.pollsters:VolumeFreePollster
storage.cluster.pool.free = ceilometer.volume.pollsters:PoolFreePollster
hardware.cpu.load.15min = ceilometer.hardware.pollsters.cpu:CPULoad15MinPollster
...
```

## SNMP 常用OID
ceilometer物理机计量项与 snmp oid 对应关系
### 磁盘信息

| OID | 描述 | ceilometer meter | 请求方式 |
| :--- | :--- | :--- | :--- |
| .1.3.6.1.4.1.2021.9.1.6 | dskTotal，磁盘/分区总大小 | hardware.disk.size.total | walk |
| .1.3.6.1.4.1.2021.9.1.7 | dskAvail，可用磁盘大小 | hardware.disk.size.avail | walk |
| .1.3.6.1.4.1.2021.9.1.8 | dskUsed，已使用磁盘大小 | hardware.disk.size.used | walk |

### 案例
对比 OID 和 ceilometer 计量项：ceilometer 中的 hardware.disk.size.total 对应 snmp 的 OID 就是 .1.3.6.1.4.1.2021.9.1.6\(dskTotal\)
```
$ snmpwalk -v 2c -c public com1 .1.3.6.1.4.1.2021.9.1.6
UCD-SNMP-MIB::dskTotal.1 = INTEGER: 42307396

$ ceilometer sample-list -m hardware.disk.size.total
+---------------------------------+--------------------------+-------+------------+------+---------------------+
| com1./dev/mapper/rootvol        | hardware.disk.size.total | gauge | 42307396.0 | KB   | 2016-12-16T08:13:46 |
+---------------------------------+--------------------------+-------+------------+------+---------------------+
```

SNMP 关于磁盘检测的配置
```
$ vim /etc/snmp/snmpd.conf
###############################################################################
# disk checks
#

# The agent can check the amount of available disk space, and make
# sure it is above a set limit.

# disk PATH [MIN=100000]
#
# PATH:  mount path to the disk in question.
# MIN:   Disks with space below this value will have the Mib's errorFlag set.
#        Default value = 100000.

# Check the / partition and make sure it contains at least 10 megs.

#disk / 10000

# % snmpwalk -v 1 localhost -c public .1.3.6.1.4.1.2021.9
# enterprises.ucdavis.diskTable.dskEntry.diskIndex.1 = 0
# enterprises.ucdavis.diskTable.dskEntry.diskPath.1 = "/" Hex: 2F
# enterprises.ucdavis.diskTable.dskEntry.diskDevice.1 = "/dev/dsk/c201d6s0"
# enterprises.ucdavis.diskTable.dskEntry.diskMinimum.1 = 10000
# enterprises.ucdavis.diskTable.dskEntry.diskTotal.1 = 837130
# enterprises.ucdavis.diskTable.dskEntry.diskAvail.1 = 316325
# enterprises.ucdavis.diskTable.dskEntry.diskUsed.1 = 437092
# enterprises.ucdavis.diskTable.dskEntry.diskPercent.1 = 58
# enterprises.ucdavis.diskTable.dskEntry.diskErrorFlag.1 = 0
# enterprises.ucdavis.diskTable.dskEntry.diskErrorMsg.1 = ""
```

**disk / 10000** ：表示对挂载到根目录大小在 10M 以上的磁盘进行检测。如案例检测的就是根目录的磁盘
```
$ df -hT
Filesystem                 Type      Size  Used Avail Use% Mounted on
/dev/mapper/rootvol        xfs       281G   35G  246G  13% /
```

> snmpd.conf 中还可以对很多监控项\(如CPU，负载，内存等\)进行检测，自行查看并按需配置即可

## 参考文献
1. SNMP监控一些常用OID的总结：[http://www.cnblogs.com/aspx-net/p/3554044.html](http://www.cnblogs.com/aspx-net/p/3554044.html)
2. SNMP配置文件：[http://www.net-snmp.org/docs/man/snmpd.conf.html](http://www.net-snmp.org/docs/man/snmpd.conf.html)