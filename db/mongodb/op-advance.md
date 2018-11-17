# 进阶操作
[官方文档](https://docs.mongodb.com/master/reference/built-in-roles/#built-in-roles)

## 一、执行 js 代码
1.利用** --quiet** 执行 js 文件
```
# 测试 js
$ vim test.js
print('=========Test==========');

var rs = db.mycol.findOne();
printjson(rs);

var sum = 1 + 2
print("1 + 2 = " + sum)

# 执行
$ mongo 10.158.113.151 --quiet test.js
=========Test==========
null
1 + 2 = 3
```

## 二、不进入 mongo shell 执行 mongo 命令
1.利用 **--eval** 执行
```
$ mongo 10.158.113.151 --eval "printjson(db.bascker)"
MongoDB shell version: 2.6.11
connecting to: 10.158.113.151/test
test.bascker

$ mongo 10.158.113.151 --eval "printjson(db.bascker.findOne())"
MongoDB shell version: 2.6.11
connecting to: 10.158.113.151/test
null

# 注：要想和在 mongo shell 一样显示 json 结果，就得使用 printjson() 方法，否则输出为 [object Object]
$ mongo --host controller1 --eval 's = db.isMaster(); s'
MongoDB shell version: 2.6.11
connecting to: controller1:27017/test
[object Object]

$ mongo --host controller1 --eval 'printjson(db.isMaster())'
MongoDB shell version: 2.6.11
connecting to: controller1:27017/test
{
    "setName" : "rs0",
    "setVersion" : 1,
    "ismaster" : true,
    "secondary" : false,
    "hosts" : [
        "10.20.102.1:27017",
        "10.20.102.3:27017",
        "10.20.102.2:27017"
    ],
    "primary" : "10.20.102.1:27017",
    "me" : "10.20.102.1:27017",
    "electionId" : ObjectId("58aa81eede69a3420ce55b6d"),
    "maxBsonObjectSize" : 16777216,
    "maxMessageSizeBytes" : 48000000,
    "maxWriteBatchSize" : 1000,
    "localTime" : ISODate("2018-02-26T09:19:54.043Z"),
    "maxWireVersion" : 2,
    "minWireVersion" : 0,
    "ok" : 1
}
```
> 无法执行 show dbs 这样的命令, 报错 SyntaxError: Unexpected identifier

## 三、用户管理
1.查看用户列表：只有切换到 admin 数据库后，执行 `db.system.users.find()` 方法才可以看到
```
> use admin;
switched to db admin
> db.system.users.find()
{ "id" : "test.bascker", "user" : "bascker", "db" : "test", "credentials" : { "MONGODB-CR" : "5cdc5f095e15d76f3bdda2f8f8995940" }, "roles" : [ { "role" : "readWrite", "db" : "test" } ] }
```

2.**添加**用户：`db.createUser(user, writeConcern)`
```
> db.createUser({"user": "bascker", "pwd": "123456", "roles": ["readWrite"]})
Successfully added user: { "user" : "bascker", "roles" : [ "readWrite" ] }
>
> db.getUser("bascker")
{
    "id" : "test.bascker",
    "user" : "bascker",
    "db" : "test",
    "roles" : [
        {
            "role" : "readWrite",
            "db" : "test"
        }
    ]
}
> db.auth("bascker", "123456")
1
```
在创建用户时，可以使用 **build-in roles**(内建的权限)或 **user-defined role**(自定义权限)。

内置权限
* readWrite：读写权限，属于普通用户权限(**Database User Roles**)，每个数据库都有 2 种普通权限(read, readWrite)
* read：只读权限
* dbAdmin：数据库管理权限，属于管理员权限(**Database Administration Roles**)
* clusterAdmin：集群管理权限，数据集群管理员权限(**Cluster Administration Roles**)
> mongodb 权限分3类：**Database User Roles、Database Administration Roles、Cluster Administration Roles**

3.**删除**用户：`db.dropUser(UserName), db.removeUser(UserDoc)` 过时

对于普通用户，可以直接删除
```
rs0:PRIMARY> db.removeUser("bascker")
WARNING: db.removeUser has been deprecated, please use db.dropUser instead
true

rs0:PRIMARY> db.dropUser("bascker")
true
```

但对于特殊用户，如某个 db 的 管理员用户，必须切换到该数据库下，删除数据库，然后删除用户。
```
rs0:PRIMARY> db = db.getSiblingDB("bascker");
bascker
rs0:PRIMARY> db.createUser({user: "bascker", pwd: 123456, roles: [ "readWrite", "dbAdmin" ]})
Successfully added user: { "user" : "bascker", "roles" : [ "readWrite", "dbAdmin" ] }
rs0:PRIMARY>
rs0:PRIMARY>
rs0:PRIMARY> db.getUser("bascker")
{
    "id" : "bascker.bascker",
    "user" : "bascker",
    "db" : "bascker",
    "roles" : [
        {
            "role" : "readWrite",
            "db" : "bascker"
        },
        {
            "role" : "dbAdmin",
            "db" : "bascker"
        }
    ]
}
rs0:PRIMARY>
rs0:PRIMARY> db
admin
rs0:PRIMARY>
rs0:PRIMARY> db.dropUser("bascker")        # 不是 bascker db 则无法删除该用户
false
rs0:PRIMARY>
rs0:PRIMARY> use bascker
switched to db bascker
rs0:PRIMARY>
rs0:PRIMARY> db.dropDatabase()
{ "dropped" : "bascker", "ok" : 1 }
rs0:PRIMARY>
rs0:PRIMARY> db.dropUser("bascker")
true
rs0:PRIMARY>
rs0:PRIMARY> db.getUser("bascker")
null
```