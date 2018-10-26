# alias
## 简介
用来设置指令的别名，可将一些长命令简化。alias命令的作用只局限于该次登入的操作，即临时生效。若想永久生效，可将相应的alias命令存放到bash的初始化文件_/etc/bashrc_ 或 _.bashrc_ 中。语法如下：

```
$ alias 新的命令='原命令 -选项/参数'
```

> 注：
>
> 1. 使用alias时，用户必须使用单引号''将原来的命令引起来，防止特殊字符导致错误
> 2. 要删除一个别名，可以使用 **unalias **命令，如 unalias k8s

## 案例

```
$ alias k8s='kubectl --namespace kolla'
$ k8s get pvc
NAME       STATUS    VOLUME     CAPACITY   ACCESSMODES   AGE
glance     Bound     glance     10Gi       RWO           1d
mariadb    Bound     mariadb    10Gi       RWO           9d
rabbitmq   Bound     rabbitmq   10Gi       RWO           9d

# 让其永久生效
$ vim /etc/bashrc
# 末尾添加代码
alias k8s='kubectl --namespace kolla'
```