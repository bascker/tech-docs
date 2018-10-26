# PV\(Physical Volume\)系列命令
## 简介
用于管理物理卷相关的命令。

1. **pvscan**：检查当前系统是否存在 pv 卷
2. **pvcreate**：用于将物理硬盘**分区**初始化为物理卷，以便LVM使用。**要求**该磁盘分区没有挂载文件系统
3. **pvdisplay**：查看创建的物理卷
4. **pvs**：查看所有 pv 信息

## 案例
**创建 pv 卷**

```
$ lsblk
NAME            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
...
sdb               8:16   0   1.8T  0 disk
├─sdb1            8:17   0   1.8T  0 part
└─sdb2            8:18   0     5G  0 part
sdc               8:32   0   1.8T  0 disk
└─sdc1            8:33   0   1.8T  0 part
...

# 将分区初始化为 pv 卷
$ pvcreate /dev/sdb1
WARNING: xfs signature detected on /dev/sdb1 at offset 0. Wipe it? [y/n]: y
  Wiping xfs signature on /dev/sdb1.
  Physical volume "/dev/sdb1" successfully created

# 扫描 pv 卷
$ pvscan
    PV /dev/sda2   VG centos   lvm2 [1.82 TiB / 60.00 MiB free]
    PV /dev/sdb1               lvm2 [1.81 TiB]
    Total: 2 [3.63 TiB] / in use: 1 [1.82 TiB] / in no VG: 1 [1.81 TiB]

# 显示信息
$  pvdisplay /dev/sdb1
  "/dev/sdb1" is a new physical volume of "1.81 TiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb1
  VG Name
  PV Size               1.81 TiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               UfjdMJ-Mv6H-WVx1-qajD-75hQ-lE6o-2pesLe
```

**格式化磁盘、挂载磁盘**

```
1. 查看当前的文件系统 df -hT
$ df -hT
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/centos-root xfs        50G   50G   84M 100% /
devtmpfs                devtmpfs  911M     0  911M   0% /dev
tmpfs                   tmpfs     921M     0  921M   0% /dev/shm
tmpfs                   tmpfs     921M  8.6M  912M   1% /run
tmpfs                   tmpfs     921M     0  921M   0% /sys/fs/cgroup
/dev/mapper/centos-home xfs        48G   33M   48G   1% /home
/dev/sda1               xfs       497M  164M  334M  33% /boot
tmpfs                   tmpfs     185M     0  185M   0% /run/user/0

从上可以看到，目前的文件系统有哪些。

2. 查看添加的硬盘：在/dev目录下，最首先只有一块硬盘，当添加后会多出一块 sdb
$ ls -al /dev/ | grep sd
brw-rw----   1 root disk      8,   0 Sep 12 09:52 sda
brw-rw----   1 root disk      8,   1 Sep 12 09:52 sda1
brw-rw----   1 root disk      8,   2 Sep 12 09:52 sda2
brw-rw----   1 root disk      8,  16 Sep 12 10:10 sdb         # 新加银盘

注：要让 sdb 可用，就得看 df -hT 上是否有其显示

3. 初始化分区sdb为物理卷pv
$ pvcreate /dev/sdb
$ pvdisplay

4. 初始化磁盘为 xfs 文件系统
$ mkfs.xfs /dev/sdb

5. 挂载磁盘
$ mkdir /sdb
$ mount /dev/sdb /sdb/         # 将该卷挂载到 /sdb/ 下

6. 查看结果
$ df -hT
Filesystem              Type      Size  Used Avail Use% Mounted on
.....
/dev/sdb                xfs       100G   33M  100G   1% /sdb
```

> 注：
>
> 1.  这种挂盘，仅仅是临时的挂盘，一旦系统重启，盘就被卸载了，只能重新挂载
> 2. 若sdb目录下本来就存在文件或目录，当挂盘后，就进入sdb下执行 ll 看到的就只是磁盘 /dev/sdb 下保存的数据，而看不到原本在sdb下的数据。若想重新看到sdb本来保存的数据，就得重启系统\(或卸载磁盘\)