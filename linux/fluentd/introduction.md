# 简介
fluentd 是一个使用 c 和 ruby**开源日志收集系统**，目前提供 300+ 扩展插件存储大数据用于日志搜索、数据分析和存储.特征如下：
* unified logging with json：尽可能的将数据处理为 json
* pluggable architecture：可插拔的架构，插件多而灵活
* minimum resource required：最小的资源要求，仅消耗 30~40M 内存就可以每秒处理 13000 个事件
* built-in reality：结构可靠
  * 支持基于内存和文件缓存的方式，防止节点间数据的丢失
  * 支持容错和高可用

# 安装
fluentd 的安装很简单，只需要执行如下命令即可.
```
$ yum install -y td-agent
$ systemctl enable td-agent
$ systemctl start td-agent
$ systemctl status td-agent
```
也可以使用进程启动。
```
/opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent \
        --log /var/log/td-agent/td-agent.log \
        --use-v1-config \
        --group td-agent \
        --daemon /var/run/td-agent/td-agent.pid
```
加上 --daemon 是以后台守护进程方式启动，**若使用 docker，则需要去掉 --daemon，以前台方式启动**

# 插件
1. [tail 插件](http://docs.fluentd.org/articles/in_tail)
2. [fluent-plugin-elasticsearch 插件](https://github.com/uken/fluent-plugin-elasticsearch#include_tag_key-tag_key)

# 参考文档
* [官方地址](http://www.fluentd.org/)