# Label
## 一、简介
Label 是 一个被附加到资源上的键/值对，其作用是用于筛选/区分资源，是 svc 和 rc 运行的基础.
* 通过标识容器的 labels 从给后端提供服务的多个容器中选择正确的容器来处理 svc的请求
* rc 也使用 labels 来管理通过模板创建的一组容器

> 注：不同于 uuid，lable不具有唯一性，多个pod可以持有同一 label

## 二、案例
1.label 在 yaml 模板中的使用
```
$ vim mariadb-pod.yml
apiVersion: apps/v1alpha1
kind: PetSet
spec:
  serviceName: "mariadb"
  replicas: 1
  template:
    metadata:
      labels:                            # 定义 label：一个或多个
        service: mariadb
      annotations:
        pod.alpha.kubernetes.io/initialized: "true"
    spec:
      nodeSelector:
      ...
```

2.通过 label 筛选资源：2种方式
* equality-based，利用 `=，==，!=`来过滤
* set-based,利用 `in, notin` 来过滤


```
# 利用 =，==，!= 过滤
$ kubectl get nodes -l kolla_controller=true
NAME         STATUS    AGE
compute1     Ready     21d
controller   Ready     21d

$ k8s get daemonset -l component=nova
NAME           DESIRED   CURRENT   NODE-SELECTOR        AGE
nova-compute   2         2         kolla_compute=true   19d
nova-libvirt   2         2         kolla_compute=true   19d

# 类似 python 的写法，使用元组，利用 in, notin 过滤
$ kubectl get nodes -l 'kolla_controller in (true aaaa)'
NAME         STATUS    AGE
compute1     Ready     21d
controller   Ready     21d

$ kubectl get nodes -l 'kolla_controller notin (true)'
NAME       STATUS    AGE
compute2   Ready     21d
```