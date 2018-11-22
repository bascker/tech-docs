# 安装
## yum
yum安装很简单, 执行以下命令即可
```
$ yum install -y docker         # v1.10
$ yum install -y docker-engine  # v1.12
```

## rpm 安装
安装依赖
```
$ rpm -ivh audit-libs-python
$ rpm -ivh checkpolicy
$ rpm -ivh docker-engine-selinux
$ rpm -ivh iptables
$ rpm -ivh libcgroup
$ rpm -ivh libmnl
$ rpm -ivh libnetfilter_conntrack
$ rpm -ivh libnfnetlink
$ rpm -ivh libseccomp
$ rpm -ivh libselinux-python
$ rpm -ivh libselinux-utils
$ rpm -ivh libsemanage-python
$ rpm -ivh libtool-ltdl
$ rpm -ivh policycoreutils
$ rpm -ivh policycoreutils-python
$ rpm -ivh python-IPy
$ rpm -ivh selinux-policy
$ rpm -ivh selinux-policy-targeted
$ rpm -ivh setools-libs
```

安装docker
```
$ rpm -ivh docker-engine
```

## FAQ
### 1.yum 安装时发现出现警告信息
**场景**：yum 安装 docker 时出现如下警告信息
```
...
%post(docker-engine-selinux-1.12.0-1.el7.centos.noarch) 脚本执行失败，退出状态码为 255
```
**原因**：因为在安装 docker 时没有关闭防火墙

**解决**：关闭防火墙，重启 docker 即可