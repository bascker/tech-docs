# MariaDB
## 一、简介
Mariadb 是 MySQL 的开源版本, 三种启动方式。
```
# systemd 启动服务
$ systemctl start mariadb

# mysqld 脚本来启动
$ /etc/init.d/mysqld start

# mysqld_safe
$ mysqld_safe &
```
mysqld_safe 是**官方推荐**的 mariadb 启动方式，使用 mysqld_safe 启动，会监控mysql进程，如果mysql进程关闭，自动重启mysql进程。
默认情况下，mysqld_safe 尝试启动可执行 mysqld-max(若存在)，否则启动 mysqld