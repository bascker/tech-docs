# useradd
## 简介

* 用于添加用户
* useradd UserName
* 选项：
  * _-m_：自动创建一个用户根目录
  * _-U_：是 --user-group 的缩写，表明创建用户组 XXX 的同时在该组下创建一个 XXX 用户
  * _-G_：是 --groups 的缩写，表明创建一个用户组

## 案例

```
# 创建用户和用户组 test，并将其归入 aaa 用户组
$ useradd -m -U test -G aaa
```