# td-agent.conf
## 一、简介
fluentd 安装好后，会在 /etc 下生成一个 td-agent 的目录，其中就存在一个 td-agent.conf 的配置文件。该配置文件就是用来设置要使用 fluentd 来做什么？常见指令(配置项)如下：
* source
* match
* filter
* system
* label
* include

## 二、基础概念
### 2.1 source：指定数据的来源
通过 @type 来指定 input plugin ，此处使用的是 tail 插件(允许 fluentd 从文本尾部读取事件，类似于 tail -f )。fluentd 标准的 2 个插件为 http 和 forward。
官方案例：
```
# Receive events from 24224/tcp
# This is used by log forwarding and the fluent-cat command
<source>
  @type forward
  port 24224
</source>

# http://this.host:9880/myapp.access?json={"event":"data"}
<source>
  @type http
  port 9880
</source>
```
> 每个 resource 都必须指定 @type，以告知 fluentd 使用哪种 input plugin

### 2.2 match：告诉 fluentd 怎么做
match 会查看事件，若事件的 tag 与其指定的一致，则处理。通过 @type 指定 output plugin ，此处使用的是 elasticsearch 。官方提供 2 种插件为 file 和 forward 。
官方 file 插件案例：
```
<match myapp.access>
  @type file
  path /var/log/fluent/access
</match>
```
此处表明，处理tag 为 myapp.access 的 events，将数据存储文件 /var/log/fluent/access.%Y-%m-%d。默认文件后缀为 %Y-%m-%d，可以通过 time_slice_format 选项自定义。

> 注：要使用 elasticsearch 插件，需要安装 fluent-plugin-elasticsearch。[**fluent-plugin-elasticsearch插件地址**](https://github.com/uken/fluent-plugin-elasticsearch)

#### 2.2.1 match tag 的 patterns
* **\***：匹配某 tag 的一部分。如 a.\* 只会匹配 a.b 而不匹配 a.b.c
* **\*\***：匹配所有 tag。**不推荐**
* **{x,y,z}**：匹配 x, y, z 中的一个。如 {a, b} 会匹配 a 和 b，不匹配 c
> 注：match 的 patterns 可自由组合。且书写顺序：按 pattern 匹配的宽广，从低到高匹配。若反过来，则宽的匹配后，低的会被忽略

### 2.3 system：设置 fluentd 系统配置
常使用的属性：
* log_level：设置 fluentd 的日志输出等级，根据等级，记录日志到 td-agent.log 中(td-agent 命令有选项可配置)。日志等级如下：
  * debug：对应选项 -v
  * trace：对应选项 -vv
  * warn：对应选项 -q
  * error：对应选项 -qq
* process_name：只能在 td-agent.conf 中配置。指定后 fluentd 的 supervisor(主进程) 和 worker(工作进程) 进程名将改变
  ```
  # 案例
  $ cat /etc/td-agent/td-agent.conf
  <system>
    process_name td-jiaop
  </system>

  # 启动进程
  $ td-agent -o /var/log/td-agent/td-agent.log -d /var/run/td-agent/td-agent.pid

  # 查看进程
  $  ps aux
  USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
  td-agent    67  0.0  0.2 112840 22936 ?        Sl   07:00   0:00 supervisor:td-jiaop
  td-agent    70  0.3  0.3 119836 26980 ?        Sl   07:00   0:00 worker:td-jiaop
  td-agent    96  0.0  0.2 112700 22816 ?        Sl   07:00   0:00 supervisor:td-jiaop
  td-agent    99  3.5  0.3 119952 27144 ?        Sl   07:00   0:00 worker:td-jiaop
  ```

### 2.4 include：重用 td-agent 配置文件
利用该指令可以重用已有的配置文件，使用该指令时需要 **@**** **标记符。支持导入本地文件、远程文件(http方式)、正则式匹配等。官方案例如下：
```
@include /path/to/config.conf

# if using a relative path, the directive will use
# the dirname of this config file to expand the path
@include extra.conf

# glob match pattern
@include config.d/*.conf

# http
@include http://example.com/fluent.conf

# 习惯说明
# If you have a.conf,b.conf,...,z.conf and a.conf / z.conf are important...

# This is bad
@include *.conf

# This is good
@include a.conf
@include config.d/*.conf
@include z.conf
```

## 三、案例
如下所示是收集主机上 ceilometer-api 日志的一段配置
```
<source>
  @type tail
  path /var/log/ceilometer/api.log
  tag 10.158.112.43:ceilometer.api
  format /(?<occurTime>[^ ]*\s[^ ]*) (?<id>[^ ]*) (?<level>[^ ][WARNING||ERROR]+) (?<modul>[^ ]*) (?<requestID>\[[^\]]*\]) (?<content>.*)/
  pos_file /var/log/td-agent/access.log.pos
</source>
<match 10.158.112.43:ceilometer.api>
  @type elasticsearch
  hosts 10.158.112.43       # elasticsearch 服务地址，可指定多个，使用“,”分隔。多个会进行负载分担
  index_name github
  type_name ceilometer
  include_tag_key true
  logstash_format true
  logstash_prefix github
  tag_key location
</match>

<system>
  log_level debug           # 设置 fluentd 的日志输出级别
</system>
```

配置说明：
* type：指定使用 tail 插件采集日志信息
* path：信息来源/读取路径。多路径使用 “,” 分割
* tag：事件 tag，提供给 match 使用
* format：指定日志的格式。使用正则表达式时，需要使用 “**/” **包裹
* **pos_file(可选参数)**：用于记录 fluentd 上次读取文件的位置。**推荐使用**

## 参考文档
1. [官方文档](http://docs.fluentd.org/articles/config-file)