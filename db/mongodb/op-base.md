# 基础操作
进入 mongodb 后台，可以进行基础操作。如简单计算等

## 一、常用工具函数
1.count()：统计结果数
```
> db.mycol.find().count()
4
```

2.pretty()：格式化输出
```
> db.mycol.find({age: 23}).pretty()
{
    "id" : ObjectId("58a4167b285af69d4fc1a0dc"),
    "name" : "paul",
    "age" : 23,
    "sex" : "man"
}
```

## 二、数据库操作
1.显示所有数据库：`show dbs`
```
> show dbs;
admin  (empty)
local  0.078GB
test   0.078GB
```

特殊数据库说明：
* **admin**： 从权限的角度来看，这是"root"数据库。若将一个用户添加到这个数据库，则该用户自动继承所有数据库的权限。一些特定的服务器端命令也只能从这个数据库运行，比如列出所有的数据库或者关闭服务器。
* **local**: 该数据库**永远不会被复制**，可以用来存储限于本地单台服务器的任意集合。
* **config**: 当Mongo用于分片设置时，config数据库在内部使用，**用于保存分片的相关信息**。
> 注：mongodb 中数据库名应全小写，最多 64 字节

2.显示当前数据库：`db`
```
> db
test
```

3.**连接**到指定数据库(**创建**数据库)：`use DBNAME`
使用 use 连接到指定数据库时，若指定的 DBNAME  不存在，则创建
```
# 连接到 admin 数据库
> use admin
switched to db admin

# 创建数据库 bascker
> use bascker
switched to db bascker
> db
bascker

# 查看所有数据库：没有 bascker 数据库，因为此时该数据库并没有数据
> show dbs
admin    (empty)
local    0.078GB
test     0.078GB

# 插入测试数据
> db.bascker.insert({"name": "bascker"})
WriteResult({ "nInserted" : 1 })
>
>
> db.bascker.find()
{ "id" : ObjectId("58a4128e285af69d4fc1a0d9"), "name" : "bascker" }
>
> show dbs
admin    (empty)
bascker  0.078GB
...
```

4.**删除**数据库：`db.dropDatabase()`
```
> use bascker
switched to db bascker
>
> db.dropDatabase()                             # 删除
{ "dropped" : "bascker", "ok" : 1 }
>
> show dbs                                      # 查看结果
admin  (empty)
local  0.078GB
test   0.078GB
>
> db                                            # 查看当前数据库
bascker
>
> db.bascker.insert({"name": "bascker"})        # 再次插入数据
WriteResult({ "nInserted" : 1 })
>
>
> show dbs                                      # 查看结果
admin    (empty)
bascker  0.078GB
local    0.078GB
test     0.078GB
>
```
可以发现，执行删除数据库操作后，虽然使用 show dbs 可以看到该数据库已经没有了，但是执行 db 发现还是处于该数据库中，若再次插入数据
后，使用 show dbs 可以看到数据库又出来了。
> 删除数据库时，必须先切换到该数据库，然后执行删除操作，否则会报错：dropDatabase doesn't take arguments at src/mongo/shell/db.js:141

5.获取数据库对象：`db.getSiblingDB(DBNAME)`

通过 **db.getSiblingDB(DBNAME)**  方法可以获取到某个数据库对象。
```
rs0:PRIMARY> use admin
switched to db admin
rs0:PRIMARY>
rs0:PRIMARY> db
admin
rs0:PRIMARY>
rs0:PRIMARY> db = db.getSiblingDB("local")
local
rs0:PRIMARY> db.getName()
local
rs0:PRIMARY> show collections
me
oplog.rs
slaves
startuplog
system.indexes
system.replset
rs0:PRIMARY>
```

## 三、简单算术运算
mongodb shell 作为一个 javascript shell，因此可以支持简单算术运算。
```
> 2 + 2
4
>
> 1 * 2
2
```

## 四、条件操作符
MongoDB 中有 **5 种**条件操作符，写法类似于 shell。

| mongodb | shell | 说明 |
| :--- | :--- | :--- |
| $gt | -gt | 大于 |
| $gte | -ge | 大于等于 |
| $lt | -lt | 小于 |
| $lte | -le | 小于等于 |
| $ne | -ne | 不等于 |

案例：
```
> db.mycol.find()
{ "id" : ObjectId("58a4167b285af69d4fc1a0dc"), "name" : "paul", "age" : 23, "sex" : "man" }
{ "id" : ObjectId("58a41779285af69d4fc1a0dd"), "name" : "lisa", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
{ "id" : ObjectId("58a41b94ea0a613747ca1c23"), "name" : "Alis", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
{ "id" : ObjectId("58a41daeea0a613747ca1c24"), "name" : "john", "age" : 21, "sex" : "man", "habbit" : "eat, guita" }
>
>
> db.mycol.find({age: {$gt: 21}})
{ "id" : ObjectId("58a4167b285af69d4fc1a0dc"), "name" : "paul", "age" : 23, "sex" : "man" }
>
> db.mycol.find({age: {$lt: 23}}).count()
3
```

## 六、$type
`$type`操作符是基于BSON类型来检索集合中匹配的数据类型，并返回结果。**利用 $type 可以根据数据类型过滤**。每种数据类型，都有一个
数字来表示。如数字 2 代表 String 类型
```
# 检索 mycol 集合中的文档，获取所有符合 name 属性类型为 String 的结果，并统计结果数
> db.mycol.find({"name": {$type: 2}}).count()
4
```

## 七、插入数据
使用 `db.DBNAME.insert(JSON)` 来为数据库新增数据
```
> db.bascker.insert({x:10})
WriteResult({ "nInserted" : 1 })
>
>
> db.bascker.find()
{ "id" : ObjectId("58a4052492f95b6ec373ea14"), "x" : 10 }
```

> 注：mongo shell 支持自动补全，使用 Tab 键即可

## 八、文档操作
1.**插入**文档到集合：`db.COLLECTIONNAME.insert(document)`

使用该方法插入数据时，若集合不存在，则自动创建
> 文档格式和JSON一样，存储在集合中的文档都是**BSON**格式(Binary JSON, 类JSON 的一种二进制形式存储格式)

```
> db
bascker
>
# 直接写入 json 串
> db.mycol.insert({name: "paul", age: "23", sex: "man"})
WriteResult({ "nInserted" : 1 })
>
> db.mycol.findOne()
{
    "id" : ObjectId("58a4167b285af69d4fc1a0dc"),
    "name" : "paul",
    "age" : "23",
    "sex" : "man"
}
>
> use test
switched to db test
>
> db.mycol.findOne()
null

# 以变量方式插入数据
> > use bascker
switched to db bascker
>
> person2 = {name: "lisa", age: 21, sex: "woman"}
{ "name" : "lisa", "age" : 21, "sex" : "woman" }
>
> person2
{ "name" : "lisa", "age" : 21, "sex" : "woman" }
>
> db.mycol.insert(person2)
WriteResult({ "nInserted" : 1 })
>
>
# 查看集合 mycol 中的所有文档
> db.mycol.find()
{ "id" : ObjectId("58a4167b285af69d4fc1a0dc"), "name" : "paul", "age" : "23", "sex" : "man" }
{ "id" : ObjectId("58a41779285af69d4fc1a0dd"), "name" : "lisa", "age" : 21, "sex" : "woman" }
>
# 根据条件查找
> db.mycol.find({name: "lisa"}).pretty()
{
    "id" : ObjectId("58a41779285af69d4fc1a0dd"),
    "name" : "lisa",
    "age" : 21,
    "sex" : "woman"
}
```

2.**更新**文档：`db.COLLECTIONNAME.update()`

update() 语法格式如下：
```
db.COLLECTIONNAME.update(
   <query>,
   <update>,
   {
     upsert: <boolean>,
     multi: <boolean>,
     writeConcern: <document>
   }
)
```

参数说明：
* **query**：查询条件，类似 sql  的 where 语句
* **update**：更新的对象，类似 sql 中 update 语句的 set 部分
* **upsert**：可选参数，若不存在要更新的文档，是否插入。默认为 false
* **multi**：可选参数，是否对符合条件的所有记录进行更新操作，默认为 false，即只更新符合条件的第一条记录
* **writeConcer**：可选参数，抛出异常的级别

案例：
```
> db.mycol.find({age: 21})
{ "id" : ObjectId("58a41779285af69d4fc1a0dd"), "name" : "lisa", "age" : 21, "sex" : "woman"}
{ "id" : ObjectId("58a41b94ea0a613747ca1c23"), "name" : "Alis", "age" : 21, "sex" : "woman", "habbit" : "eat" }
{ "id" : ObjectId("58a41daeea0a613747ca1c24"), "name" : "john", "age" : 21, "sex" : "man", "habbit" : "guita" }
>
>
# 将所有符合条件 age = 21 的文档记录全部更新域 habbit 为 "eat, guita"
> db.mycol.update({age: 21}, {$set: {habbit: "eat, guita"}},{multi: true})
WriteResult({ "nMatched" : 3, "nUpserted" : 0, "nModified" : 3 })
>
> db.mycol.find({age: 21})
{ "id" : ObjectId("58a41779285af69d4fc1a0dd"), "name" : "lisa", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
{ "id" : ObjectId("58a41b94ea0a613747ca1c23"), "name" : "Alis", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
{ "id" : ObjectId("58a41daeea0a613747ca1c24"), "name" : "john", "age" : 21, "sex" : "man", "habbit" : "eat, guita" }
>
```

3.**替换**文档：`db.COLLECTIONNAME.save()`

save()用于将传入的文档**替换**掉已有的文档。其语法格式如下：
```
db.COLLECTIONNAME.save(
   <document>,
   {
     writeConcern: <document>
   }
)
```

案例：
```
> db.mycol.find({name: "Alis"})
{ "id" : ObjectId("58a41b94ea0a613747ca1c23"), "name" : "Alis", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
>
# 更新指定 id 的文档记录
> db.mycol.save({id: ObjectId("58a41b94ea0a613747ca1c23"), "name" : "Alis", "age" : 21, "sex" : "woman", "habbit" : "eat"})
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
>
> db.mycol.find({name: "Alis"})
{ "id" : ObjectId("58a41b94ea0a613747ca1c23"), "name" : "Alis", "age" : 21, "sex" : "woman", "habbit" : "eat" }
>
```

使用 save() 时，**只有在指定 id 属性时，才会替换已存在的文档**，否则会新增一篇文档。
```
> db.mycol.save({name: "Alis", age: 22, sex: "woman"})
WriteResult({ "nInserted" : 1 })
>
> db.mycol.find({name: "Alis"})
{ "id" : ObjectId("58a41b94ea0a613747ca1c23"), "name" : "Alis", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
{ "id" : ObjectId("58a41f27ea0a613747ca1c25"), "name" : "Alis", "age" : 22, "sex" : "woman" }
```

4.**删除**文档：`db.COLLECTIONNAME.remove()`

remove()语法格式如下所示：
```
db.COLLECTIONNAME.remove(
   <query>,
   {
     justOne: <boolean>,
     writeConcern: <document>
   }
)
```

参数说明：
* **query**：可选，根据条件删除。若不指定，则删除所有文档
* **justOne**：可选，如果设为 true 或 1，则只删除一个文档

> 注：只有 2.6 以后的版本才支持 writeConcern

案例：
```
> db.mycol.remove({id: ObjectId("58a41f27ea0a613747ca1c25")})
WriteResult({ "nRemoved" : 1 })
>
> db.mycol.find({name: "Alis"})
{ "id" : ObjectId("58a41b94ea0a613747ca1c23"), "name" : "Alis", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
>
```

5.**查询**文档：`db.COLLECTIONNAME.find() ，db.COLLECTIONNAME.findOne()`
* find() 和 findOne() 都可用于根据条件查询稳定。
* 若不指定条件，则find()会获取所有文档，findOne()获取集合中的第一个文档。
* find()查询结果不会进行自动格式化，需要连缀方式调用 pretty() 才进行格式化，而findOne()自动格式化输出。
* **AND查询**(多条件查询)：多条件查询时，传入的JSON串中以逗号分割键值对即可
* **OR查询**：mongodb的或查询需要使用关键字 **$or**, 格式如下
  ```
  >db.COLLECTIONNAME.find(
     {
        $or: [
           {key1: value1}, {key2:value2}
        ]
     }
  ).pretty()
  ```

OR查询案例：查询 sex 为 man 或者 name 为 paul 的记录
```
> db.mycol.find({$or: [{sex: "man"}, {name: "paul"}]})
{ "id" : ObjectId("58a4167b285af69d4fc1a0dc"), "name" : "paul", "age" : "23", "sex" : "man" }
{ "id" : ObjectId("58a41daeea0a613747ca1c24"), "name" : "john", "age" : 21, "sex" : "man", "habbit" : "eat, guita" }
```

6.**删除**集合：`db.COLLECTIONNAME.drop()`
```
rs0:PRIMARY> show collections
cols
rs0:PRIMARY> db.cols.drop()
true
```

## 九、分页：limit() + skip()
利用 limit() 和 skip() 方法可以达到分页的效果。

1.读取指定数量数据记录：`db.COLLECTIONNAME.find().limit(NUMBER)`
```
> db.mycol.find().limit(2)
{ "id" : ObjectId("58a4167b285af69d4fc1a0dc"), "name" : "paul", "age" : 23, "sex" : "man" }
{ "id" : ObjectId("58a41779285af69d4fc1a0dd"), "name" : "lisa", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
```

2.跳过指定数量数据记录：`db.COLLECTIONNAME.find().skip(NUMBER)`
```
> db.mycol.find().skip(2)
{ "id" : ObjectId("58a41b94ea0a613747ca1c23"), "name" : "Alis", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
{ "id" : ObjectId("58a41daeea0a613747ca1c24"), "name" : "john", "age" : 21, "sex" : "man", "habbit" : "eat, guita" }
```

3.分页效果：limit() + skip()
```
# 总记录数 4 条，分 2 页，每页 2 条记录
# 第一页
> db.mycol.find().limit(2)
{ "id" : ObjectId("58a4167b285af69d4fc1a0dc"), "name" : "paul", "age" : 23, "sex" : "man" }
{ "id" : ObjectId("58a41779285af69d4fc1a0dd"), "name" : "lisa", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
>
# 第二页
> db.mycol.find().skip(2).limit(2)
{ "id" : ObjectId("58a41b94ea0a613747ca1c23"), "name" : "Alis", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
{ "id" : ObjectId("58a41daeea0a613747ca1c24"), "name" : "john", "age" : 21, "sex" : "man", "habbit" : "eat, guita" }
```

## 十、排序：sort()
`sort()`用于对数据进行排序。可以通过参数指定排序的字段，并使用 1 和 -1 来指定排序的方式，其中 1 为**升序**，而 -1是用于**降序**。

> 使用 find() 时默认按照 id 升序排序
```
> db.mycol.find()
{ "id" : ObjectId("58a4167b285af69d4fc1a0dc"), "name" : "paul", "age" : 23, "sex" : "man" }
{ "id" : ObjectId("58a41779285af69d4fc1a0dd"), "name" : "lisa", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
{ "id" : ObjectId("58a41b94ea0a613747ca1c23"), "name" : "Alis", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
{ "id" : ObjectId("58a41daeea0a613747ca1c24"), "name" : "john", "age" : 21, "sex" : "man", "habbit" : "eat, guita" }
>
> db.mycol.find().sort({name: 1})
{ "id" : ObjectId("58a41b94ea0a613747ca1c23"), "name" : "Alis", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
{ "id" : ObjectId("58a41daeea0a613747ca1c24"), "name" : "john", "age" : 21, "sex" : "man", "habbit" : "eat, guita" }
{ "id" : ObjectId("58a41779285af69d4fc1a0dd"), "name" : "lisa", "age" : 21, "sex" : "woman", "habbit" : "eat, guita" }
{ "id" : ObjectId("58a4167b285af69d4fc1a0dc"), "name" : "paul", "age" : 23, "sex" : "man" }
```

## 十一、索引
索引是一种特殊的数据结构，存储在一个易于遍历读取的数据集合中。利用索引通常能够极大的提高查询的效率，
**如果没有索引**，MongoDB在读取数据时必须进行**全集合扫描**(扫描集合中的每个文件)并选取那些符合查询条件的记录。

1.创建索引：`db.COLLECTIONNAME.ensureIndex()`

语法格式：
```
db.COLLECTIONNAME.ensureIndex( {KEY: 1 or -1},
                                {
                                  background: <Boolean>,
                                  unique: <Boolean>,
                                  name: <string>,
                                  dropDups: <Boolean>,
                                  sparse: <Boolean>,
                                  expireAfterSeconds: <integer>,
                                  v: <index version>,
                                  weights: <document>,
                                  defaultlanguage: <string>,
                                  languageoverride: <string>
                                }
                               )
```

参数说明：
* KEY：想要创建索引的字段
* 1 or -1：排序方式，升序或降序
* background：是否以**后台方式**创建索引。默认为 false，建索引过程会阻塞其它数据库操作
* unique：建立的索引是否唯一
* name：索引名，若不指定，则通过连接索引的字段名和排序顺序生成一个索引名称
* dropDups：建立唯一索引时是否删除重复记录
* sparse：对文档中不存在的字段数据不启用索引。true 表示在索引字段中不会查询出不包含对应字段的文档
* expireAfterSeconds：设定集合的生存时间，秒级单位
* v：索引的版本号。默认的索引版本取决于mongod创建索引时运行的版本
* weights：索引权重值，数值在 1 到 99,999 之间，表示该索引相对于其他索引字段的得分权重
* defaultlanguage：对于文本索引，该参数决定了停用词及词干和词器的规则的列表。 默认为英语
* languageoverride：对于文本索引，该参数指定了包含在文档中的字段名，语言覆盖默认的language，默认值为 language

> 若想多字段索引，使用逗号分割。在RDBMS 中称为“复合索引”

案例：根据 age 字段后台方式创建索引
```
> db.mycol.ensureIndex({age: 1}, {background: true})
{
    "createdCollectionAutomatically" : false,
    "numIndexesBefore" : 1,
    "numIndexesAfter" : 2,
    "ok" : 1
}
```

## 十二、聚合 aggregate
MongoDB 的 aggregate 主要用于处理数据，如统计平均值，求和等。类似SQL中的 count(*)

语法格式：
```
db.COLLECTIONNAME.aggregate(AGGREGATEOPERATION)
```

聚合表达式：

| **表达式** | **描述** |
| :--- | :--- |
| $sum | 求总和 |
| $avg | 求平均值 |
| $min | 求最小值 |
| $max | 求最大值 |
| $push | 在结果文档中插入值到一个数组中 |
| $addToTest | 在结果文档中插入值到一个数组中，但不创建副本 |
| $first | 根据资源文档的排序获取**第一个**文档数据 |
| $last | 根据资源文档的排序获取**最后一个**文档数据 |

案例：获取云上云下资源的总计量项
```
rs0:PRIMARY> db
ceilometer
rs0:PRIMARY>
# 按 source 进行分组，并计算 source 相同值的总数
rs0:PRIMARY> db.meter.aggregate([{$group: {id: "$source", numtutorial: {$sum: 1}}}])
{ "id" : "hardware", "numtutorial" : 612954 }
{ "id" : "openstack", "numtutorial" : 156856 }
# 对应 sql 语句：select byuser, count(*) from mycol group by byuser
rs0:PRIMARY>
rs0:PRIMARY> db.meter.count()
769810
rs0:PRIMARY> db.meter.count({"source": "openstack"})
156856
```

## 十三、聚合管道
MongoDB的**聚合管道**将MongoDB文档在一个管道处理完毕后将结果传递给下一个管道处理。管道操作是可以重复的

聚合框架中常用操作

| **管道操作符** | **描述** |
| :--- | :--- |
| $project | 修改输入文档的结构。可以用来重命名、增加或删除域，也可以用于创建计算结果以及嵌套文档 |
| $match | 用于过滤数据，只输出符合条件的文档。$match使用MongoDB的标准查询操作 |
| $limit | 分页操作，用于限制结果返回数 |
| $skip | 分页操作，跳过指定数量文档 |
| $unwind | 将文档中的某一个数组类型字段拆分成多条，每条包含数组中的一个值 |
| $group | 将集合中的文档分组，可用于统计结果 |
| $sort | 将输入文档排序后输出 |
| $geoNear | 输出接近某一地理位置的有序文档 |