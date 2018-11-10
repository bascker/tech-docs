# 数据存储
配置文件为 `/usr/share/elasticsearch/config/elasticsearch.yml`
> 当前 Elasticsearch 集群为**单节点集群**
```
$ cat elasticsearch.yml
node.name: "elastic"
network.host: "elastic"
cluster.name: "kolla_logging"
node.master: true
node.data: true
discovery.zen.ping.unicast.hosts: ["elastic"]

discovery.zen.minimum_master_nodes: 1
gateway.expected_nodes: 1
gateway.recover_after_time: "5m"
gateway.recover_after_nodes: 1
path.conf: "/etc/elasticsearch"                 # 配置文件路径
path.data: "/var/lib/elasticsearch/data"        # 数据存储路径
path.logs: "/var/log/kolla/elasticsearch"       # 日志文件存储路径
path.scripts: "/etc/elasticsearch/scripts"
```

Elasticsearch 集群默认存储位置为 `/var/lib/elasticsearch/data`
```
$ docker exec -it elasticsearch bash
$ cd /var/lib/elasticsearch/data
$ ls
kolla_logging                            # 当前 Elasticsearch 集群名
```

查看文件层次
```
$ tree
.
`-- kolla_logging                        # 集群名
    `-- nodes                            # 集群节点信息
        `-- 0                            # 第一个节点
            |-- _state
            |   `-- global-0.st
            |-- indices                  # 存储索引信息
                |   |-- log-2018.01.15   # 索引名
                |   |   |-- 0            # 第一个主分片
                |   |   |   |-- _state
                |   |   |   |   `-- state-0.st
                |   |   |   |-- index
                |   |   |   |   |-- segments_2
                |   |   |   |   `-- write.lock
                |   |   |   `-- translog
                |   |   |       |-- translog-1.tlog
                |   |   |       `-- translog.ckp
                |   |   |-- 1
                |   |   |   |-- _state
                |   |   |   |   `-- state-0.st
                |   |   |   |-- index
                |   |   |   |   |-- segments_2
                |   |   |   |   `-- write.lock
                |   |   |   `-- translog
                |   |   |       |-- translog-1.tlog
                |   |   |       `-- translog.ckp
                ....
                |   |   |-- 4             # 第五个主分片
                |   |   `-- _state
                |   |       `-- state-1.st
            `-- node.lock
```
从上述输出可知：
1. 以**集群名**分隔数据
2. **nodes**目录：存储节点数据信息，节点编号从 **0** 开始.每个节点目录包含 2个目录(**_state, indices**)和一个文件(**node.locl**)
3. **indices**：存储集群索引信息，并按主分片个数建立相应个数目录(从 0 开始编号)保存数据