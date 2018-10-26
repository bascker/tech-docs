# losetup
## 简介
用于设定与控制循环设备\(loop 设备是一种伪设备,能使我们像块设备一样访问一个文件\)。一个 loop 设备必须要和一个文件进行连接才能被使用。如果这个文件包含有一个完整的文件系统，那么这个文件就可以像一个磁盘设备一样被 mount 起来。一般使用 _\`\*.iso\` _光盘镜像文件和 _\`\*.img\`_ 镜像文件,它们都包含有文件系统。

> loop：使用 mount 的方式，利用镜像文件，在第一层文件系统\(物理机本身的文件系统\)上再次挂载一个系统，称为 loop

## 操作
* losetup -d：卸载设备
* losetup -a：查看当前的回环设备

## 案例

命令显示

```
$ losetup
NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE
/dev/loop0         0      0         1  0 /var/lib/docker/devicemapper/devicemapper/data
/dev/loop1         0      0         1  0 /var/lib/docker/devicemapper/devicemapper/metadata
/dev/loop2         0      0         1  0 /var/lib/docker-bootstrap/devicemapper/devicemapper/data
/dev/loop3         0      0         1  0 /var/lib/docker-bootstrap/devicemapper/devicemapper/metadata
```

创建并挂载块设备

```
1. 创建空的磁盘镜像文件：1.44M的软盘
$ dd if=/dev/zero of=floppy.img bs=512 count=2880

2. 使用 losetup 将磁盘镜像文件虚拟成块设备
$ losetup /dev/loop1 floppy.img

3. 挂载块设备
$ mkdir test
$ mount /dev/loop0 test

4. 卸载loop设备
$ umount test
$ losetup -d /dev/loop1
```