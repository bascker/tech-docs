# ceilometer
## 简介

**ceilometer**是**openstack**的监控组件，主要负责**云\(****Openstack****云\)上资源**的采集,如虚机性能数据，其他组件\(glance, cinder\)的数据，网络资源数据。当然，**ceilometer**也可以搭配**snmp**来监控**云下资源\(物理机\)**的数据。

可采集的数据：

* 云上资源信息：镜像、块存储、对象存储、认证、网络等
* 裸机的信息
* 基于IPMI的计量项
* 基于SNMP的计量项
* VPNaas：VPN as a Service
* FWaas：Firewall as a Service
* ...

> 具体查看：[https://docs.openstack.org/admin-guide/telemetry-measurements.html](https://docs.openstack.org/admin-guide/telemetry-measurements.html)

## 服务

主要分为 **5** 个服务，本来还有告警服务，后面被独立作为一个组件 aodh。**核心服务是 polling agent 和 notification agent**.

### 1.控制服务

* **ceilometer-api**：负责 api 请求的转发与处理。默认端口 **8777**，通过 **wsgi **组件来监听
* **ceilometer-notification**：负责根据默认配置文件** pipeline.yml** 并采集各组件\(如 nova\) 推送到 **oslo-messaging**\(openstack整体的消息队列框架\) 的信息===&gt;只需监听 **AMQP **中的 queue 即可收到信息===&gt;通过消息队列，获取通知信息，转为采样数据
* **ceilometer-central**：通过各组件 API 方式收集有用的信息
* **ceilometer-collector**：汇总 _central、compute、notification_ 采集到的数据，并存储到后端存储

### 2.计算服务

* **ceilometer-compute**：只负责收集虚拟机的相关信息

> 可知，**云上虚机资源**的信息就依赖 _**ceilometer-compute**_ 服务收集，而**其他数据\(如：网络信息，云下的物理机信息\)**都由 _**ceilometer -central**_** **来负责收集

### 3、服务之间的关系图谱

![](asset/components.png)

## 参考文档

1. 计量模块 Ceilometer 介绍及优化：[http://www.cnblogs.com/sammyliu/p/4383289.html](http://www.cnblogs.com/sammyliu/p/4383289.html)
2. ceilometer的数据采集机制：[http://niusmallnan.com/\_build/html/\_templates/openstack/ceilometer\_collect.html](http://niusmallnan.com/_build/html/_templates/openstack/ceilometer_collect.html)