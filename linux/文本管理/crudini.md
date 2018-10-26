# crudini
## 简介

用于操纵配置文件（ini或conf等）的变量，需要安装。

```
$ yum install -y crudini
```

## 操作
1.设置\(添加、更新\)：_crudini --**set **\[--existing\] config\_file section \[param\] \[value\]_

2.获取：_crudini --**get **\[--format=sh\|ini\] config\_file \[section\] \[param\]_

3.删除：_crudini --**del **\[--existing\] config\_file section \[param\]_

4.合并：_crudini --**merge **\[--existing\] config\_file \[section\]_

## 案例

```
$ vim test.conf
[DEFAULT]
user = admin
passwd = admin
port = 8088

[URL]
client = 127.0.0.1:8088
admin = 127.0.0.1:8080

# 设置：更新 section 为 DEFAULT 的 user 为 root
$ crudini --set test.conf DEFAULT user root

# 获取
$ crudini --get test.conf DEFAULT user
root

# 添加
$ crudini --set test.conf DEFAULT sex man
$ crudini --get test.conf DEFAULT sex
man

# 删除
$ crudini --get test.conf DEFAULT
user
passwd
port
sex

$ crudini --del test.conf DEFAULT sex
$ crudini --get test.conf DEFAULT
user
passwd
port

```