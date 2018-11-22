# DS
## 一、简介
ds 是 Daemon Set 的简称，是 rc 的一种变体。创建某个 ds 资源后，会在所有符合 nodeSelector 定义的标签的节点上启动一个 pod。
若不指定 nodeSelect，则默认在所有节点上启动一个 pod。删除 ds 是会将其创建的 pod 一并删除。

ds 的优点
* 快速响应：可以快速检测到某 node  的标签被改变，从而快速在匹配的节点上启动 pod，在不匹配的节点上删除 pod
* 固定标签节点上启动 pod：ds 创建的 pod 会在固定标签节点上启动，不会向 deployment 一样不固定

典型应用：
* 用作集群的存储daemon，如 glusterd, ceph
* 用作日志收集，如 fluentd、logstash
* 用作监视daemon,，如 collectd

## 二、案例
```
$ vim hello-daemonset.yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  labels:
    ver: test
  name: hello
spec:
  template:
    metadata:
      labels:
        ver: test
    spec:
      containers:
      - command:
          - echo
          - "Hello"
        image: centos
        imagePullPolicy: IfNotPresent
        name: hello
      restartPolicy: Always
```