# Configmap
## 一、简介
configmap 是用于存储配置文件的，提供挂载 configmap 到 pod 指定文件或目录的功能。其创建方法有2种：
* 使用 yaml 模板
* kubectl 命令

## 二、案例
使用 yaml 模板生成 configmap，并将其挂载到 pod 中。

1.编写 yaml 模板
```
$ vim consul-compute-ha-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: consul-compute-ha
data:
  consul-computer-ha.yaml: |
    ---
    service_host_ip: "192.168.1.158"

    ##################
    # Openstack options
    ###################
    os_project_domain_name: "default"
    os_user_domain_name: "default"
    os_project_name: "admin"
    os_tenant_name: "admin"
    os_username: "admin"
    os_password: "123456"
    os_auth_url: "http://192.168.1.158:35357/v3"
    os_identity_api_version: "3"

    openstack_vip: "10.158.113.241/24"

    ###################
    # Consul options
    ###################
    consul_client_prefix: "computer"

    ###################
    # Time options(单位：秒)
    ###################
    manage_net_alonedowntime_svc_down: 20
    storage_net_alonedowntime_evacuate: 60
    manage_storage_net_downtime_evacuate: 20
```

2.创建 configmap
```
$ kubectl create -f consul-compute-ha-configmap.yaml
```

3.查看
```
$ kubectl get configmap consul-compute-ha
NAME                DATA      AGE
consul-compute-ha   1         2d
```

4.给 pod 挂载 configmap
```
$ vim consul-compute-ha-daemonset.yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: computer-ha
  labels:
    service: computer-ha
spec:
  template:
    metadata:
      labels:
        service: computer-ha
    spec:
      containers:
      - name: computer-ha
        image: computer-ha
        imagePullPolicy: IfNotPresent
        # 注意：指定了挂载路径对应文件，必须加上 subPath 指定使用 configmap 中的哪个文件，
        # 否则 /root/ha/consul-computer-ha.yaml 将是一个目录
        volumeMounts:
        - mountPath: /root/ha/consul-computer-ha.yaml
          name: consul-compute-ha-config
          subPath: consul-computer-ha.yaml
      hostNetwork: true
      nodeSelector:
        nodeType: "computer-ha"
      restartPolicy: Always
      volumes:
      - configMap:                                                    # 声明使用 configmap
          name: consul-compute-ha
        name: consul-compute-ha-config

$ kubectl get pod
NAME                READY     STATUS    RESTARTS   AGE
computer-ha-981il   1/1       Running   0          39m

$ kubectl  exec -it computer-ha-981il /bin/bash
$ pwd
/root/ha
$ ll consul-computer-ha.yaml
-rw-r--r-- 1 root root 645 Nov 14 02:04 consul-computer-ha.yaml
```
