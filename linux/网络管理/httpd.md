# Httpd
## 简介
可以在自己的主机上启动一个 httpd 的服务，用于充当Web服务器，提供文件上传下载功能

## 安装
可以直接使用 yum 安装，也可以使用 rpm 安装

```
1.yum 安装
$ yum install -y httpd

2.rpm 安装：较为麻烦
# 安装 httpd 的依赖包
$ rpm -ivh apr***
$ rpm -ivh apr-util***
$ rpm -ivh centos-logos***
$ rpm -ivh httpd-tools***
$ rpm -ivh mailcap***

# 安装 httpd
$ rpm -ivh httpd
```

启动 httpd 服务

```
$ systemctl start httpd
$ systemctl status httpd
$ ps auxf | grep httpd
root       984  0.0  0.0 221908  5028 ?        Ss   Feb09   3:08 /usr/sbin/httpd -DFOREGROUND
apache   20296  0.0  0.0 222044  3656 ?        S    Mar26   0:00  \_ /usr/sbin/httpd -DFOREGROUND
apache   20298  0.0  0.0 222044  3716 ?        S    Mar26   0:00  \_ /usr/sbin/httpd -DFOREGROUND
apache   20299  0.0  0.0 222044  3704 ?        S    Mar26   0:00  \_ /usr/sbin/httpd -DFOREGROUND
apache   20300  0.0  0.0 222044  3740 ?        S    Mar26   0:00  \_ /usr/sbin/httpd -DFOREGROUND
apache   20303  0.0  0.0 222044  3656 ?        S    Mar26   0:00  \_ /usr/sbin/httpd -DFOREGROUND
```

## 修改默认端口

httpd 默认端口号为 80，若想修改端口，那么就需要修改 /etc/httpd/conf/httpd.conf 文件

```
$ vim httpd.conf
# Listen 80
Listen 8080

$ systemctl restart httpd
$ curl -i http://localhost:8080
HTTP/1.1 200 OK
Date: Mon, 26 Jun 2017 12:27:27 GMT
Server: Apache/2.4.6 (CentOS)
Last-Modified: Thu, 22 Jun 2017 12:56:51 GMT
ETag: "65-5528c04b83f7d"
Accept-Ranges: bytes
Content-Length: 101
Content-Type: text/html; charset=UTF-8

<html>
  <head>
    <title>Index</title>
  </head>
  <body>
    This is index page
  </body>
</html>

$ curl -i http://www.tanlang.xin:8080
# 同上
```