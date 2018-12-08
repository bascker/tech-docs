# lsblk
## 一、简介
用于列出所有可用**块设备**(硬盘，闪存盘，CD-ROM)的信息，但不会列出RAM盘的信息。

## 二、案例
![lsblk](asset/lsblk.jpg)

参数解释：
* **NAME**: 块设备名
* **MAJ:MIN**：显示主要和次要设备号
* **RM**: 显示设备是否可移动设备。1 表示可移动，0 不可移动
* **SIZE**: 列出设备的容量大小信息
* **RO**: 表明设备是否为只读。1 表示只读，0 不是只读
* **TYPE**:显示块设备是否是磁盘或磁盘上的一个分区
* **MOUNTPOINT**: 指出设备挂载的挂载点

## 三、FAQ
### 3.1 磁盘重复挂载导致虚机重启失败
场景：磁盘分区挂载后，某天虚拟机下点重启后，启动失败，报磁盘重复挂载的错误。

原因：磁盘重复挂载了
```
# 查看磁盘挂载情况
$ lsblk
xvde                202:64      0     200G      disk
|- xvde1            202:65      0     200G      part
   |- vg01-data     253:1       0     89G       lvm       /opt
   |- vg01-log      253:2       0     109G      lvm       /opt/logs

# 查看 /etc/fstab 文件
$ cat /etc/fstab
/dev/xvde1                /opt        ext4      defaults  1   1
/dev/mapper/vg01-data     /opt        ext4      defaults  0   0
/dev/mapper/vg01-log      /opt/logs   ext4      defaults  0   0
```
可以看到 /dev/xvde1 和 /dev/mapper/vg01-data 同时挂载在 /opt 下。

Note：
* /dev/xvde 是虚拟机的磁盘
* /dev/xvde1 是从 /dev/xvde 中格式化后的分区
* vg01-data 和 vg01-log 是从 /dev/xvde1 创建的卷组 vg01 中创建出来的逻辑卷 lvm

解决：删除重复挂载的磁盘
```
sed -i "/\/dev\/xvde1/d" /etc/fstab
```
