# netstat
## 简介
查看网络端口的命令。要使用该命令，需要额外安装包。

```
$ yum install -y net-tools
```

## 选项

* **-a**：all，显示所以连接和监听端口
* **-n**：number，以数字形式显示地址和端口号

## 案例

查看80端口情况

```
$ netstat -anp | grep 80
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp6       0      0 :::80                   :::*                    LISTEN      963/httpd
```

查看 dockerd 套接字监听情况

```
$ netstat -anp | grep dockerd
Active UNIX domain sockets (servers and established)
Proto RefCnt Flags       Type       State         I-Node   PID/Program name     Path
unix  2      [ ACC ]     STREAM     LISTENING     27759    966/dockerd          /run/docker/libnetwork/5ad5d65a1be18995b929550b979d6d18978cb4bc6ec92be5f713ffcc9a06ca1a.sock
unix  2      [ ACC ]     STREAM     LISTENING     23997    966/dockerd          /var/run/docker.sock
unix  3      [ ]         STREAM     CONNECTED     20839    966/dockerd
unix  3      [ ]         STREAM     CONNECTED     26637    966/dockerd
unix  2      [ ]         DGRAM                    22473    966/dockerd
```