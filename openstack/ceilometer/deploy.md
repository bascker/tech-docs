# 部署

1.修改 /etc/kolla/globals.yml

```
$ vim /etc/kolla/globals.yml
enable_ceilometer: "yes"
ceilometer_database_type: "mongodb"
```

2.使用 kolla 项目，构建 ceilometer 镜像

```
$ kolla-build -b centos -t binary --tag 3.0.0 ceilometer
$ docker images | grep ceilometer | awk '{print $1":"$2}'
registry:5000/kolla/centos-binary-ceilometer-api:3.0.0
registry:5000/kolla/centos-binary-ceilometer-central:3.0.0
registry:5000/kolla/centos-binary-ceilometer-collector:3.0.0
registry:5000/kolla/centos-binary-ceilometer-notification:3.0.0
registry:5000/kolla/centos-binary-ceilometer-compute:3.0.0
registry:5000/kolla/centos-binary-ceilometer-base:3.0.0
```

3.部署

kolla 系列项目，2 种部署方式，虽然部署方式不一样，但结果相同

* kolla-ansible方式：执行 kolla-ansible deploy 自动部署即可
* kolla-kubernetes方式：kolla-kubernete resouce create XXX 逐一创建资源即可

> kolla-kubernete 项目中目前没有 ceilometer 的组件，需要自己进行 ceilometer 的 k8s 化

4.结果

以 kolla-k8s 方式部署结果为例，显示最终结果：

```
$ k8s get po | grep ceilo
ceilometer-api-2708715907-1ghfm            1/1       Running   0          1d
ceilometer-central-3032661648-9xplx        1/1       Running   0          1d
ceilometer-collector-3917136170-6k30z      1/1       Running   0          1d
ceilometer-compute-2stpr                   1/1       Running   0          1d
ceilometer-compute-5vfjg                   1/1       Running   0          1d
ceilometer-compute-xpp0q                   1/1       Running   0          1d
ceilometer-notification-3119486165-7z8b6   1/1       Running   0          1d

$ . admin.rc
$ ceilometer meter-list | tail
| network.incoming.bytes                   | cumulative | B         | instance-00000004-a134d60a-d056-4b2e-8fc1-780f16b56ec9-tap9ba78f48-59 | fc94b27355794ec4bae358080278bb71 | 2212062c347d4687b5462d7f7c3003b8 |
| network.incoming.bytes.rate              | gauge      | B/s       | instance-00000004-a134d60a-d056-4b2e-8fc1-780f16b56ec9-tap9ba78f48-59 | fc94b27355794ec4bae358080278bb71 | 2212062c347d4687b5462d7f7c3003b8 |
| network.incoming.packets                 | cumulative | packet    | instance-00000004-a134d60a-d056-4b2e-8fc1-780f16b56ec9-tap9ba78f48-59 | fc94b27355794ec4bae358080278bb71 | 2212062c347d4687b5462d7f7c3003b8 |
| network.incoming.packets.rate            | gauge      | packet/s  | instance-00000004-a134d60a-d056-4b2e-8fc1-780f16b56ec9-tap9ba78f48-59 | fc94b27355794ec4bae358080278bb71 | 2212062c347d4687b5462d7f7c3003b8 |
| network.outgoing.bytes                   | cumulative | B         | instance-00000004-a134d60a-d056-4b2e-8fc1-780f16b56ec9-tap9ba78f48-59 | fc94b27355794ec4bae358080278bb71 | 2212062c347d4687b5462d7f7c3003b8 |
| network.outgoing.bytes.rate              | gauge      | B/s       | instance-00000004-a134d60a-d056-4b2e-8fc1-780f16b56ec9-tap9ba78f48-59 | fc94b27355794ec4bae358080278bb71 | 2212062c347d4687b5462d7f7c3003b8 |
| network.outgoing.packets                 | cumulative | packet    | instance-00000004-a134d60a-d056-4b2e-8fc1-780f16b56ec9-tap9ba78f48-59 | fc94b27355794ec4bae358080278bb71 | 2212062c347d4687b5462d7f7c3003b8 |
| network.outgoing.packets.rate            | gauge      | packet/s  | instance-00000004-a134d60a-d056-4b2e-8fc1-780f16b56ec9-tap9ba78f48-59 | fc94b27355794ec4bae358080278bb71 | 2212062c347d4687b5462d7f7c3003b8 |
| vcpus                                    | gauge      | vcpu      | a134d60a-d056-4b2e-8fc1-780f16b56ec9                                  | fc94b27355794ec4bae358080278bb71 | 2212062c347d4687b5462d7f7c3003b8 |
+------------------------------------------+------------+-----------+-----------------------------------------------------------------------+----------------------------------+----------------------------------+
```