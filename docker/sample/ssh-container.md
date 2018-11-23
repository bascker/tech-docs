# SSH容器
## 一、简介
默认情况下创建的容器是无法进行 SSH 远程登录的

## 二、实现
基于ubuntu14.04基础镜像创建SSH容器。
```
1.安装 openssh-server
$ apt-get install openssh-server

2.创建 sshd 运行 pid 目录
$ mkdir /var/run/sshd

3.修改配置：允许 root 用户使用密码登录
$ vi /etc/ssh/sshd_config
# PermitRootLogin without-password            默认值
PermitRootLogin yes

4.修改root用户密码
$ echo "root:123456" | chpasswd

5.启动服务
$ nohup /usr/sbin/sshd -D &
$ ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  18228  2104 ?        Ss   05:44   0:00 /bin/bash
root       683  0.0  0.0  61376  3056 ?        S    05:55   0:00 /usr/sbin/sshd -D

6.添加测试用户
$ useradd admin
$ echo "admin:admin" | chpasswd
```

测试宿主机是否可以 SSH 远程登录容器
```
$ ssh 172.17.0.3
root@172.17.0.3's password:
Welcome to Ubuntu 14.04.5 LTS (GNU/Linux 3.10.0-327.36.1.el7.x86_64 x86_64)

 * Documentation:  https://help.ubuntu.com/
Last login: Tue Mar 28 06:05:46 2017 from 172.17.0.1
root@ubuntu:~# exit
logout
Connection to 172.17.0.3 closed.

$ ssh admin@172.17.0.3
admin@172.17.0.3's password:
Welcome to Ubuntu 14.04 LTS (GNU/Linux 4.4.0-62-generic x86_64)
...
$ ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  18228  2104 ?        Ss+  05:44   0:00 /bin/bash
root       683  0.0  0.0  61376  3068 ?        S    05:55   0:00 /usr/sbin/sshd -D
root       738  0.1  0.0  95100  3888 ?        Ss   06:02   0:00 sshd: admin [priv]
admin      749  0.0  0.0  95100  1868 ?        S    06:02   0:00 sshd: admin@pts/0
admin      750  0.0  0.0   4440   648 pts/0    Ss   06:02   0:00 -sh
admin      752  0.0  0.0  15560  1168 pts/0    R+   06:02   0:00 ps aux
```