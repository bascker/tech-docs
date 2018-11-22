# Job
## 一、简介

job 一般用于执行初始化之类只需要执行一次的操作，如创建数据库、数据库更新、创建用户等

## 二、案例
```
$ vim job-hello.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: hello
spec:
  template:
    metadata:
      name: hello
    spec:
      containers:
      - name: hello
        image: centos
        imagePullPolicy: IfNotPresent
        command: ["echo", "Hello Job"]
      restartPolicy: OnFailure

$ kubectl create -f job-hello.yaml

$ kubectl get job -a
NAME                                READY     STATUS             RESTARTS   AGE
hello-b9n47                         0/1       Completed          0          1m
...

$ kubectl logs hello-b9n47
Hello Job
```
> 重启策略： OnFailure,Never