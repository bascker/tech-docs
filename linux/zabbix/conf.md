# 配置文件
## 简介
zabbix 相关配置文件如下所示
| 配置文件 | 描述
| ------- | -----
| /etc/zabbix/zabbix_agentd.conf | agent 的配置文件
| /etc/zabbix/zabbix_server.conf | server 的配置文件
| /etc/zabbix/web/zabbix.conf.php | zabbix-server持有的配置，用于 web 界面的访问设置
| /etc/httpd/conf.d/zabbix.conf | zabbix web 界面的配置文件

## zabbix_agentd.conf
1. **AllowRoot**：是否允许使用 root 身份运行zabbix，默认值为 0，表示不允许，启动时会以 zabbix 用户允许。设置为 1 表示允许
2. **BufferSend**：数据存储在 buffer 中最长生存多少秒，默认为 5，取值范围 1-3600
4. **DebugLevel**：日志等级
    * 0：basic info
    * 1：critical
    * 2：error
    * 3：warnings
    * 4：debug
    * 5：extended debugging
5. **EnableRemoteCommands**：是否运行zabbix server在此服务器上执行远程命令，默认为 0，表示不允许。为 1 表示允许
6. **Hostname**：必须唯一，区分大小写，且必须 zabbix web上配置的一直，否则zabbix主动监控无法正常工作。
7. **Server**：server 的地址，表示允许哪个 server 来和本 agent 建立连接。多地址使用逗号分割
8. **ServerActive**：zabbix 主动监控server的ip地址，多地址使用逗号分隔
9. **Timeout**：连接超时设置
10. **UserParameter**：自定义监控