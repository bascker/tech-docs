# 简介
Redis是一个 key-value 存储系统，是当下互联网公司最常用的NoSQL数据库之一，默认端口号为 6379，且默认只允许本地访问。

## 安装
1.安装依赖软件
```
$ yum install -y gcc wget
```

2.获取 redis tar 文件，并解压
```
$ wget http://download.redis.io/releases/redis-3.2.9.tar.gz
$ tar xzf redis-3.2.9.tar.gz && cd redis-3.2.9
```

3.编译 redis
```
$ make MALLOC=libc
cd src && make all
make[1]: 进入目录“/share/redis-3.2.9/src”
...
make[2]: 离开目录“/share/redis-3.2.9/deps”
    CC adlist.o
    CC quicklist.o
    ...
    LINK redis-server
    INSTALL redis-sentinel
    CC redis-cli.o
    LINK redis-cli
    CC redis-benchmark.o
    LINK redis-benchmark
    INSTALL redis-check-rdb
    CC redis-check-aof.o
    LINK redis-check-aof

Hint: It's a good idea to run 'make test' ;)

make[1]: 离开目录“/share/redis-3.2.9/src”
```

4.启动 redis 服务
```
$ nohup ./redis-server > /var/log/redis.log &
# 查看 Server 启动 Log
$ cat /var/log/redis.log
3090:C 07 Jun 19:12:27.766 # Warning: no config file specified, using the default config. In order to specify a config file use ./redis-server /path/to/redis.conf
3090:M 07 Jun 19:12:27.767 * Increased maximum number of open files to 10032 (it was originally set to 1024).
                _._
           _.-``__ ''-._
      _.-``    `.  `_.  ''-._           Redis 3.2.9 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 3090
  `-._    `-._  `-./  _.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |           http://redis.io
  `-._    `-._`-.__.-'_.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |
  `-._    `-._`-.__.-'_.-'    _.-'
      `-._    `-.__.-'    _.-'
          `-._        _.-'
              `-.__.-'

3090:M 07 Jun 19:12:27.767 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
3090:M 07 Jun 19:12:27.768 # Server started, Redis version 3.2.9
3090:M 07 Jun 19:12:27.768 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
3090:M 07 Jun 19:12:27.768 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
3090:M 07 Jun 19:12:27.768 * DB loaded from disk: 0.000 seconds
3090:M 07 Jun 19:12:27.768 * The server is now ready to accept connections on port 6379
```

5.进入 cli，测试 redis
```
$ ./redis-cli
127.0.0.1:6379>
127.0.0.1:6379>
127.0.0.1:6379>
127.0.0.1:6379> set foo bar
OK
127.0.0.1:6379>
127.0.0.1:6379>
127.0.0.1:6379> get foo
"bar"
127.0.0.1:6379> exit
```

6.创建软连接，方便以后直接调用命令
```
$ mv /share/redis-3.2.9 /usr/local
$ cd /usr/local/bin
$ ln -s ../redis-3.2.9/src/redis-server redis-server
$ ln -s ../redis-3.2.9/src/redis-cli redis-cli
```