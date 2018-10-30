# Aodh
## 简介
1. 从 ceilometer 中分离出来的项目\(ceilometer-alarm 变为 aodh\)，用于提供告警\(alarm\)功能
2. 组合：ceilometer + gnocchi + aodh，这三者是 Telemetry 的子项目
   * ceilometer：metering as a service，核心
   * gnocchi：metric as a service
   * aodh：alarm as a service
3. openstack doc：[http://docs.openstack.org/developer/aodh/index.html](http://docs.openstack.org/developer/aodh/index.html)

## 组成
1. aodh-api：为告警数据的存储和访问提供接口
2. aodh-evaluator：根据统计数据，评估是否需要触发告警
3. aodh-listener：监听事件，触发事件相关告警
4. aodh-notifier：根据告警方式，发出告警

## Aodh 和 Ceilometer
因 Aodh 是从 Ceilometer 中抽离出来的项目，因此当 Aodh 和 Ceilometer 集成后，就会将自己的告警 api 重定向到 Aodh。
> 只要 Aodh 服务的 endpoint 注册到 keystone，就会认为 aodh 加入集群，ceilometer alarm api 开始重定向

```
# ceilometer 日志
WARNING ceilometer.api.controllers.v2.root [-] ceilometer-api started with aodh enabled. Alarms URLs will be redirected to aodh endpoint.
```

在调用 Ceilometer 命令时\(如 ceilometer meter-list\)，通过 debug，可以知道该命令会首**先经过 aodh api，然后才是 ceilometer api**。
```
$ ceilometer --debug meter-list
# 先进行 ceilometer 身份认证, 认证通过后从 keystone 获取 token，token 中携带所有服务的 endpoints
DEBUG (session) REQ: curl -g -i -X GET http://100.33.0.253:5000/v3 -H "Accept: application/json" -H "User-Agent: ceilometer keystoneauth1/2.12.1 python-requests/2.10.0 CPython/2.7.5"
INFO (connectionpool) Starting new HTTP connection (1): 100.33.0.253
...

DEBUG (base) Making authentication request to http://100.33.0.253:5000/v3/auth/tokens
DEBUG (base) {
    "token": {
        "is_domain": false,
        "methods": [
            "password"
        ],
        "roles": [
            {
                "id": "...",
                "name": "admin"
            }
        ],
        ...
        "project": {
            "domain": {
                "id": "default",
                "name": "Default"
            },
            "id": "...",
            "name": "admin"
        },
        "catalog": [
            ...
            {
                "endpoints": [
                    {
                        "url": "http://aodh-api:8042",
                        "interface": "internal",
                        "region": "RegionOne",
                        "region_id": "RegionOne",
                        "id": "..."
                    },
                    {
                        "url": "http://100.33.0.253:8042",
                        "interface": "public",
                        "region": "RegionOne",
                        "region_id": "RegionOne",
                        "id": "..."
                    },
                    {
                        "url": "http://aodh-api:8042",
                        "interface": "admin",
                        "region": "RegionOne",
                        "region_id": "RegionOne",
                        "id": "..."
                    }
                ],
                "type": "alarming",
                "id": "...",
                "name": "aodh"
            },
            ...
        ],
        "user": {
            "domain": {...},
            "id": "...",
            "name": "admin"
        },
        "audit_ids": ["..."],
        "issued_at": "..."
    }
}

...
# 1. Aodh 的 API, 8042 是 aodh-api 的 port
DEBUG (client) REQ: curl -g -i -X 'GET' 'http://100.33.0.253:8042/' \
  -H 'User-Agent: ceilometerclient.openstack.common.apiclient' \
  -H 'X-Auth-Token: {SHA1}7e8ca2f6746d09b3630fe4b4c35d94ed2f6171a7'
...

# 再次进行 ceilometer 身份认证，获取 token
DEBUG (session) REQ: curl -g -i -X GET http://100.33.0.253:5000/v3 ...
...

# 2. 发送 meter 请求，获取结果
DEBUG (client) REQ: curl -g -i -X 'GET' 'http://100.33.0.253:8777/v2/meters' ...
...
```

## 参考文献
1.官网-aodh：[https://docs.openstack.org/developer/aodh/](https://docs.openstack.org/developer/aodh/)