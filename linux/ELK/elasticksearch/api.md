# API
* [查询](#query)
  * [查询所有index](#query_indices)
  * [查询指定index](#query_index)
  * [查询部分属性](#query_attrs)
  * [只查看文档存储数据](#query_datas)
  * [获取多个文档](#query_docs)
* [搜索](#search)
* [删除](#delete)
* [增加](#add)
* [批处理](#batch)
* [更新](#update)

<b id="query"></b>
## 一、查询
<b id="query_indices"></b>
1.列出所有 index
```
$ curl -i http://elastic:9200/_cat/indices?v
HTTP/1.1 200 OK
Content-Type: text/plain; charset=UTF-8
Content-Length: 704

health status index          pri rep docs.count docs.deleted store.size pri.store.size
yellow open   log-2018.01.08   5   1      23121            0        7mb            7mb
yellow open   log-2018.01.10   5   1       4735            0      1.5mb          1.5mb
```

<b id="query_index"></b>
2.查看指定的 index: 加上 `?pretty` 会格式化 json 串
```
# 显示指定 index 的结构
$ curl -i http://elastic:9200/log-2018.01.08?pretty
HTTP/1.1 200 OK
Content-Type: application/json; charset=UTF-8
Content-Length: 1971

{
  "log-2018.01.08" : {
    "aliases" : { },
    "mappings" : {
      "message" : {
        "properties" : {
          "Hostname" : {
            "type" : "string"
          },
          ...
          "python_module" : {
            "type" : "string"
          },
          "request_id" : {
            "type" : "string"
          },
          "severity_label" : {
            "type" : "string"
          },
          "syslogfacility" : {
            "type" : "long"
          },
          "tenant_id" : {
            "type" : "string"
          },
          "user_id" : {
            "type" : "string"
          }
        }
      }
    },
    "settings" : {
      "index" : {
        "creation_date" : "1483833625786",
        "uuid" : "0drApHDRTMWzZsIsuwdi2w",
        "number_of_replicas" : "1",
        "number_of_shards" : "5",
        "version" : {
          "created" : "2040199"
        }
      }
    },
    "warmers" : { }
  }
}
```

<b id="query_attrs"></b>
3.查看某文档的部分属性值：`_source` 的使用
```
# 只获取文档的 content 和 modul 属性值
$ curl 'elastic:9200/github-2018.01.10/ceilometer/AVmHuCtvm_RLDnunMYID?_source=content,modul' | python -m json.tool
{
    "_id": "AVmHuCtvm_RLDnunMYID",
    "_index": "github-2018.01.10",
    "_source": {
        "content": "Cannot inspect data of MemoryUsagePollster for 09de795d-828e-49c8-a661-35e81db06f2e, non-fatal reason: Failed to inspect memory usage of instance <name=instance-0000008f, id=09de795d-828e-49c8-a661-35e81db06f2e>, can not get info from libvirt.",
        "modul": "ceilometer.compute.pollsters.memory"
    },
    "_type": "ceilometer",
    "_version": 1,
    "found": true
}
```

<b id="query_datas"></b>
4.只查看文档存储数据，不看其他元数据：_source 的使用
```
$ curl 'elastic:9200/github-2018.01.10/ceilometer/AVmHuCtvm_RLDnunMYID/_source' | python -m json.tool
{
    "@timestamp": "2018-01-10T17:30:57+08:00",
    "content": "Cannot inspect data of MemoryUsagePollster for 09de795d-828e-49c8-a661-35e81db06f2e, non-fatal reason: Failed to inspect memory usage of instance <name=instance-0000008f, id=09de795d-828e-49c8-a661-35e81db06f2e>, can not get info from libvirt.",
    "id": "28247",
    "level": "WARNING",
    "location": "ceilometer.api",
    "modul": "ceilometer.compute.pollsters.memory",
    "occurTime": "2018-01-05 16:48:55.191",
    "requestID": "[-]"
}
```

<b id="query_docs"></b>
5.获取多个文档：_mget 的使用
```
# docs 数组：分别从 index 为 bascker 和 github 下获取一篇符合查询条件的文档
$ curl 'elastic:9200/_mget?pretty' 、
    -d '{"docs": [{"_index": "bascker", "_type": "test", "_id": 1}, {"_index": "github-2018.01.10", "_type": "ceilometer", "_id": "AVmHuCtvm_RLDnunMYID"}]}'
{
  "docs" : [ {
    "_index" : "bascker",
    "_type" : "test",
    "_id" : "1",
    "_version" : 1,
    "found" : true,
    "_source" : {
      "user" : "bascker",
      "post_date" : "2018-01-13",
      "message" : "Just a test"
    }
  }, {
    "_index" : "github-2018.01.10",
    "_type" : "ceilometer",
    "_id" : "AVmHuCtvm_RLDnunMYID",
    "_version" : 5,
    "found" : true,
    "_source" : {
      "id" : "30001",
      "modul" : "ceilometer",
      "name" : "paul"
    }
  } ]
}

# ids 数组：从同 index，同 type 下获取 2 篇文档
$ curl 'elastic:9200/bascker/test/_mget?pretty' -d '{"ids": ["1", "2"]}'
{
  "docs" : [ {
    "_index" : "bascker",
    "_type" : "test",
    "_id" : "1",
    "_version" : 1,
    "found" : true,
    "_source" : {
      "user" : "bascker",
      "post_date" : "2018-01-13",
      "message" : "Just a test"
    }
  }, {
    "_index" : "bascker",
    "_type" : "test",
    "_id" : "2",
    "_version" : 2,
    "found" : true,
    "_source" : {
      "user" : "bascker3",
      "post_date" : "2018-01-13",
      "message" : "Just a test"
    }
  } ]
}
```

<b id="search"></b>
## 二、搜索
| **URL** | **描述**
| :--- | :---
| _search | 全文搜索/空白搜索
| _search?q=mary | 搜索所有带 mary 字符串的文档
| /gb*/_search | 搜索所有以gb为前缀的indices的文档
| /gb,us/_search | 同时搜索gb 和 us 内的文档
| /gb/test/_search | 搜索gb下type为test的所有文档
| /gb,us/user,tweet/_search | 搜索索引gb和索引us中类型user以及类型 tweet 内的所有文档
| /_all/user,tweet/_search | 搜索所有索引中类型为user以及tweet内的所有文档
| /_search?size=5 | 每次返回 5 条数据。size 默认为 10
| GET /_search?size=5&from=10 | 每次返回 5 条数据，忽略前 10 条数据。from 默认为 0

对于分页搜索，不要一次请求过多或者页码过大的结果。以搜索拥有5个主分片的索引的第1000页(第10001~10010数据)的结果为例，说明分页搜索的原理。
1. 请求节点发送搜索请求到每个分片(总共5个)
2. 每个分片产生前10010个结果(1000页，每页默认 10 条)，并排序
3. 请求节点获取所有结果(50050条)
4. 请求节点对数据(50050条数据)排序，抛弃其中 50040 条
5. 返回搜索结果

分布式系统中，大页码请求所消耗的系统资源是呈指数式增长的，太耗费性能。
> Note: mysql 中的分页查询也是先获取所有数据，然后抛弃一部分数据，再返回结果的

### 2.1 全文检索
全文检索（空白检索），不加任何查询条件的，只是返回集群中所有文档的搜索
```
$ curl -X GET http://10.20.0.253:9200/log-2018.01.10/_search?pretty
{
  "took" : 2,           # 搜索耗时，单位：毫秒
  "timed_out" : false,  # 搜索是否超时
  "_shards" : {         # 参与查询分片的总数
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 24552,
    "max_score" : 1.0,   # 显示所有匹配文档中的_score的最大值
    "hits" : [{          # hits 指明匹配的文档总数，默认返回前十个结果
      ....
    }, {
      "_index" : "log-2018.01.10",
      "_type" : "message",
      "_id" : "AVmFrdNym_RLDnunMVfu",
      "_score" : 1.0,    # _score：文档相关性评分，表示当前文档与查询的匹配程度。默认按照_score由高至低进行排列
      "_source" : {
        "Timestamp" : "2018-01-10T00:01:17",
        "Type" : "log",
        "Logger" : "openstack.nova",
        "Severity" : 6,
        "Payload" : "[req-69928afa-2345-48a5-8a20-a68652e9f76f - - - - -] Successfully synced instances from host 'kolla-com1'.\n",
        "Pid" : 7,
        "Hostname" : "kolla-con1",
        "python_module" : "nova.scheduler.host_manager",
        "programname" : "nova-scheduler",
        "severity_label" : "INFO",
        "request_id" : "69928afa-2345-48a5-8a20-a68652e9f76f"
      }
    } ]
  }
}
```
1. 若在 _search 之前未指定索引，则默认使用最古老的 index 值。如此处就会默认查 log-2018.01.08
2. timeout 并不会终止查询，它只是会在你指定的时间内返回当时已经查询到的数据，然后关闭连接。在后台，其他的查询可能会依旧继续，尽管查询结果已经被返回
3. 在索引中搜索时，Elasticsearch 会将搜索请求转发给相应索引中的**所有**主从分片，然后收集每个分片的结果

### 2.2 支持正则的搜索
```
# 搜索所有以 github 开头的索引内的文档，并返回
$ curl 'elastic:9200/github*/_search?pretty'
```

### 2.3 查询字符串搜索
```
# 检索名字 github 下 employ 中 user 属性为 paul 的数据
$ curl -X GET http://elastic:9200/github/employ/_search?q=username:paul | python -m json.tool
{
    "_shards": {
        "failed": 0,
        "successful": 5,
        "total": 5
    },
    "hits": {
        "hits": [
            {
                "_id": "2",
                "_index": "github",
                "_score": 0.028130025,
                "_source": {
                    "age": 22,
                    "username": "Paul"
                },
                "_type": "employ"
            }
        ],
        "max_score": 0.028130025,
        "total": 1
    },
    "timed_out": false,
    "took": 3
}
```

### 2.4 query dsl 搜索
Elasticsearch 提供的查询语言，使用 JSON  作为主体进行查询
```
# 查询匹配 username 为 john 的数据
$ curl -X GET http://elastic:9200/github/employ/_search \
 -d '{"query": {"match": {"username": "john"}}}' | python -m json.tool
{
    "_shards": {
        "failed": 0,
        "successful": 5,
        "total": 5
    },
    "hits": {
        "hits": [
            {
                "_id": "1",
                "_index": "github",
                "_score": 0.30685282,
                "_source": {
                    "age": 21,
                    "username": "John"
                },
                "_type": "employ"
            }
        ],
        "max_score": 0.30685282,
        "total": 1
    },
    "timed_out": false,
    "took": 2
}

# 添加过滤器：搜索 age > 20 且名字为 paul 的记录
$ curl -X GET http://elastic:9200/github/employ/_search \
 -d '{"query": {
         "filtered": {
             "filter": {
                 "range": {
                     "age": {"gt": 20}
                  }
              }
          },
          "query": {"macth": {"username": "paul"}}
       }' | python -m json.tool
```

### 2.5 检索排序
使用 query dsl + sort 参数，根据文档 _source 内的某属性值，对查询结果进行排序
> 注：可根据多个属性值进行排序，排序结果按 sort 中指定的属性字段顺序来
```
# 按 id 降序排序
$ curl http://elastic:9200/github-2018.01.10/_search?pretty -d '{"sort": {"id": {"order": "desc"}}}'
{
  "took" : 834,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 4,
    "max_score" : null,
    "hits" : [ {
      "_index" : "github-2018.01.10",
      "_type" : "ceilometer",
      "_id" : "AVmHuCtvm_RLDnunMYID",
      "_score" : null,
      "_source" : {
        "id" : "30001",
        "modul" : "ceilometer",
        "name" : "paul"
      },
      "sort" : [ "30001" ]
    }, {
      "_index" : "github-2018.01.10",
      "_type" : "ceilometer",
      "_id" : "AVmHuCtvm_RLDnunMYIG",
      "_score" : null,
      "_source" : {
        "occurTime" : "2018-01-05 16:48:55.191",
        "id" : "28247",
        "level" : "WARNING",
        "modul" : "ceilometer.compute.pollsters.memory",
        "requestID" : "[-]",
        "content" : "Cannot inspect data of MemoryUsagePollster for 09de795d-828e-49c8-a661-35e81db06f2e, non-fatal reason: Failed to inspect memory usage of instance <name=instance-0000008f, id=09de795d-828e-49c8-a661-35e81db06f2e>, can not get info from libvirt.",
        "@timestamp" : "2018-01-10T17:31:04+08:00",
        "location" : "ceilometer.api"
      },
      "sort" : [ "28247" ]
    }, {
      "_index" : "github-2018.01.10",
      "_type" : "ceilometer",
      "_id" : "AVmHuCtvm_RLDnunMYIE",
      "_score" : null,
      "_source" : {
        "occurTime" : "2018-01-05 16:48:55.191",
        "id" : "28247",
        "level" : "WARNING",
        "modul" : "ceilometer.compute.pollsters.memory",
        "requestID" : "[-]",
        "content" : "Cannot inspect data of MemoryUsagePollster for 09de795d-828e-49c8-a661-35e81db06f2e, non-fatal reason: Failed to inspect memory usage of instance <name=instance-0000008f, id=09de795d-828e-49c8-a661-35e81db06f2e>, can not get info from libvirt.",
        "@timestamp" : "2018-01-10T17:30:57+08:00",
        "location" : "ceilometer.api"
      },
      "sort" : [ "28247" ]
    }, {
      "_index" : "github-2018.01.10",
      "_type" : "ceilometer",
      "_id" : "AVmHuCtvm_RLDnunMYIF",
      "_score" : null,
      "_source" : {
        "occurTime" : "2018-01-05 16:48:55.191",
        "id" : "28247",
        "level" : "WARNING",
        "modul" : "ceilometer.compute.pollsters.memory",
        "requestID" : "[-]",
        "content" : "Cannot inspect data of MemoryUsagePollster for 09de795d-828e-49c8-a661-35e81db06f2e, non-fatal reason: Failed to inspect memory usage of instance <name=instance-0000008f, id=09de795d-828e-49c8-a661-35e81db06f2e>, can not get info from libvirt.",
        "@timestamp" : "2018-01-10T17:30:58+08:00",
        "location" : "ceilometer.api"
      },
      "sort" : [ "28247" ]
    } ]
  }
}

# 按 occurTime 降序排序
$ curl http://elastic:9200/github-2018.01.10/_search?pretty -d '{"sort": {"occurTime": {"order": "desc"}}}'
```

### 2.6 段落检索
使用 query dsl，改 match  为 match_phrase
> 在 DSL 查询时，可以使用 highlight 来进行结果高亮
```
$ curl -X GET http://elastic:9200/github/employ/_search \
 -d '{"query": {"match_phrase": {"username": "john"}}}' | python -m json.tool
{
    "_shards": {
        "failed": 0,
        "successful": 5,
        "total": 5
    },
    "hits": {
        "hits": [
            {
                "_id": "1",
                "_index": "github",
                "_score": 0.30685282,
                "_source": {
                    "age": 21,
                    "username": "John"
                },
                "_type": "employ"
            }
        ],
        "max_score": 0.30685282,
        "total": 1
    },
    "timed_out": false,
    "took": 2
}
```

<b id="delete"></b>
## 三、删除
删除指定 index，删除一个文档并**不会立即删除(之后还是会删除)**，只是在Elasticsearch内部标记成已删除，不能继续访问，因此仅调用DELETE删除会有数据残留
```
$ curl -i -X DELETE http://elastic:9200/log-2018.01.04?pretty
HTTP/1.1 200 OK
Content-Type: application/json; charset=UTF-8
Content-Length: 28

{
  "acknowledged" : true
}
```

<b id="add"></b>
## 四、增加
增加一条新数据：创建一个名为 bascker 的 index，其 type 为 test, 其 id 为 1。类比 mysql 就是创建数据库 bascker，并在其创建表 test，然后插入一条数据，
其 id 为 1。
> 若已经存在一个 id 为 2 的文档，则覆盖掉旧的文档(更新)，并更新文档的 _version 值和更改 created 为 false
```
$ curl -X PUT http://elastic:9200/bascker/test/1?pretty -d '{"user": "bascker", "post_date": "2018-01-13", "message": "Just a test"}'
{
  "_index" : "bascker",
  "_type" : "test",
  "_id" : "1",
  "_version" : 1,
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "created" : true
}

$ curl http://elastic:9200/_cat/indices?v
yellow open   bascker               5   1          1            0       130b           130b

# 查询
$ curl -X GET http://elastic:9200/bascker/test/1?pretty
{
  "_index" : "bascker",
  "_type" : "test",
  "_id" : "1",
  "_version" : 1,
  "found" : true,
  "_source" : {
    "user" : "bascker",
    "post_date" : "2018-01-13",
    "message" : "Just a test"
  }
}

# 检索：默认返回最开始的 10 条数据
$ curl http://elastic:9200/bascker/_search?pretty
{
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 1,
    "max_score" : 1.0,
    "hits" : [ {
      "_index" : "bascker",
      "_type" : "test",
      "_id" : "1",
      "_score" : 1.0,
      "_source" : {
        "user" : "bascker",
        "post_date" : "2018-01-13",
        "message" : "Just a test"
      }
    } ]
  }
}
```

<b id="batch"></b>
## 五、数据批处理
bluk API可以帮助进行数据批处理，极大提高效率。`bulk`的请求主体的格式稍微有些不同，类似于一个用 "\n" 字符来连接的单行json。如下：
```
{ action: { metadata }}\n
{ request body        }\n
{ action: { metadata }}\n
{ request body        }\n
...
```
每一个子请求都会被单独执行，因此一旦有一个子请求失败了，并不会影响到其他请求的成功执行。执行完毕 Elasticsearch 会返回含有 _items 的列表，其顺序和请求顺序是相同的。
> 执行 delete 动作时不需要指定 request body

参数说明：
* action/metadata 行：指定了将要在哪个文档中执行什么操作
* action：必须是 _index, create, update _或者 _delete_
* metadata：需要指明需要被操作文档的_index, _type_ 以及 _id

注意事项：
* 每一行都结尾处都必须有换行字符"\n"，最后一行也要有
* 行里不能包含非转义字符，以免干扰数据的分析
* bulk应该有一个最佳的限度(取决于硬件，文档大小以及复杂性，索引以及搜索的负载)，超过这个限制后，性能不但不会提升反而可能会造成宕机
  * 一般比较好初始数量级是**1000-5000**个文档
  * 一般比较好的初始批量容量是**5-15MB**

<b id="update"></b>
## 六、更新：_update + POST
局部更新：仅更新文档的某一属性值
```
# 原始文档
$ curl 'elastic:9200/github-2018.01.10/ceilometer/AVmHuCtvm_RLDnunMYID?pretty'
{
  "_index" : "github-2018.01.10",
  "_type" : "ceilometer",
  "_id" : "AVmHuCtvm_RLDnunMYID",
  "_version" : 3,
  "found" : true,
  "_source" : {
    "id" : "29248",
    "modul" : "ceilometer"
  }
}

# 更新 id: 需要传入一个 doc 键值对
$ curl -X POST 'elastic:9200/github-2018.01.10/ceilometer/AVmHuCtvm_RLDnunMYID/_update?pretty'  -d '{"doc": {"id": "30000"}}'
{
  "_index" : "github-2018.01.10",
  "_type" : "ceilometer",
  "_id" : "AVmHuCtvm_RLDnunMYID",
  "_version" : 4,
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  }
}

# 更新后文档
$ curl 'elastic:9200/github-2018.01.10/ceilometer/AVmHuCtvm_RLDnunMYID?pretty'
{
  "_index" : "github-2018.01.10",
  "_type" : "ceilometer",
  "_id" : "AVmHuCtvm_RLDnunMYID",
  "_version" : 4,
  "found" : true,
  "_source" : {
    "id" : "30000",
    "modul" : "ceilometer"
  }
}

# 添加新属性
$ curl -X POST 'elastic:9200/github-2018.01.10/ceilometer/AVmHuCtvm_RLDnunMYID/_update?pretty'  -d '{"doc": {"id": "30001", "name": "paul"}}'
{
  "_index" : "github-2018.01.10",
  "_type" : "ceilometer",
  "_id" : "AVmHuCtvm_RLDnunMYID",
  "_version" : 5,
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  }
}
```
Elasticsearch 支持使用脚本来完成使用API无法直接完成的自定义行为，默认的脚本语言为 **MVEL(一个简单高效的JAVA基础动态脚本语言，它的语法类似于Javascript)**，
但也支持JavaScript, Groovy 以及 Python.