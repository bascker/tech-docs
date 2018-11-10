# 文档
## 一、简介
* 是在Elasticsearch中被存储到唯一ID下的由最高级或者**根对象**(root object)序列化而来的JSON
* 一个文档就相当于关系型 DB 中某个 table 的一条数据
* 文档组成 = 元数据 + 数据
* 文档元数据：必要 3 个
  * _index：指明文档存储的地方
  * _type：指明文档存储的类型
  * _id：指明文档的唯一编号

> _index + _type + _id 组成了唯一的文档标记

## 二、文档ID
文档 ID 既可以自己指定，也可以让 Elasticsearch 自己生成。

### 2.1 自定义 ID
使用 _PUT _方法，在 type 后加上 id 即可。如下所示：
```
$ curl -X PUT 'elastic:9200/bascker/test/6' -d '{"user": "johnnie", "message": "My name is johnnie"}'
{"_index":"bascker","_type":"test","_id":"6","_version":1,"_shards":{"total":2,"successful":1,"failed":0},"created":true}
```

> 注：使用 PUT 方法添加数据，必须得加 id，否则报错  No handler found for uri [/INDIX/TYPE/] and method [PUT]

### 2.2 自增 ID
由 Elasticsearch 自生成的 ID 就是自增 ID。使用 POST 方法就可以自生成 ID。如下所示：
```
$ curl -X POST 'elastic:9200/bascker/test/' -d '{"user": "paul", "message": "My name is paul"}'
{"_index":"bascker","_type":"test","_id":"AVmbFG9km_RLDnunMtmk","_version":1,"_shards":{"total":2,"successful":1,"failed":0},"created":true}

# 查看该文档的 ID
$ curl 'elastic:9200/bascker/test/_search?q=user:paul' | python -m json.tool | grep _id
"_id": "AVmbFG9km_RLDnunMtmk",

# 根据 ID 查看内容
$ curl 'elastic:9200/bascker/test/AVmbFG9km_RLDnunMtmk?pretty'
{
  "_index" : "bascker",
  "_type" : "test",
  "_id" : "AVmbFG9km_RLDnunMtmk",
  "_version" : 1,
  "found" : true,
  "_source" : {
    "user" : "paul",
    "message" : "My name is paul"
  }
}
```