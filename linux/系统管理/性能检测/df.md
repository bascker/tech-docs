# df
## 简介

用于检查linux服务器的文件系统的磁盘空间占用情况。常结合 _**lsblk **_命令使用

* -h：方便阅读方式显示
* -T：显示文件系统类型

## 案例
```
$ df -hT
Filesystem              Type      Size  Used Avail Use% Mounted on
/dev/mapper/centos-root xfs        50G   50G  288M 100% /
devtmpfs                devtmpfs  3.9G     0  3.9G   0% /dev
tmpfs                   tmpfs     3.9G     0  3.9G   0% /dev/shm
tmpfs                   tmpfs     3.9G  8.5M  3.9G   1% /run
tmpfs                   tmpfs     3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/mapper/centos-home xfs        48G   33M   48G   1% /home
/dev/sda1               xfs       497M  164M  334M  33% /boot
tmpfs                   tmpfs     798M     0  798M   0% /run/user/0
/dev/sdb                xfs       100G   33M  100G   1% /sdb
```