# NameSpace
## 一、简介
namespace 简称 ns，用于分隔 pod 的工作空间，默认情况下创建的资源都是在 default 空间下工作的。用于可以自定义 ns，
让 pod 在自定义 ns 下启动运行。

## 二、案例
```
$ kubectl get ns
NAME          STATUS    AGE
default       Active    6d
kolla         Active    6d
kube-system   Active    6d

$ kubectl --namespace kube-system get po
NAME                         READY     STATUS    RESTARTS   AGE
heapster-26slc               1/1       Running   1          6d
heapster-c04lk               1/1       Running   1          6d
kubernetes-dashboard-71p9d   1/1       Running   1          5d
kubernetes-dashboard-jqrxd   1/1       Running   0          5d
monitoring-grafana-v6vcg     1/1       Running   1          5d
monitoring-grafana-wmxrv     1/1       Running   0          5d
monitoring-influxdb-5gqwg    1/1       Running   0          5d
monitoring-influxdb-npr63    1/1       Running   1          5d
```

在 yaml 模板中指定 ns
```
apiVersion: batch/v1
kind: Job
metadata:
  name: mariadb-bootstrap
  namespace: kolla
...
```