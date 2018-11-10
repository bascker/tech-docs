# 简介
Elasticsearch 是一种**面向文档型数据库**(存储整个对象或文档，并为其建立索引)，分布式**NoSQL**文档存储。负责存储日志数据和提供查询接口，使用 JSON 进行序列化。
常用于组成 ELK 日志管理系统，其中 Elasticsearch 进行数据存储，Logstash 进行日志采集，Kibana 提供日志分析的UI界面。
* 默认数据存储位置：`/var/lib/elasticsearch/data`
* 启动命令：`/usr/share/elasticsearch/bin/elasticsearch`
* 锁机制：Elasticsearch使用**乐观锁**，即仅在提交事务操作时检验数据完整性

主要特性如下：
* 支持全文检索、段落检索、查询字符串检索、检索结果高亮、统计/汇总
* 支持成百上千的台节点的集群环境，处理 PB 级数据
* 支持高可用与负载分担
* 支持自动选举主节点

# VS. 关系型数据库
与关系型数据库概念对比
`````
关系数据库      ⇒ 数据库        ⇒ 表          ⇒ 行    ⇒ 列(Columns)
Elasticsearch  ⇒ 索引(index)   ⇒ 类型(type)  ⇒ 文档  ⇒ 字段(Fields)
`````

# 参考文献
1. [Elasticsearch权威指南](http://www.learnes.net/getting_started/tutorial_indexing.html)
2. [官方 api 文档地址](https://www.elastic.co/guide/en/elasticsearch/reference/master/index.html)