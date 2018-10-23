# rpm
## 简介

* 用于软件包管理
* **5** 种操作模式：安装、卸载、升级、查询和验证

## 操作

1.**安装**：_rpm -ivh_

* **-i**：安装
* **-v**：在安装过程中显示正在安装的文件信息
* **-h**：显示安装进度

2.**升级**\(不破坏软件依赖关系的情况下升级rpm包\)：_rpm -Uvh_

3.**查询**：_rpm -qa_

* **-a**：查询所有已经安装的包
* **-s**：显示安装版中的所有文件状态及被安装到哪些目录下

4.**卸载**：_rpm -e_

5.**验证**：_rpm -V_

6.**导入key**：rpm --import

```
# 当进行 reposync -r influxdb 时需要，否则yum源同步失败
$ rpm --import influxdb.key
```

## 案例

```
# 查找系统中的 docker rpm包
$ rpm -qa | grep docker
# 删除 rpm 包
$ rpm -e docker-forward-journald-1.10.3-44.el7.centos.x86_64

$ rpm -qa | grep httpd
httpd-2.4.6-40.el7.centos.4.x86_64
httpd-tools-2.4.6-40.el7.centos.4.x86_64

# 显示依赖关系
$ rpm -qa --requires | grep httpd
httpd-tools = 2.4.6-40.el7.centos.4
httpd-mmn = 20120211x8664
```