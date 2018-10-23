# su
## 简介
用于切换用户的命令，以及指定用户来执行某命令。语法：
```
su 选项 用户
```

选项：

* “**-**” 或“**-l**”：登录并改变到所切换的用户环境
* “**-c**”：执行一个命令，然后退出所切换到的用户环境

> 若不加任何参数，则默认切换到 root 目录

## 案例
指定 zabbix 用户来执行命令
```
$ su - zabbix -c "/usr/sbin/zabbix_server -f -c /etc/zabbix/zabbix_server.conf"
```