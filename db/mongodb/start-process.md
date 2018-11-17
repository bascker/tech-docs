# 启动流程
以命令 **mongod --config /etc/mongod.conf --rest --replSet rs0**的执行来进行说明.

## 一、分析
## 1.1 启动进程
```
$ mongod --config /etc/mongod.conf --rest --replSet rs0
2018-02-20T08:14:59.084+0000 ** WARNING: --rest is specified without --httpinterface,
2018-02-20T08:14:59.084+0000 **          enabling http interface
about to fork child process, waiting until server is ready for connections.
forked process: 72
child process started successfully, parent exiting

$ vim mongodb.log
### mongo 进程启动并初始化
[initandlisten] MongoDB starting : pid=72 port=27017 dbpath=/var/lib/mongodb 64-bit host=deploy
[initandlisten] db version v2.6.11
[initandlisten] git version: nogitversion
[initandlisten] OpenSSL version: OpenSSL 1.0.1e-fips 11 Feb 2013
[initandlisten] build info: Linux c1bk.rdu2.centos.org 2.6.32-573.8.1.el6.x86_64 #1 SMP Tue Nov 10 18:01:38 UTC 2015 x86_64 BOOST_LIB_VERSION=1_53
[initandlisten] allocator: tcmalloc
[initandlisten] options: { config: "/etc/mongod.conf", net: { bindIp: "10.158.113.151", http: { RESTInterfaceEnabled: true, enabled: true }, unixDomainSocket: { pathPrefix: "/var/run/mongodb" } }, processManagement: { fork: true, pidFilePath: "/var/run/mongodb/mongod.pid" }, replication: { replSet: "rs0" }, storage: { dbPath: "/var/lib/mongodb" }, systemLog: { destination: "file", path: "/var/log/mongodb/mongod.log" } }
[initandlisten]
[initandlisten] ** WARNING: Readahead for /var/lib/mongodb is set to 4096KB
[initandlisten] **          We suggest setting it to 256KB (512 sectors) or less
[initandlisten] **          http://dochub.mongodb.org/core/readahead
[initandlisten] journal dir=/var/lib/mongodb/journal
[initandlisten] recover begin
[initandlisten] recover lsn: 0
[initandlisten] recover /var/lib/mongodb/journal/j._0
[initandlisten] recover cleaning up
[initandlisten] removeJournalFiles
[initandlisten] recover done
[initandlisten] preallocateIsFaster=true 2.5
[initandlisten] preallocateIsFaster=true 4.84
[initandlisten] preallocateIsFaster check took 13.893 secs
[initandlisten] waiting for connections on port 27017

# 启动 web 服务
[websvr] admin web console waiting for connections on port 28017

# 副本准备：尚未初始化副本，该输出只有在启动 mongod 时指定 --replSet 参数时才有
[rsStart] replSet can't get local.system.replset config from self or any seed (EMPTYCONFIG)
[rsStart] replSet info you may need to run replSetInitiate -- rs.initiate() in the shell -- if that is not already done
[rsStart] replSet can't get local.system.replset config from self or any seed (EMPTYCONFIG)
[rsStart] replSet can't get local.system.replset config from self or any seed (EMPTYCONFIG)
[rsStart] replSet can't get local.system.replset config from self or any seed (EMPTYCONFIG)
[rsStart] replSet can't get local.system.replset config from self or any seed (EMPTYCONFIG)
[rsStart] replSet can't get local.system.replset config from self or any seed (EMPTYCONFIG)
[rsStart] replSet can't get local.system.replset config from self or any seed (EMPTYCONFIG)

$ mongo 10.158.113.151
MongoDB shell version: 2.6.11
...
>
```

## 1.2 集群初始化
```
# 单节点集群：注意初始化前后提示符的变化
> conf={"_id": "rs0", "version": 1, members: [{"_id": 1, "host": "10.158.113.151"}]}
{
    "_id" : "rs0",
    "version" : 1,
    "members" : [
        {
            "_id" : 1,
            "host" : "10.158.113.151"
        }
    ]
}
>
>
> rs.initiate(conf)
{
    "info" : "Config now saved locally.  Should come online in about a minute.",
    "ok" : 1
}
>
rs0:PRIMARY>
rs0:PRIMARY> exit

$ vim mongodb.log
[rsStart] replSet can't get local.system.replset config from self or any seed (EMPTYCONFIG)
### 开始初始化副本集：副本添加
[conn1] replSet replSetInitiate admin command received from client
[conn1] replSet replSetInitiate config object parses ok, 1 members specified
[conn1] replSet replSetInitiate all members seem up
[conn1] ******
[conn1] creating replication oplog of size: 990MB...
[FileAllocator] allocating new datafile /var/lib/mongodb/local.1, filling with zeroes...
[FileAllocator] creating directory /var/lib/mongodb/_tmp
[FileAllocator] done allocating datafile /var/lib/mongodb/local.1, size: 1024MB,  took 0.024 secs
[conn1] ******
[conn1] replSet info saving a newer config version to local.system.replset: { _id: "rs0", version: 1, members: [ { _id: 1, host: "10.158.113.151:27017" } ] }
[conn1] build index on: local.system.replset properties: { v: 1, key: { _id: 1 }, name: "_id_", ns: "local.system.replset" }
[conn1]     added index to empty collection
[conn1] replSet saveConfigLocally done
[conn1] replSet replSetInitiate config now saved locally.  Should come online in about a minute.
### 副本启动
[rsStart] replSet I am 10.158.113.151:27017
[rsStart] build index on: local.me properties: { v: 1, key: { _id: 1 }, name: "_id_", ns: "local.me" }
[rsStart]   added index to empty collection
[rsStart] replSet STARTUP2
### 副本同步
[rsSync] replSet SECONDARY
[rsMgr] replSet info electSelf 1
[rsMgr] replSet PRIMARY
[clientcursormon] mem (MB) res:97 virt:3410
[clientcursormon]  mapped (incl journal view):2848
[clientcursormon]  connections:1
[clientcursormon]  replication threads:32

# 退出 shell
[conn1] end connection 10.158.113.151:58442 (0 connections now open)
```
此处是单节点集群，因此副本只有 1 个，**若是多节点集群，**则会在**副本添加阶段将所有 mongo 节点加入集群，**在**同步阶段将数据
同步**。

## 二、总结
根据上述结果，可知 mongodb 集群的启动流程分为以下步骤：
1. mongodb 进程的启动：**mongod **
   * **27017 **端口的监听：mongodb 数据库端口监听
   * **28017 **端口的监听：若开启 web 功能
2. 等待副本集(集群初始化)：`rs.initiate()`
   * **添加**副本：连接指定的 mongodb 节点
   * **启动**副本
   * **同步**副本：数据同步