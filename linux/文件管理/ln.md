# ln
## 简介
用于创建软连接，类似 windows 下创建快捷方式

## 案例
1.创建软连接：`ln -s src_path linkname`

```
$ ln -s /var/lib/docker/volumes/kolla_logs/_data/ kolla_logs
```

2.删除软连接：`rm -f linkname`

```
$ rm -f kolla_logs
```

> 删除软连接时，千万不能写成 rm -rf kolla\_logs_/，_这样删除的不是软连接，而是kolla\_logs 目录下的所有文件！！！