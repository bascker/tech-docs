# 后端存储
## 简介

ceilometer后端存储数据库支持 mysql、mongodb(默认)、gnocchi等。控制其后端存储方式的配置文件是 **ceilometer.conf**
```
[database]
event_connection = ....
metering_connection = ...
```

## 后端存储之mysql

要使用 mysql 作为其后端存储，主要步骤如下：
> 注：event、meter 数据的存储可以是不同数据库

1.**修改 ceilometer.conf**
```
$ vim ceilometer.conf
event_connection = mysql+pymysql://ceilometer:PASS@mariadb:3306/ceilometer
metering_connection = mysql+pymysql://ceilometer:PASS@mariadb:3306/ceilometer
```

> 格式：mysql+pymysql://{{ ceilometer\_database\_user }}:{{ ceilometer\_database\_password }}@{{ ceilometer\_database\_mysql\_address }}/{{ ceilometer\_database\_name }}

2.mysql 中创建 ceilometer 数据库
```
$ show databases;
+--------------------+
| Database           |
+--------------------+
| ceilometer         |
+--------------------+
```

3.mysql 中创建 ceilometer 用户，并赋予其操作 ceilometer 数据库的权限
```
$ insert into user(Host, User, Password) values("%", "ceilometer", "CEILOMETER_DB_PASSWD");
$ grant all privileges on ceilometer.* to 'ceilometer'@'%' identified by 'CEILOMETER_DB_PASSWD';
```

4.mysql 中创建 ceilometer 数据库需要的表
```
$ show tables;
+----------------------+
| Tables_in_ceilometer |
+----------------------+
| event                |
| event_type           |
| metadata_bool        |
| metadata_float       |
| metadata_int         |
| metadata_text        |
| meter                |
| migrate_version      |
| resource             |
| sample               |
| trait_datetime       |
| trait_float          |
| trait_int            |
| trait_text           |
+----------------------+
14 rows in set (0.00 sec)
```
做好以上操作后，ceilometer 收集的数据将存储到 ceilometer 数据库对应的表中

## 后端存储之 mongodb
ceilometer 虽然支持很多类型的数据库，但其默认的后端存储是 mongodb。使用 mongodb 作为 ceilometer 的后端 DB 性能会比使用 mysql 高。其配置流程如下：
1.修改 ceilometer.conf
```
$ vim ceilometer.conf
event_connection = mongodb://ceilometer:123456@mongodb:27017/ceilometer
metering_connection = mongodb://ceilometer:123456@mongodb:27017/ceilometer
```

2.mongodb 中创建 ceilometer 数据库，ceilometer 用户以及赋权
```
$ mongo --host mongodb-master
        --eval 'db = db.getSiblingDB("ceilometer");
                db.createUser({user: "ceilometer",
                               pwd: "PASSWD",
                               roles: [ "readWrite", "dbAdmin" ]})'
```

3.执行完毕后上述步骤后即可。不需要特意去创建集合(表)，ceilometer 在存储数据时会自动处理
```
# 查看 mongodb 日志
$ vim mongodb.log
2017-02-20T10:30:22.667+0800 [rsSync] replSet initial sync pending
2017-02-20T10:30:22.667+0800 [rsSync] replSet syncing to: 10.20.102.2:27017
2017-02-20T10:30:22.673+0800 [rsSync] build index on: local.replset.minvalid properties: { v: 1, key: { _id: 1 }, name: "_id_", ns: "local.replset.minvalid" }
2017-02-20T10:30:22.673+0800 [rsSync]    added index to empty collection
2017-02-20T10:30:22.673+0800 [rsSync] replSet initial sync drop all databases
2017-02-20T10:30:22.673+0800 [rsSync] dropAllDatabasesExceptLocal 1
2017-02-20T10:30:22.673+0800 [rsSync] replSet initial sync clone all databases
2017-02-20T10:30:22.674+0800 [rsSync] replSet initial sync cloning db: admin
2017-02-20T10:30:22.675+0800 [rsSync] replSet initial sync data copy, starting syncup
2017-02-20T10:30:22.678+0800 [rsSync] oplog sync 1 of 3
2017-02-20T10:30:22.679+0800 [rsSync] oplog sync 2 of 3
2017-02-20T10:30:22.679+0800 [rsSync] replSet initial sync building indexes
2017-02-20T10:30:22.679+0800 [rsSync] replSet initial sync cloning indexes for : admin
2017-02-20T10:30:22.679+0800 [rsSync] oplog sync 3 of 3
2017-02-20T10:30:22.680+0800 [rsSync] replSet initial sync finishing up
2017-02-20T10:30:22.701+0800 [rsSync] replSet set minValid=58aa54ad:1
2017-02-20T10:30:22.703+0800 [rsSync] replSet RECOVERING
2017-02-20T10:30:22.703+0800 [rsSync] replSet initial sync done

# mongodb 中验证：此时仅有 用户，还没有 ceilometer 数据库，因为没存入数据
rs0:PRIMARY> use admin
switched to db admin
rs0:PRIMARY>
rs0:PRIMARY> show collections
system.indexes
system.users
system.version
rs0:PRIMARY>
rs0:PRIMARY> db.system.users.findOne({user: "ceilometer"})
{
	"_id" : "ceilometer.ceilometer",
	"user" : "ceilometer",
	"db" : "ceilometer",
	"credentials" : {
		"MONGODB-CR" : "1d748d763f575355bdbbe78063ce9ef6"
	},
	"roles" : [
		{
			"role" : "readWrite",
			"db" : "ceilometer"
		},
		{
			"role" : "dbAdmin",
			"db" : "ceilometer"
		}
	]
}

# 创建镜像资源(glance image-create)，让 ceilometer 收集数据存储到 mongodb
rs0:PRIMARY> show dbs;
ceilometer   0.078GB

rs0:PRIMARY> use ceilometer;
switched to db ceilometer
rs0:PRIMARY>
rs0:PRIMARY> show collections;
event
meter
resource
system.indexes
rs0:PRIMARY> db.resource.findOne()
{
	"_id" : "3f18e57a-d514-43a5-ae34-1fdaa56e2906",
	"source" : "openstack",
	"project_id" : "2212062c347d4687b5462d7f7c3003b8",
	"user_id" : null,
	"first_sample_timestamp" : ISODate("2017-02-23T03:47:08.141Z"),
	"last_sample_timestamp" : ISODate("2017-02-23T06:15:31.443Z"),
	"metadata" : {
		"status" : "active",
		"name" : "cirros2",
		"tags" : [ ],
		"container_format" : "bare",
		"created_at" : "2017-02-23T03:47:04Z",
		"disk_format" : "qcow2",
		"updated_at" : "2017-02-23T03:47:08Z",
		"visibility" : "public",
		"protected" : false,
		"checksum" : "ee1eca47dc88f4879d8a229cc70a07c6",
		"min_disk" : 0,
		"virtual_size" : null,
		"min_ram" : 0
	},
	"meter" : [
		{
			"counter_name" : "image.size",
			"counter_unit" : "B",
			"counter_type" : "gauge"
		},
		{
			"counter_name" : "image",
			"counter_unit" : "image",
			"counter_type" : "gauge"
		}
	]
}
rs0:PRIMARY> db.meter.findOne()
{
	"_id" : ObjectId("58b143fbec15840019be69e6"),
	"counter_name" : "image",
	"user_id" : null,
	"resource_id" : "3f18e57a-d514-43a5-ae34-1fdaa56e2906",
	"timestamp" : ISODate("2017-02-25T08:44:43.176Z"),
	"message_signature" : "00124dba6badccfe3410f18d046a1e30ba241b09f931c029b806efa5a01337cf",
	"resource_metadata" : {
		"status" : "active",
		"name" : "cirros2",
		"tags" : [ ],
		"container_format" : "bare",
		"created_at" : "2017-02-23T03:47:04Z",
		"disk_format" : "qcow2",
		"updated_at" : "2017-02-23T03:47:08Z",
		"visibility" : "public",
		"protected" : false,
		"checksum" : "ee1eca47dc88f4879d8a229cc70a07c6",
		"min_disk" : 0,
		"virtual_size" : null,
		"min_ram" : 0
	},
	"source" : "openstack",
	"counter_unit" : "image",
	"counter_volume" : 1,
	"recorded_at" : ISODate("2017-02-25T08:44:43.599Z"),
	"project_id" : "2212062c347d4687b5462d7f7c3003b8",
	"message_id" : "a71b790e-fb36-11e6-83c6-0242a4a0f226",
	"counter_type" : "gauge"
}
```

> 后端存储之 gnocchi：用于解决Ceilometer性能问题负责多租户的时间序列化、度量、资源数据库。目前没用过