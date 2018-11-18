# redis.conf
| 配置项 | 描述 | 备注
| ----- | ---- | ----
| bind | 绑定的主机地址 |
| requirepass | 设置密码认证 |
| timeout | 客户端连接闲置多久后，关闭连接 |
| daemonize | 是否以守护进程方式运行 | 默认为 no
| databases | 设置数据库数量 | 默认为 0
| loglevel | 指定日志级别，debug/verbose/notice/warning | 默认为 verbose
| save | 设置多长时间，有多少次更新操作，就将数据同步到数据文件。可以多个条件配合 |
| rdbcompression | 指定存储至本地数据库时是否压缩数据 | 默认为yes
| dbfilename | 指定本地数据库文件名 | 默认值为dump.rdb
| dir | 指定本地数据库存放目录 |
| slaveof，masterip，masterport | 设置当本机为slav服务时，设置master服务的IP地址及端口，在Redis启动时，它会自动从master进行数据同步 |
| masterauth，master-password | 当master服务设置了密码保护时，slave服务连接master的密码 |
| maxclients | 设置同一时间最大客户端连接数 | 默认无限制
| maxmemory | 指定 Redis 最大内存限制 |
| appendonly | 指定是否在每次更新操作后进行日志记录 | 默认情况下是异步的把数据写入磁盘，如果不开启，可能会在断电时导致一段时间内的数据丢失
| appendfilename | 指定更新日志文件名 | 默认为appendonly.aof
| vm-enabled | 指定是否启用虚拟内存机制 | 默认值为no
| vm-swap-file | 虚拟内存文件路径 | 默认值为/tmp/redis.swap，不可多个Redis实例共享
| include | 指定包含其它的配置文件 | 可在同一主机上多个Redis实例之间使用同一份配置文件，而同时各个实例又拥有自己的特定配置文件

## maxmemory
* Redis 在启动时会把数据加载到内存中，达到最大内存后，Redis 会先尝试清除已到期或即将到期的 Key
* 当此方法处理后，仍然到达最大内存设置，将无法再进行写入操作，但仍然可以进行读取操作
* Redis 新的 vm 机制，会把 Key 存放内存，Value 会存放在 swap 区

## appendfsync
* no：表示等操作系统进行数据缓存同步到磁盘（快）
* always：表示每次更新操作后手动调用fsync()将数据写到磁盘（慢，安全）
* everysec：表示每秒同步一次（折衷，默认值）