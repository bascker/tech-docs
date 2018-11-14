# tail 插件
## 一、简介
fluent 的**输入**插件\(tail-input-plugin)，直接支持，不需额外安装。类似 tail -f 的方式追踪文件。

| 属性 | 是否必选 | 备注
|-----|---------|------
| type | Y | 值为 tail
| tag | Y |
| path | Y | 支持正则表达式
| format | Y | 建立利用**命名分组**来写表达式
| pos_file | N | 强烈推荐使用
| refresh_interval | N | 监视时间，默认为 60s 收集一次数据
| exclude_path | N | 值为列表，用来排除监视的文件，一般配置 path 值类似 /path/* 时使用
| read_lines_limit | N | 每次IO操作读取的行数，默认为 1000

Note: linux 命名分组和 python 的命名分组的区别
* 前者直接写为 (?&lt;Key&gt;Pattern) 的形式
* 后者为 (?P&lt;Key&gt;Pattern)，多了一个 P

## 二、案例
同时跟踪多个文件：收集 /var/log/kolla 下的 test-*.log 日志信息，并按 format 格式，将数据命名分组(date, username, userpass)，然后以 json 串格式
存入 Elasticsearch 指定索引(格式为 "logstash_prefix-format_date_")中，其类型为 test.

1.编辑配置文件
```
$ cat td-agent.conf
<source>
  @type tail
  path /var/log/kolla/test-*.log      # 跟踪 test-*.log 文件
  tag fluentd.test
  format /(?<date>.*\s.*\s\d*\s.*\s.*\s\d*)-(?<username>[^ ]*)-(?<userpass>[^ ]*)/
  pos_file /var/log/td-agent/access.log.pos
</source>
<match fluentd.test>
  type elasticsearch
  hosts 10.158.113.155
  index_name bascker
  type_name test
  include_tag_key true
  logstash_format true            # 使用 logstash 的格式
  logstash_prefix bascker           # index 前缀
  tag_key location
</match>

<system>
log_level debug
</system>
```

2.生成 test-*.log 文件
```
$ touch test-1.log
$ touch test-2.log
$ touch test-3.log
```

3.生成数据
```
$ echo "$(date)-bascker-123" >> test-1.log
$ echo "$(date)-paul-234" >> test-1.log
$ echo "$(date)-lisa-345" >> test-2.log
```

4.查看 td-agent 日志
```
$ tail -f td-agent.log
    tag_key location
  </match>
  <system>
    log_level debug
  </system>
</ROOT>
2018-01-16 14:03:16 +0800 [info]: following tail of /var/log/kolla/test-1.log
2018-01-16 14:03:16 +0800 [info]: following tail of /var/log/kolla/test-2.log
2018-01-16 14:04:16 +0800 [info]: following tail of /var/log/kolla/test-3.log
2018-01-16 14:04:17 +0800 [info]: Connection opened to Elasticsearch cluster => {:host=>"10.158.113.155", :port=>9200, :scheme=>"http"}
```

5.查看 Elasticsearch 中的记录
```
$ curl http://elastic:9200/_cat/indices?v
health status index                 pri rep docs.count docs.deleted store.size pri.store.size
yellow open   bascker-2018.01.16    5   1          3            0     13.1kb         13.1kb

$ curl http://10.158.113.158:9200/bascker-2018.01.16/test/_search?pretty;
{
  "took" : 2,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "failed" : 0
  },
  "hits" : {
    "total" : 3,
    "max_score" : 1.0,
    "hits" : [ {
      "_index" : "bascker-2018.01.16",
      "_type" : "test",
      "_id" : "AVml4E1Ym_RLDnunM5m0",
      "_score" : 1.0,
      "_source" : {
        "date" : "Mon Jan 16 14:03:37 CST 2018",
        "username" : "bascker",
        "userpass" : "123",
        "@timestamp" : "2018-01-16T14:03:37+08:00",
        "location" : "fluentd.test"
      }
    }, {
      "_index" : "bascker-2018.01.16",
      "_type" : "test",
      "_id" : "AVml4iFGm_RLDnunM5oy",
      "_score" : 1.0,
      "_source" : {
        "date" : "Mon Jan 16 14:05:19 CST 2018",
        "username" : "paul",
        "userpass" : "234",
        "@timestamp" : "2018-01-16T14:05:19+08:00",
        "location" : "fluentd.test"
      }
    }, {
      "_index" : "bascker-2018.01.16",
      "_type" : "test",
      "_id" : "AVml5rVMm_RLDnunM5pl",
      "_score" : 1.0,
      "_source" : {
        "date" : "Mon Jan 16 14:10:54 CST 2018",
        "username" : "lisa",
        "userpass" : "345",
        "@timestamp" : "2018-01-16T14:10:54+08:00",
        "location" : "fluentd.test"
      }
    } ]
  }
}
```
> path 也可以写成 test-ceph-mon.*.log，这样就会去跟踪如 test-ceph-mon.con1.log, test-ceph-mon.con2.log 这样的日志文件