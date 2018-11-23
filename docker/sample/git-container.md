# git 仓库镜像
1.编写 Dockerfile
```
$ vim Dockerfile
FROM centos:7
MAINTAINER tanlang <jp2317015793@aliyun.com>

RUN yum install -y vim git openssh-server
RUN git config --global receive.denyCurrentBranch ignore
RUN mkdir /var/run/sshd \
    && sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
    && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
    && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key

RUN echo "root:123456" | chpasswd

ENTRYPOINT ["/usr/sbin/sshd", "-E", "/var/log/auth.log", "-D"]
```
启动命令 `["/usr/sbin/sshd", "-E", "/var/log/auth.log", "-D"]` 建议更改为 `["/usr/sbin/sshd", "-D"]`, 不然 docker logs 看不到 sshd 的日志输出
若想同时看到日志和输入到日志文件，那么就使用 tee 命令拼接好了。

2.构建镜像
```
$ docker build -t bascker/gitrepo .
```

3.创建容器
```
$ docker run -itd --name gitrepos tanlang/gitrepo

# 查看 ip
$ docker inspect gitrepos | grep IPAddress
            "SecondaryIPAddresses": null,
            "IPAddress": "172.17.0.3",
                    "IPAddress": "172.17.0.3"
```

4.ssh测试
```
$ ssh 172.17.0.3
  The authenticity of host '172.17.0.3 (172.17.0.3)' can't be established.
  ECDSA key fingerprint is 62:e4:90:52:c0:9b:7d:b4:5f:0e:ae:f4:df:d6:9b:b8.
  Are you sure you want to continue connecting (yes/no)? yes
  Warning: Permanently added '172.17.0.3' (ECDSA) to the list of known hosts.
  root@172.17.0.3's password:
[root@b7d35fe60b7d ~]#
[root@b7d35fe60b7d ~]# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.3 105480  3940 ?        Ss+  02:15   0:00 /usr/sbin/sshd -E /var/log/auth.log -D
root         6  0.1  0.5 146280  5592 ?        Ss   02:17   0:00 sshd: root@pts/0
root         8  0.0  0.1  15200  1984 pts/0    Ss   02:17   0:00 -bash
root        23  0.0  0.1  50872  1812 pts/0    R+   02:17   0:00 ps aux
[root@b7d35fe60b7d ~]#
```

5.Git 测试
```
# 容器内创建 git 仓库
$ git init sample.git

# 宿主机
$ ssh-copy-id -i .ssh/id_rsa.pub 172.17.0.3                 # 配置无密钥登录

$ git clone ssh://172.17.0.3/root/sample.git
Cloning into 'sample'...
warning: You appear to have cloned an empty repository.

$ ll
drwxr-xr-x 3 root root 4096 Jul 12 10:21 sample

$ cd sample
$ echo "Test" > a
$ git add a
$ git commit -m "Just a Test"
[master (root-commit) 94b690c] Just a Test
 1 file changed, 1 insertion(+)
 create mode 100644 a
$ git push
Counting objects: 3, done.
Writing objects: 100% (3/3), 221 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To ssh://172.17.0.3/root/sample.git
 * [new branch]      master -> master
```