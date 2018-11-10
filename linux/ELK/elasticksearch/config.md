# 配置文件
Elasticsearch 的 2 个配置文件
* 基础配置：elasticsearch.yml
* 日志配置：logging.yml

## elasticsearch.yml
查看当前配置
```
$ cat /usr/share/elasticsearch/config/elasticsearch.yml
node.name: "19.0.7.7"
network.host: 0.0.0.0
cluster.name: "20.0.0.1"
node.master: true
node.data: true
discovery.zen.ping.unicast.hosts: "19.0.7.7"

discovery.zen.minimum_master_nodes: 1
gateway.expected_nodes: 1
gateway.recover_after_time: "5m"
gateway.recover_after_nodes: 1
path.conf: "/etc/elasticsearch"
path.data: "/var/lib/elasticsearch/data"
path.logs: "/var/log/kolla/elasticsearch"
path.scripts: "/etc/elasticsearch/scripts"
```

该配置对应的集群信息
```
$ curl http://19.0.7.7:9200
{
  "name" : "19.0.7.7",
  "cluster_name" : "20.0.0.1",
  "cluster_uuid" : "iNXotFoPRQq_wdbFdFZilg",
  "version" : {
    "number" : "2.4.1",
    "build_hash" : "c67dc32e24162035d18d6fe1e952c4cbcbe79d16",
    "build_timestamp" : "2018-09-27T18:57:55Z",
    "build_snapshot" : false,
    "lucene_version" : "5.5.2"
  },
  "tagline" : "You Know, for Search"
}
```
配置说明：
* node.name：当前 elasticsearch 节点名
* network.host：设置进程启动时绑定的 ip 地址。默认端口 9200
* cluster.name：集群名
* node.master：节点是否有称为集群 master 节点的资格，默认值为 true
* node.data：节点是否存储索引数据，默认为 true
* discovery.zen.minimum_master_nodes：设置集群中master节点的初始列表，可以通过这些节点来**自动发现**新加入集群的节点
* gateway.expected_nodes: 设置这个集群中节点的数量，一旦这N个节点启动，就会立即进行数据恢复。默认为 2
* gateway.recover_after_time: 设置初始化数据恢复进程的超时时间，默认 5min
* gateway.recover_after_nodes: 集群中N个节点启动时进行数据恢复，默认为 1
* path.conf: 配置文件路径，默认为 `/etc/elasticsearch`
* path.data: 集群数据存储路径，默认为 `/var/lib/elasticsearch/data`
* path.logs: 集群日志存储路径