# sudo
## 简介

* 能够限制用户只在某台主机上运行某些命令
* 提供了丰富的日志，详细地记录了每个用户干了什么
* 能够将日志传到中心主机或者日志服务器
* sudo 的配置文件是 **sudoers **文件，允许系统管理员集中的管理用户的使用权限和使用的主机
* 默认是在 _/etc/sudoers_，权限为 _**0440**_
* **visudo **命令：利用 visudo 命令编辑 sudoers 文件会**帮助校验文件配置**是否正确，如果不正确，在保存退出时就会提示

## 案例
```
$ vim /etc/sudoers
test ALL=(ALL) ALL                            # 允许普通用户 test 执行 root 权限的所有命令
%aaa ALL=(ALL) NOPASSWD: ALL                   # 允许 aaa 用户组下的成员不输入该用户的密码的情况下使用所有命令
%aaa ALL=(root) NOPASSWD: /usr/sbin/useradd    # 允许 aaa 用户组下的成员不输入该用户的密码的情况下执行 useradd 命令
```

> 添加了权限限制的用户，在执行限制的操作时，需要加上 sudo. 如 sudo useradd test2