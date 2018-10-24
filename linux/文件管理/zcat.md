# zcat
## 简介
用于不真正解压缩文件，就能显示gzip压缩包中文件的内容的场合

## 案例
读取 zabbix sql tar文件内容，写入数据库

```
$ zcat /usr/share/doc/zabbix-server-mysql-3.2.*/create.sql.gz | mysql -h mariadb -u zabbix -p123456 --database=zabbix
```