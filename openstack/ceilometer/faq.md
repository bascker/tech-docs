# FAQ

## 1.使用 _**ceilometer meter-list **_仅显示一部分计量项
**场景**：使用 ceilometer meter-list 查看计量项，发现仅仅只显示了云上资源的计量项，而云下资源的未显示。查看数据库却发现数据库中存有云下的计量项

**原因**：ceilometer.conf 文件的配置中 _**\[api\] **_部分的默认值_** default\_api\_return\_limit = 100**_ 太小，显示不全

```
$ cat ceilometer.conf
[api]

#
# From ceilometer
#

# Toggle Pecan Debug Middleware. (boolean value)
#pecan_debug = false

# Default maximum number of items returned by API request. (integer value)
# Minimum value: 1
#default_api_return_limit = 100
```

**解决**：修改配置文件，将 _**default\_api\_return\_limit  **_取值加大

## 2.ceilometer 对接 mongodb 时，ceilometer-collector 出错

**场景**：ceilometer 使用 mongodb 作为后端数据库时，ceilometer-collector.log 中报错 "no master"

**原因**：当前 mongodb 的集群为副本集群，ceilometer.conf 中配置 mongodb 接入点不是 mongodb 的 master 节点，非 master 无法对数据进行读写操作，因此报错

**解决**：修改配置，将接入点改为 mongodb 的 master 节点

## 3.ceilometer 监控云上资源获取不到 memory.usage 的监控项

**场景**：ceilometer 监控云上资源时，使用 ceilometer meter-list 获取不到 memory.usage 信息

**原因**：当前环境中，所有的虚机全部是基于 cirros 镜像启动的，而该镜像内不包含 virtio 驱动，导致无法获取到 VM 内存的信息。且日志报错如下

```
$ cat ceilometer-polling.log
INFO ceilometer.agent.manager [-] Polling pollster network.outgoing.packets in the context of meter_source
INFO ceilometer.agent.manager [-] Polling pollster memory.usage in the context of meter_source
WARNING ceilometer.compute.pollsters.memory [-] Cannot inspect data of MemoryUsagePollster for 45ed1104-71e5-4135-9dbf-a76ad6b4c43d, non-fatal reason: Failed to inspect memory usage of instance <name=instance-00000002, id=45ed1104-71e5-4135-9dbf-a76ad6b4c43d>, can not get info from libvirt.
```

对比环境：使用cirros创建的云实例

```
$ virsh list
 Id    Name                           State
----------------------------------------------------
 2     instance-00000002              running

# 内存信息显示不全
$ virsh dommemstat instance-00000002
actual 524288
rss 147396

# 通过 libvirt api 来查看
$ python
>>> import libvirt
>>>
>>> conn = libvirt.open("qemu:///system")
>>> domainIDs = conn.listDomainsID()
>>> domainIDs
[2]
>>>
>>> id = domainIDs[0]
>>> id
2
>>> domain = conn.lookupByID(id)
>>>
>>> domain
<libvirt.virDomain object at 0x7f6a8f197690>
>>>
>>> domain.setMemoryStatsPeriod(10)
0
>>> meminfo = domain.memoryStats()
>>>
>>> meminfo
{'actual': 524288L, 'rss': 147396L}
```

使用带 virtio 驱动的镜像创建的云实例

```
$ virsh list
 Id    Name                           State
----------------------------------------------------
 2     instance-66d18e94-8312-472a-87d3-a0bac352c0de running
 31    instance-5ae1d5a0-0a04-4d0f-882b-e879b7ac22f2 running
 33    instance-af31d700-613e-4219-850a-33c3eb1323e1 running
 41    instance-54e61959-4984-4094-ad69-4f0dea6d4638 running
 42    instance-0ce9d855-ce2f-4d6f-9660-5efed7499256 running

$ virsh dommemstat instance-66d18e94-8312-472a-87d3-a0bac352c0de
actual 2097152
swap_in 0
swap_out 0
major_fault 349
minor_fault 2366763
unused 1936312
available 2056352
rss 469276
```

**解决**：使用带 virtio 的镜像创建虚机，即可

```
$ glance image-create --name centos7 --progress \
                      --disk-format iso --container-format bare --visibility public --progress \
                      --file ./CentOS-7-x86_64-Minimal-1511.iso
$ glance image-list
+--------------------------------------+---------+
| ID                                   | Name    |
+--------------------------------------+---------+
| 68072422-cbb0-4c27-9593-591423f0e7e1 | centos7 |
+--------------------------------------+---------+

$ nova boot --flavor m1.tiny --image centos7 virtio
$ nova list
+--------------------------------------+--------+--------+------------+-------------+---------------------------+
| ID                                   | Name   | Status | Task State | Power State | Networks                  |
+--------------------------------------+--------+--------+------------+-------------+---------------------------+
| 371974c5-0d5b-4f7a-8f5d-49aa9122245a | virtio | ACTIVE | -          | Running     | demo-ovn-net=192.168.1.11 |
+--------------------------------------+--------+--------+------------+-------------+---------------------------+

$ ceilometer meter-list | grep memory | grep -v hard
| memory.resident                          | gauge      | MB        | 371974c5-0d5b-4f7a-8f5d-49aa9122245a                                  | c7da6129403046f0aba48e5c597749b9 | 6c161e993e6d49198eb12c00edfcacc8 |
| memory.resident                          | gauge      | MB        | 45ed1104-71e5-4135-9dbf-a76ad6b4c43d                                  | c7da6129403046f0aba48e5c597749b9 | 6c161e993e6d49198eb12c00edfcacc8 |
| memory.resident                          | gauge      | MB        | 6a8df2f0-b03c-4c7a-833d-3ef0ba7a1e88                                  | c7da6129403046f0aba48e5c597749b9 | 6c161e993e6d49198eb12c00edfcacc8 |
| memory.resident                          | gauge      | MB        | ee90e642-2219-4d92-abdd-e25c594fd6fc                                  | c7da6129403046f0aba48e5c597749b9 | 6c161e993e6d49198eb12c00edfcacc8 |
| memory.usage                             | gauge      | MB        | 371974c5-0d5b-4f7a-8f5d-49aa9122245a                                  | c7da6129403046f0aba48e5c597749b9 | 6c161e993e6d
```

> 要获取VM内存使用详细信息，VM中需要安装virtio驱动并且支持memballoon。Linux一般都会包含该驱动\(通过 lsmod \| grep virtio 查看\)，但是windows的virtio驱动需要自己在镜像中安装。

## 4.如何对 ceilometer 的数据进行自定义处理？

**场景**：新版本中 ceilometer 对 memory.usage 的获取默认是取实际使用多少 MB 的内存，而不是百分比。

**解决**：在 pipeline.yaml 中定义 memory 的数据处理流程

```
# 定义 polling 获取的 memory.usage 数据要经过 memory_sink 的处理，将结果公布到 memory.util
$ vim pipeline.yaml
---
sources:
    ...
    - name: memory_source
      interval: 30
      meters:
          - "memory.usage"
      sinks:
          - memory_sink
sinks:
    ...
    - name: memory_sink
      transformers:
          - name: "arithmetic"
            parameters:
                target:
                    name: "memory.util"
                    unit: "%"
                    type: "gauge"
                    expr: "100 * $(memory.usage) / $(memory.usage).resource_metadata.flavor.ram"
      publishers:
          - notifier://

# 测试
$ ceilometer meter-list
...
| memory.resident     | gauge      | MB  | cd4a2efa-259a-4861-8317-792aeca2086c        | 10741b1b706d4057bc62f019497c8620 | e5e66c5b08e341a3a2bcee747a950e36 |
| memory.usage        | gauge      | MB  | cd4a2efa-259a-4861-8317-792aeca2086c        | 10741b1b706d4057bc62f019497c8620 | e5e66c5b08e341a3a2bcee747a950e36 |
| memory.util         | gauge      | %   | cd4a2efa-259a-4861-8317-792aeca2086c        | 10741b1b706d4057bc62f019497c8620 | e5e66c5b08e341a3a2bcee747a950e36 |

$ ceilometer statistics -m memory.util
+--------+----------------------------+----------------------------+------+------+------+------+-------+----------+----------------------------+----------------------------+
| Period | Period Start               | Period End                 | Max  | Min  | Avg  | Sum  | Count | Duration | Duration Start             | Duration End               |
+--------+----------------------------+----------------------------+------+------+------+------+-------+----------+----------------------------+----------------------------+
| 0      | 2017-03-18T09:57:15.714000 | 2017-03-18T09:57:25.871000 | 42.0 | 42.0 | 42.0 | 42.0 | 1     | 0.0      | 2017-03-18T09:57:25.871000 | 2017-03-18T09:57:25.871000 |
+--------+----------------------------+----------------------------+------+------+------+------+-------+----------+----------------------------+----------------------------+
```

上面是直接使用 memory.usage 来处理的，也可以通过 memory.usage + memory.resident 一起处理：

```
$ vim pipeline.yaml
...
sinks:
    ...
    - name: memory_sink
      transformers:
          - name: "arithmetic"
            parameters:
                target:
                    name: "memory.util"
                    unit: "%"
                    type: "gauge"
                    expr: "100 * $(memory.usage) / $(memory.resident)"
      publishers:
          - notifier://

$ ceilometer statistics -m memory.util
+--------+----------------------------+----------------------------+------+------+------+------+-------+----------+----------------------------+----------------------------+
| Period | Period Start               | Period End                 | Max  | Min  | Avg  | Sum  | Count | Duration | Duration Start             | Duration End               |
+--------+----------------------------+----------------------------+------+------+------+------+-------+----------+----------------------------+----------------------------+
| 0      | 2017-03-18T09:49:40.734000 | 2017-03-18T09:55:56.468000 | 42.0 | 42.0 | 42.0 | 42.0 | 1     | 0.0      | 2017-03-18T09:55:56.468000 | 2017-03-18T09:55:56.468000 |
+--------+----------------------------+----------------------------+------+------+------+------+-------+----------+----------------------------+----------------------------+
```

## 5.ceilomete meter-list 无 hardware.disk.\* 计量项

**场景**：使用`ceilometer meter-list` 命令查看不到`hardware.disk.*` 的计量项

**原因**：使用 snmpwalk 命令爬取 disk 的 数据，显示无实例拥有该 OID 值，连 snmp 都获取不到，自然 ceilometer 无此数据了。使用命令`df -hT` 查看，显示磁盘情况如下：

```
$ df -hT
Filesystem                 Type      Size  Used Avail Use% Mounted on
/dev/dm-20                 xfs        10G  306M  9.7G   3% /
...
/dev/mapper/rootvol        xfs       281G  8.0G  273G   3% /etc/hostname
```

主机磁盘挂载目录是 `/etc/hostname`, 而本人配置磁盘扫描目录却是 `/etc/hosts`，因此扫描不到数据

**解决**：修改 `rootvol`的正确挂载点，或修改 snmp 扫描目录