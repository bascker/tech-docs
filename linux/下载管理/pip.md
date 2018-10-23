# pip
## 简介

python 的包管理工具

> 注：安装 pip 后，需要执行 _yum install -y python-devel_ 安装** python-devel**，该软件是Python的头文件和静态库包，若没有装这个，pip 使用时会报错"_src/MD2.c:31:20: fatal error: Python.h: No such file or directory_"

## 操作

* 安装：**pip install**
  * 安装指定版本包：_pip install PKG\_NAME==VERSION_
  * 安装本地包：_pip install --no-index -f=&lt;目录&gt;/ &lt;包名&gt;_
* 升级：_pip install -U PKG\_NAME_
* 卸载：_pip uninstall PKG\_NAME_
* 查看已安装包信息信息：_pip show PKG\_NAME_
  * 参数 **-f**：显示与 PKG 相关的所有文件
* 查看所有可升级的包：_pip list -o_
* 搜索：_pip search PKG\_NAME_
* 下载包：_pip download_
  * -q：静默下载
* **pip2tgz**：扩展工具, 用于单个/批量下载pip软件包
  * 安装：_pip install pip2pi_

## 案例

1.查看 docker-py 包信息

```
$ pip show docker-py
---
Metadata-Version: 2.0
Name: docker-py
Version: 1.7.2
Summary: Python client for Docker.
Home-page: https://github.com/docker/docker-py/
Author: UNKNOWN
Author-email: UNKNOWN
Installer: pip
License: UNKNOWN
Location: /usr/lib/python2.7/site-packages
Requires: six, requests, websocket-client
Classifiers:
  Development Status :: 4 - Beta
  Environment :: Other Environment
  Intended Audience :: Developers
  Operating System :: OS Independent
  Programming Language :: Python
  Programming Language :: Python :: 2.6
  Programming Language :: Python :: 2.7
  Programming Language :: Python :: 3.3
  Programming Language :: Python :: 3.4
  Topic :: Utilities
  License :: OSI Approved :: Apache Software License
```

2.下载多个 pip 包

```
$ pip2tgz /var/www/packages/ -r requirements.txt foo==1.2
```

3.使用 pip download 下载

```
$ pip download graphviz
Collecting graphviz
  Downloading http://pypi.doubanio.com/packages/ff/81/14ad4d67841aca1522c00eaad9e751dcab8f49958e0a3f474c483904d532/graphviz-0.6-py2.py3-none-any.whl
  Saved ./graphviz-0.6-py2.py3-none-any.whl
Successfully downloaded graphviz

$ ll
total 16
-rw-r--r-- 1 root root 14427 Mar 23 05:34 graphviz-0.6-py2.py3-none-any.whl
```

## FAQ

1.安装 mysql\_python 出错

场景：centos下安装 mysql\_python  报错 _pg\_config executable not found_

解决：安装 mysql-devel

```
$ yum install mysql-devel
```

2.安装 psycopg2 出错

场景：安装 psycopg2 出错，报错 _Error:pg\_config executable not found_

解决：安装 postgresql-deve

```
$ yum install postgresql-deve3.
```

3.InsecurePlatformWarning: A true SSLContext object is not available.

```
pip install pyopenssl ndg-httpsclient pyasn1
```

4.pip install pyopenssl ndg-httpsclient pyasn1出错

场景：pip 安装pyopenssl ndg-httpsclient pyasn1 出错，报错_Python.h No such file or directory_

解决：2种系统下的方法

```
# centos
$ yum install openssl-devel

# ubuntu
$ apt-get install libssl-dev
```