# ElasticSearch插件
## 一、简介
fluent-plugin-elasticsearch 是fluent 的**输出**插件, 用于将数据存储到 Elasticsearch。
```
# 安装
$ td-agent-gem install fluent-plugin-elasticsearch
```
> td-agent-gem 命令其实就是  gem 命令的一个包装而已

## 二、常用指令

| 指令 | 说明
| ---- | ----
| hosts | Elasticsearch 集群节点地址，可指定多个(使用英文逗号分割)
| index_name | 索引名
| type_name | 类型名
| logstash_format | 建议设为 true，默认为 false。这样数据将兼容 Logstash，便于接入 Logstash
| logstash_prefix | index 名的前缀，默认为 logstash
| logstash_dateformat | 配合 logstash 的属性使用，用于组成 index 名。默认为 %Y.%m.%d_
| time_key | 配合 logstash 的属性使用，用于设置时间 key 名。默认为 @timestamp
| time_key_format | 设置时间格式
| request_timeout | 存储数据到 Elasticsearch 的请求超时时间，默认为 5s
| tag_key | 记录 tag 值。若指定为 location，其值为 source 指令内的 tag 值

## 三、案例
```
$ cat /etc/td-agent/td-agent.conf
<source>
  @type tail
  path /var/log/kolla/test-2.*.log
  tag fluentd.test2
  format /(?<date>.*\s.*\s\d*\s.*\s.*\s\d*)-(?<username>[^ ]*)-(?<userpass>[^ ]*)/
  pos_file /var/log/td-agent/access.log.pos
</source>
<match fluentd.test2>
  type elasticsearch
  hosts elastic
  type_name test2
  include_tag_key true
  logstash_format true
  tag_key location
</match>

<system>
log_level debug
</system>

$ echo "$(date)-bascker-111" >> test-2.01.log

$ curl http://elastic:9200/_cat/indices?v
health status index               pri rep docs.count docs.deleted store.size pri.store.size
yellow open   logstash-2018.01.16   5   1          1            0      4.6kb          4.6kb

$ curl http://elastic:9200/logstash-2018.01.16/_search?pretty |  grep id
"_id" : "AVmmWTGam_RLDnunM6MK"

$ curl http://elastic:9200/logstash-2018.01.16/test2/AVmmWTGam_RLDnunM6MK?pretty
{
  "_index" : "logstash-2018.01.16",
  "_type" : "test2",
  "_id" : "AVmmWTGam_RLDnunM6MK",
  "_version" : 1,
  "found" : true,
  "_source" : {
    "date" : "Mon Jan 16 16:16:06 CST 2018",
    "username" : "bascker",
    "userpass" : "111",
    "@timestamp" : "2018-01-16T16:16:06+08:00",    # time_key
    "location" : "fluentd.test2"                   # tag_key
  }
}
```