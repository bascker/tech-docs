# FAQ
## 一、进入 mongodb 后台 shell 失败
场景：直接执行 mongo 进入后台 shell 时失败。报错如下所示：
```
$ mongo
MongoDB shell version: 2.6.11
connecting to: test
2018-02-15T14:50:53.965+0800 warning: Failed to connect to 127.0.0.1:27017, reason: errno:111 Connection refused
2018-02-15T14:50:53.966+0800 Error: couldn't connect to server 127.0.0.1:27017 (127.0.0.1), connection attempt failed at src/mongo/shell/mongo.js:146
exception: connect failed
```
原因：启动 mongod 时指定了配置文件，而配置文件中的 **bindIp** 值不是 127.0.0.1。因此执行 mongo 时需要添加 --host 参数

## 二、远程连接问题
使用 mongodb 进行远程连接时，有 2 种方式：
1. mongo --host IP/Hostname
2. mongo IP：这种省略 --host 的方式只使用后面直接跟 ip 地址的情况

**建议使用 --host 明确指定**，否则若是使用第二种方式时，写成 mongo Hostname，就会出错，这样连接的是本地 mongo 服务器，而不是
远程 mongo 服务器。这种情况，在k8s环境下对 mongo 集群进行初始化时，很容易出现不确定哪个节点称为 Master 节点的问题。
```
$ mongo controller1
MongoDB shell version: 2.6.11
connecting to: controller1
2018-02-26T17:01:20.680+0800 warning: Failed to connect to 127.0.0.1:27017, reason: errno:111 Connection refused

$ mongo --host controller1
MongoDB shell version: 2.6.11
connecting to: controller1:27017/test
Server has startup warnings:
...
rs0:PRIMARY>
```

## 三、副本集群数据操作问题
mongo 副本集群环境中，**只有 master 节点才能对数据库进行增删改查的操作，数据更新后再同步到 slave 节点**。而 slave 节点是
没有权限的。
```
# Slave
rs0:SECONDARY> use ceilometer
switched to db ceilometer
rs0:SECONDARY>
rs0:SECONDARY> show collections
2018-02-23T14:53:14.549+0800 error: { "$err" : "not master and slaveOk=false", "code" : 13435 } at src/mongo/shell/query.js:131
rs0:SECONDARY> show collections;
2018-02-23T14:53:17.749+0800 error: { "$err" : "not master and slaveOk=false", "code" : 13435 } at src/mongo/shell/query.js:131
rs0:SECONDARY>
rs0:SECONDARY> db.test.insert({"name": "jp"})
WriteResult({ "writeError" : { "code" : undefined, "errmsg" : "not master" } })

# Master
rs0:PRIMARY> use ceilometer
switched to db ceilometer
rs0:PRIMARY>
rs0:PRIMARY> db.test.insert({"name": "jp"})
WriteResult({ "nInserted" : 1 })
rs0:PRIMARY>
```