# PVC
## 一、简介
pvc 是  PersistentVolumeClaim，即持久化卷请求。用户使用 pvc 来向 pv 申请数据存储空间。

## 二、案例
向 pv 申请数据存储空间
```
$ vim nfs_pvc.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs
  annotations:
    volume.beta.kubernetes.io/storage-class: "slow"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi

$ kubectl create -f nfs_pvc.yml
persistentvolumeclaim "nfs" created

$ kubectl get pvc nfs
NAME      STATUS    VOLUME    CAPACITY   ACCESSMODES   AGE
nfs       Bound     nfs       5Gi        RWO           5s

$ kubectl get pv nfs
NAME      CAPACITY   ACCESSMODES   STATUS    CLAIM         REASON    AGE
nfs       5Gi        RWO           Bound     default/nfs             15m
```

使用 pv 和 pvc 来进行数据持久化的 pod
```
$ vim nfs-base-rc.yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: nfs-base
spec:
  replicas: 2
  selector:
    name: nfs-base
  template:
    metadata:
      labels:
        name: nfs-base
    spec:
      containers:
      - image: centos
        command:
          - sh
          - -c
          - 'while true; do touch /root/test.txt; date > /root/test.txt; echo "bascker" >> /root/test.txt; sleep $(($RANDOM % 5 + 5)); done'
        imagePullPolicy: IfNotPresent
        name: base
        volumeMounts:
          - name: nfs
            mountPath: "/root"
      volumes:
      - name: nfs
        persistentVolumeClaim:
          claimName: nfs

$ kubect get pod --name
NAME                READY     STATUS              RESTARTS   AGE
nfs-base-hm4md      0/1       ContainerCreating   0          11s        # compute2 失败
nfs-base-korfn      1/1       Running             0          11s        # compute1 成功

$ kubectl describe pod nfs-base-korfn        # 获得容器 id：c627a83d01ab
$ ssh compute1
$ docker exec -it c627a83d01ab /bin/bash
$ cat ~/test.txt

# 查看 nfs 服务器那边的情况，文件一致
```