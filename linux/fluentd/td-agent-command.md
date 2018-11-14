# td-agent
## 一、简介
安装好 td-agent 后，可以就会有 td-agent 命令。
```
$ td-agent -h
Usage: td-agent [options]
    -s, --setup [DIR=/etc/td-agent]  install sample configuration file to the directory
    -c, --config PATH                config file path (default: /etc/td-agent/td-agent.conf)
        --dry-run                    Check fluentd setup is correct or not
        --show-plugin-config=PLUGIN  Show PLUGIN configuration and exit(ex: input:dummy)
    -p, --plugin DIR                 add plugin directory
    -I PATH                          add library path
    -r NAME                          load library
    -d, --daemon PIDFILE             daemonize fluent process
        --no-supervisor              run without fluent supervisor
        --user USER                  change user
        --group GROUP                change group
    -o, --log PATH                   log file path
    -i CONFIG_STRING,                inline config which is appended to the config file on-fly
        --inline-config
        --emit-error-log-interval SECONDS
                                     suppress interval seconds of emit error logs
        --suppress-repeated-stacktrace [VALUE]
                                     suppress repeated stacktrace
        --without-source             invoke a fluentd without input plugins
        --use-v1-config              Use v1 configuration format (default)
        --use-v0-config              Use v0 configuration format
    -v, --verbose                    increase verbose level (-v: debug, -vv: trace)
    -q, --quiet                      decrease verbose level (-q: warn, -qq: error)
        --suppress-config-dump       suppress config dumping when fluentd starts
    -g, --gemfile GEMFILE            Gemfile path
    -G, --gem-path GEM_INSTALL_PATH  Gemfile install path (default: $(dirname $gemfile)/vendor/bundle)

# 命令文件
$ cat /usr/sbin/td-agent
#!/opt/td-agent/embedded/bin/ruby
ENV["GEM_HOME"]="/opt/td-agent/embedded/lib/ruby/gems/2.1.0/"
ENV["GEM_PATH"]="/opt/td-agent/embedded/lib/ruby/gems/2.1.0/"
ENV["FLUENT_CONF"]="/etc/td-agent/td-agent.conf"
ENV["FLUENT_PLUGIN"]="/etc/td-agent/plugin"
ENV["FLUENT_SOCKET"]="/var/run/td-agent/td-agent.sock"
load "/opt/td-agent/embedded/bin/fluentd"
```

从上可知：
1. **-s**：指定配置文件目录路径，默认 _/etc/td-agent_
2. **-c**：指定配置文件路径，默认 _/etc/td-agent/td-agent.conf_
3. **-p**：指定插件目录路径，默认 _/etc/td-agent/plugin_
4. **-d**：指定后台运行，一般指定 _/var/run/td-agent/td-agent.pid_
5. **-o**：指定日志文件输出路径
6. **-v**：开启 debug，相当于设置 system 的 log\_level 为 debug
7. **-q**：相当于设置 system 的 log\_level 为 warn
8. **-qq**：相当于设置 system 的 log\_level 为 error
9. **--dry-run**：启动时检查 td-agent 的配置是否正确

## 二、进程方式启动 td-agent

```
# 详细指定
$ /opt/td-agent/embedded/bin/ruby /usr/sbin/td-agent \
        --log /var/log/td-agent/td-agent.log \
        --use-v1-config \
        --group td-agent \
        --daemon /var/run/td-agent/td-agent.pid

# 简化版：根据 /usr/sbin/td-agent 的 load 可知，可以省略掉部分配置
$ td-agent -o /var/log/td-agent/td-agent.log -d /var/run/td-agent/td-agent.pid
```