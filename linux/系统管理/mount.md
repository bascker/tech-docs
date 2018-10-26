# mount
## 简介
* 用于加载文件系统到指定的加载点
* 常用选项
  * **-V**: 显示程序版本
  * **-v**: 冗长模式，输出指令执行的详细信息
  * **-r**: 冗长模式，输出指令执行的详细信息
  * **-a**: 加载文件 /etc/fstab 中描述的所有文件系统

## 案例
```
$ mount -v -t nfs -o vers=4,nfsvers=4 nfs-server:/home/nfs /home/nfs
mount.nfs: timeout set for Thu Oct 20 17:24:23 2016
mount.nfs: trying text-based options 'vers=4,nfsvers=4,addr=10.158.113.160,clientaddr=10.158.113.161'
```