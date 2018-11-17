# MongoDB副本集
## 一、简介
MongoDB复制是将数据同步在多个服务器的过程。副本集的使用保证提供了数据的冗余备份，提高了数据的可靠性、可用性和安全性，允许从硬件
故障和服务中断中恢复数据。

## 二、副本集群
mongo副本集群的搭建是通过在启动 mongod 进程时指定 **--replSet** 参数来实现，即启动副本集功能。mongodb 集群可以是单节点集群
(不推荐)，但其**复制功能至少是 2 节点**。即集群模型一般是**一主一从**、**一主多从**。
* 主节点：Primary 节点，负责数据**写操作**
* 从节点：Secondary 节点，负责从 Primary **同步数据**，保持集群数据一致性，提供数据高可用
  * Secondary 也可以提供数据读服务，实现读写分离，提供副本集的可用性
> 一般副本集群节点数为奇数

MongoDB的副本集与我们常见的主从有所不同，其他常见主从在主机宕机后所有服务将停止，而 mongodb 副本集在主机宕机后，副本会接管主节
点成为主节点，不会出现宕机的情况。
> 注：mariadb 集群不是主从结构。

主节点为 PRIMARY 节点，其后台 shell 的标识符为 repSetName:PRIMARY(如：rs0:PRIMARY). 从节点为 Secondary 节点，标识符同样
会变为 repSetName:Secondary

![副本集](asset/replset.png)

## 三、Primary 节点
副本集中 Primary 主要用于写操作，当然默认情况下数据的读取请求也是发送给 primary 处理的。Primary 节点的选举依靠大多数
(**x = N / 2 + 1**，N 是集群**参与投票成员数**)成员的投票。

发生 Primary 节点选举的场景有如下几种：
* Primary 节点宕机
  * 集群成员间**默认每 2s**发送一次心跳信息，若**10s 内未收到某节点心跳信息，则认为该节点已经宕机**
* 副本集被 reconfig ：`rs.reconfig()` 操作
* Primary 被 stepDown (降级)

## 四、特殊的 Secondary 节点
MongoDB 提供对 Secondary 节点进行灵活配置，以实现多种场景。可以通过**rs.reconfig()**配置 Secondary 节点为以下角色。

### 4.1 Arbiter
**简介**：Arbiter 节点**只参与投票**，不能被选为Primary，并且不从Primary同步数据。本身不存储数据，是非常轻量级的服务，当复
制集成员为偶数时，最好加入一个Arbiter节点，以提升复制集可用性。

**场景**：2节点的MongoDB集群，一主一从，当主节点宕机后，无法进行Primary选举，因为此时大多数 x = 2 / 2 + 1 =2，节点宕机后无法
得到大多数成员投票，从而导致副本集无法提供服务。此时可以给复制集添加一个Arbiter节点，即使有节点宕机，仍能选出Primary

### 4.2 Priority0
**简介**：Priority0 节点的**选举优先级为0**，不会被选举为Primary。

**场景**：若想让 Primary 节点在某台主机或某个机房时，可以设置其他节点为 Priority0 节点
```
cfg = rs.conf();
cfg.members[2].priority = 0;
rs.reconfig(cfg);
```

### 4.3 Vote0
**简介**：MongoDB3.0 中副本集**成员最多为 50 个**，**参与** Primary 节点**选举的节点数最多 7 个**，其他成员 vote 属性必须设置为 0，即不参与投票。

**场景**：大规模的 MongoDB 集群环境下，需要设置

### 4.4 Hidden
**简介**：Hidden 节点是 Priority0 节点的一种，即不能被选举为 Primary 节点。而且 Hidden 节点对客户端 Driver 是不可见的，Hidden 节点不会接收 Driver 的请求。

**场景**：一般使用 Hidden 节点来做一些**数据备份、离线计算**的任务，不会影响复制集的服务

### 4.5 Delayed
**简介**：Delayed 节点必须是 Hidden 节点，其数据落后 Primary 节点一段时间\(如 1h，可自由配置\)

**场景**：因 Delayed 节点的数据比Primary落后一段时间，因此 Delayed 节点**常用来进行数据恢复/回滚**，即当错误或者无效的数据写入Primary时，可通过Delayed节点的数据来恢复到之前的时间点

## 五、数据同步原理
MongoDB 副本集环境下，Primary 节点与 Secondary 节点通过**oplog**来进行数据同步。Primary 节点写数据完毕后，会向特殊
的**local.oplog.rs**集合写入一条**oplog**，**Secondary不断的从Primary取新的oplog并应用**。**为了防止 local.oplog.rs
集合数据无限膨胀**，该集合会被设置为** capped 集合**，当容量达到上限时，会将**最旧**的数据删除。
> 注：当 Secondary 在批量拉取 oplog 并应用时，会加锁 _Lock::ParallelBatchWriterMode_，当设置Secondary读请求优先时，此时会阻塞所有发送到该Secondary节点上的读请求。加锁原因：
>
> * 避免脏读
> * 保证同步性能：若不锁，那么出现大量读请求时，边同步边读取，会造成同步逐步跟不上
>
> 当然加锁的缺点是，一旦当Primary上写入并发很大时，此时Secondary需要大量 oplog 的同步，可能造成阻塞很长，读取缓慢
```
rs0:PRIMARY> use local
switched to db local
rs0:PRIMARY>
rs0:PRIMARY> show collections
oplog.rs
startup_log
system.indexes
system.replset
rs0:PRIMARY>
rs0:PRIMARY> db.oplog.rs.findOne()
{
    "ts" : Timestamp(1489140204, 1),
    "h" : NumberLong(0),
    "v" : 2,
    "op" : "n",
    "ns" : "",
    "o" : {
        "msg" : "initiating set"
    }
}
```
oplog 格式解释
* ts：写操作时间
* h：操作的全局唯一标识
* v：oplog 版本信息，用于保证数据一致性---&gt;乐观锁
* op：执行动作
  * n：空操作，特殊用途，如初始化副本集
  * i：插入数据
  * u：更新数据
  * d：删除数据
  * c：执行命令，如 createDatabase, dropDatabase
* ns：操作针对的集合
* o：操作内容

> 拥有最新optime（最近一条oplog的时间戳）的节点才能被选为主节点

Secondary 节点数据同步过程
* 初次同步：第一次同步时，先进行 init sync 操作，从 Primary 或其他数据已更新的 Secondary **获取全量数据**
* 非初次：通过`taiable cursor` 不断从 Primary 的`local.oplog.rs`中查询最新的 oplog 并应用

local.oplog .rs 集合大小设置：应根据DB规模及应用写入需求合理配置
* 太大：造成空间浪费
* 太小：可能造成初次同步时 init sync 操作失败，无法同步完整数据

## 六、rs 的数据读设置
默认情况下，复制集的所有读请求都发到Primary。可以通过设置[Read Preference](https://docs.mongodb.org/manual/core/read-preference/?spm=5176.100239.blogcont64.9.BDGo1K) 来将读请求路由到其他节点。
* **primary**：默认值，读请求全部交给 Primary 节点处理
* **primaryPreferred**： Primary优先，如果Primary不可达，请求Secondary
* **secondary**： 所有的读请求都发到secondary
* **secondaryPreferred**：Secondary优先，当所有Secondary不可达时，请求Primary
* **nearest**：读请求发送到最近的可达节点上(通过**ping探测**得出最近的节点)

## 七、副本集管理
1.副本初始化：rs.initiate()
用于初始化 mongodb 集群，初始化操作执行时各成员间开始发送心跳信息，并发起 Primary 选举操作，获得大多数成员支持的节点将成为
 Primary 节点。大多数 x = N / 2 + 1，其中 N 为MongoDB集群节点数
> 每个节点都倾向于投票给优先级最高的节点，一般是执行该 rs.initiate() 操作的节点会成为 Primary 节点

示例如下：
```
# rs0 为副本集名
> conf = {"_id" : "rs0",
        "version" : 1,
        "members" : [{
                       "_id" : 1,
                       "host" : "10.20.102.1:27017"
                      },
                       {
                       "_id" : 2,
                       "host" : "10.20.102.2:27017"},
                      {
                       "_id" : 3,
                       "host" : "10.20.102.3:27017"}
                      ]}
 > rs.initiate(conf )
 > rs0:PRIMARY> rs.status()
{
    "set" : "rs0",
    "date" : ISODate("2018-02-20T10:09:08Z"),
    "myState" : 1,
    "members" : [
        {
            "_id" : 1,
            "name" : "10.20.102.1:27017",
            "health" : 1,
            "state" : 1,
            "stateStr" : "PRIMARY",
            "uptime" : 15968,
            "optime" : Timestamp(1487557805, 1),
            "optimeDate" : ISODate("2018-02-20T02:30:05Z"),
            "electionTime" : Timestamp(1487569389, 1),
            "electionDate" : ISODate("2018-02-20T05:43:09Z"),
            "self" : true
        },
        {
            "_id" : 2,
            "name" : "10.20.102.2:27017",
            "health" : 1,
            "state" : 2,
            ...
        },
        {
            "_id" : 3,
            "name" : "10.20.102.3:27017",
            "health" : 1,
            ...
        }
    ],
    "ok" : 1
}
```
> 注：要使用副本集，则mongod进程必须使用 --replSet 选项启动，否则报错 server is not running with --replSet

执行完毕后，再次可以发现后台 shell 的变化, mongodb 节点提示符分别变为如下显示：
```
# 主节点 PRIMARY
rs0:PRIMARY>

# 从节点
rs0:SECONDARY>
```

2.副本添加：rs.reconfig()、rs.add()

副本添加有 2 种方法，使用 rs.reconfig() 或者 rs.add()
```
# reconfig
> conf = {...}
> rs.reconfig(conf)

# add
> rs.add("10.158.113.151:27017")
```

3.副本移除：rs.remove()

使用 rs.remove() 将某个 mongodb 节点移除集群
```
rs0:PRIMARY> rs.remove("10.158.113.151:27017")
rs.status()
{
    "set" : "rs0",
    "date" : ISODate("2018-02-20T08:35:02Z"),
    "myState" : 1,
    "members" : [
        {
            "_id" : 1,
            "name" : "10.158.113.155:27017",
            "health" : 1,
            ....
        },
        {
            "_id" : 2,
            "name" : "10.158.113.157:27017",
            "health" : 1,
            ...
        }
    ],
    "ok" : 1
}
```

4.判断当前节点是否是 master 节点：db.isMaster()
```
rs0:PRIMARY> db.isMaster()
{
    "setName" : "rs0",
    "setVersion" : 1,
    "ismaster" : true,
    "secondary" : false,
    "hosts" : [
        "10.158.113.151:27017"
    ],
    "primary" : "10.158.113.151:27017",
    "me" : "10.158.113.151:27017",
    "electionId" : ObjectId("58aaa75264ce3ada40f654a0"),
    "maxBsonObjectSize" : 16777216,
    "maxMessageSizeBytes" : 48000000,
    "maxWriteBatchSize" : 1000,
    "localTime" : ISODate("2018-02-20T08:56:47.538Z"),
    "maxWireVersion" : 2,
    "minWireVersion" : 0,
    "ok" : 1
}
```

## 八、初始化副本集后数据添加的问题
mongodb 在初始化副本集后，集群数据只能从 Master 节点上插入，然后在同步到各个副本上。若是在 Slave 上添加数据，会报错
WriteResult({ "writeError" : { "code" : undefined, "errmsg" : "not master" } })。在副本节点上，没有管理员权限，
无法进行管理员的相关操作。Secondary 节点还是可以提供读服务的
> MongoDB复制集里Primary节点是不固定的

案例：
```
# 连接副本集的配置
$ cat ceilometer.conf
[database]
event_connection = mongodb://ceilometer:EIMzjIFScxXE4CLy3ly6r9oEZ9WSQY7EHASHVir4@master2:27017/ceilometer
metering_connection = mongodb://ceilometer:EIMzjIFScxXE4CLy3ly6r9oEZ9WSQY7EHASHVir4@master2:27017/ceilometer

# Slave 上
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

# Master 上
rs0:PRIMARY> use ceilometer
switched to db ceilometer
rs0:PRIMARY>
rs0:PRIMARY> db.test.insert({"name": "jp"})
WriteResult({ "nInserted" : 1 })
rs0:PRIMARY>
```

## 九、正确的 MongoDB 连接方法
为了解决上述问题，就必须知道正确连接 mongodb 副本集的方法，正确的 MongoDB 的 Connection String URL 如下：
```
mongodb://[username:password@]host1[:port1][,host2[:port2],...[,hostN[:portN]]][/[database][?options]]
```

URL解释
* `mongodb://`: 表示这个字符串是一个 Connection URL
* `username:password@`：若启动了鉴权，则需要指定
* `host*:port*`：副本集成员及端口，多个成员以逗号分割
* `database`：鉴权时用户使用的数据库
* `?options`：指定额外连接选项，常用选项如下：
  * `?readPreference=secondaryPreferred`：读请求优先到Secondary节点，从而实现读写分离的功能
  * `?maxPoolSize=xx`：限制连接数，将客户端连接池限制在xx以内
  * `?w=majority`：保证写请求成功写入大多数节点才向客户端返回确认信息
  > 建议 Driver 配置 w=majority，防止由于**网络分区**造成短时间内出现多个 Primary 节点时，保证只有一个 Primary 节点能成功写入大多数。

案例：
```
mongodb://ceilometer:123456@master0:27020,master0:27021,master1:27022/ceilometer?replicaSet=rs0
```
所有官方客户端 driver(如 java,python等) 都支持 MongoDB Connection String URI 的方式去连接，客户端均支持连接断开自动重连的
功能。若连接的是复制集，客户端会自动检测复制集的主备关系，当主备关系发生变化时，自动将写切换到新的主节点上，以保证服务的高可用。

![conn-url](asset/conn-url.png)

## 十、MongoDB副本重启方法
在需要重启MongoDB节点的场景(如：副本集版本升级、节点维护)中，建议不要直接shutdown Primary，这样可能导致已经写入primary但未同步到secondary的数据丢失。这种直接关闭主节点的过程如下：
1. shutdown primary：shutdown会等待Secondary oplog追到10s以内
2. 重新枚举出新的 Primary 节点
3. 旧 Primary 重启，而此时集群中已经存在 Primary 因此该将以 Secondary 角色运行
4. 旧 Primary 从新 Primary 同步数据的过程中，发现自己有无效的oplog，会先进行rollback：rollback的数据只要不超过300M是可找回的

若想重启集群后，不丢失数据，方法应该如下：
1. 逐个重启复制集里所有的Secondary节点
2. 对Primary发送_stepDown_命令，等待primary降级为Secondary
3. 重启降级后的Primary
> 注：若Secondary的同步一直追不上Primary，步骤2可能会失败，这时应重试步骤2直到stepDown成功；步骤2也可通过调用replSetReconfig命令来调整节点优先级来实现，让Secondary拥有更高的优先级，然后等待Primary降级为Secondary

## 参考文献
1. [MongoDB Driver：使用正确的姿势连接 MongoDB 副本集](https://yq.aliyun.com/articles/8461?spm=5176.100239.blogcont72235.23.IYrj4x)
2. [MongoDB管理：如何优雅的重启复制集？](https://yq.aliyun.com/articles/14692?spm=5176.100239.blogcont8461.24.aouBnH)
3. [MongoDB 生态 - 客户端 Driver 支持](https://yq.aliyun.com/articles/65109?spm=5176.100239.blogcont8461.26.PVzJ2q)
4. [MongoDB Secondary 延时高（同步锁）问题分析](https://yq.aliyun.com/articles/61949?spm=5176.100239.blogcont72235.24.dkn6uw)