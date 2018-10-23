# yum
## 简介

centos下的软件包管理命令。\(unbuntu下是 apt-get\)

## 操作

* yum -y upgrade：升级系统所有包，不改变软件和系统设置，不改变内核
* yum -y update：升级系统所有包，改变设置和内核
* yum -y remove：移除软件，以及其依赖包
  > 若只想移除某个rpm，替换成新版本的包，而不会移除该包的依赖，则应该使用 rpm -U 来更新
* yum **list **SOFT\_NAME：查看 yum源 中提供的软件
* yum **search **PKG\_NAME：查看 repo 中的软件
* yum install **--downloadonly** **--downloaddir**=/tmp libaio：仅下载libaio不安装，且将软件下载到 /tmp 下
* yum repolist：查看当前系统中存在的仓库

## 扩展工具

* **creatrepo**：用于创建 yum 源
  * **createrepo --update .**：更新本地 yum 源
* **reposync**：yum 源同步命令
  * _**reposync -n .**_ ：只获取当前yum源中没有的新rpm包

## 配置文件

yum的配置文件为 _**/etc/yum.conf**_，通过它来控制 yum 的行为。如设置安装软件时不生成 doc 帮助文档：

```
$ vi yum.conf
tsflags=nodocs
```

配置  _**tsflags=nodocs**_，那么安装完软件\(如 zabbix-server-mysql\)后将不会再 _**/usr/share/doc**_ 下生成 zabbix-server-mysql 的帮助文档目录

## 案例

1.查找哪些软件包包含某个命令

```
$ yum provides ip
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
iproute-3.10.0-54.el7.x86_64 : Advanced IP routing and network device configuration tools
Repo        : XXXX
Matched from:
Filename    : /sbin/ip

# 从输出可知是 iproute 包提供 ip 命令
```

2.制作本地yum源

```
# 分别提供 createrepo 和 reposync 命令
$ yum install -y creatrepo yum-utils

# 安装 httpd
$ yum install -y httpd
$ systemctl enable httpd
$ systemctl start httpd

# 在/var/www/html/目录下创建一个目录,充当仓库
$ cd /var/www/html/
$ cd base
$ createrepo .                                 # 创建仓库
# 可直接执行 reposync 来同步当前 /etc/yum.repos.d/ 下所有的 yum 源

# 修改 yum.repo 文件
$ vim yum.repo
# enabled=1                   # 0禁用 1启用
# priority：1-99              # 数字越大,优先级越低

$ yum repolist
仓库ID                                       仓库名称
base/7/x86_64                                CentOS-7 - Base
centos-ceph-hammer/7/x86_64                  CentOS-7 - Ceph Hammer
centos-openstack-mitaka/x86_64               CentOS-7 - OpenStack mitaka

# 同步 base 仓库
$ reposync -r base/7/x86_64
```

> 注：若更新 yum 源后，需要使用 yum clean all 来清楚缓存，否则获取不到新加入的包

3.安装远端 rpm 包：_**yum install Remote\_RPM\_Address**_

```
$ yum install ftp://mirror.switch.ch/pool/4/mirror/opensuse/opensuse/update/leap/42.2/oss/x86_64/python-pycrypto-2.6.1-7.1.x86_64.rpm
Loaded plugins: fastestmirror, ovl
python-pycrypto-2.6.1-7.1.x86_64.rpm                                                                                                                                  | 372 kB  00:00:01
Examining /var/tmp/yum-root-pOiUQy/python-pycrypto-2.6.1-7.1.x86_64.rpm: python-pycrypto-2.6.1-7.1.x86_64
Marking /var/tmp/yum-root-pOiUQy/python-pycrypto-2.6.1-7.1.x86_64.rpm to be installed
Resolving Dependencies
--> Running transaction check
---> Package python-pycrypto.x86_64 0:2.6.1-7.1 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=============================================================================================================================================================================================
 Package                                     Arch                               Version                                  Repository                                                     Size
=============================================================================================================================================================================================
Installing:
 python-pycrypto                             x86_64                             2.6.1-7.1                                /python-pycrypto-2.6.1-7.1.x86_64                             2.0 M

Transaction Summary
=============================================================================================================================================================================================
Install  1 Package

Total size: 2.0 M
Installed size: 2.0 M
Is this ok [y/d/N]: y
Downloading packages:
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : python-pycrypto-2.6.1-7.1.x86_64                                                                                                                                          1/1
  Verifying  : python-pycrypto-2.6.1-7.1.x86_64                                                                                                                                          1/1

Installed:
  python-pycrypto.x86_64 0:2.6.1-7.1

Complete!
```

## FAQ

### 1.虚拟机下搭建的 yum 源报错

**场景**：虚拟机下搭建一个yum 源，作为 yum 源的虚拟机执行`yum repolist` 时都报错：403 Forbidden

**原因**：403 的错误一般是由于**权限不足**所引起的。分析问题的步骤如下：

```
1.在 /var/www/html 的 rpms 下新建 test.txt，发送请求获取该文件，报错 403，而将该文件直接放在 /var/www/html 下却可以
2.查看 yum 源 rpms 目录权限，确实都是 root:root 权限，这是没问题的
3.请求 curl -i http://192.168.0.111/rpms/pciutils/pcituilXX.rpm，返回 403 错误
4.检查 yum 源 rpm 文件来源
(1) FireZaler 使用 SFTP 传输的---> 重新解压 tar -zxvf 放入 /var/www/html ---> 不行，403
(2) 宿主机开启 http 服务，VM使用 curl 获取--> 解压，放入 /var/www/html ---> 不行，403
(3) 宿主机直接解压缩，发现 yum.tar.gz 解压后出现了一个 yum.tar 文件，利用该文件解压放入yum源，成功！
```

经分析，最终发现是 yum 源的数据来源出现了问题，最好还是在宿主机上解压缩后，查看是否正常在创建 yum 源

