# exec
## 简介

* 在不启动新进程的情况下，调用并执行指令：会用要执行的 CMD 替换掉当前进程中的指令。
* 一般用于 shell 脚本中：调用了 exec 的脚本，执行完 exec 后，在 exec 之后的命令将不会被执行
* 语法：_exec CMD_

## 案例
```
$ vim test.sh
#!/bin/bash

echo "Before exec..."
exec echo "Run exec..."
echo "After exec..."

$ chmod +x test.sh
$ ./test.sh
Before exec...
Run exec...

$ docker exec -it centos /bin/bash
$ exec hostname && echo "in container"
centos
$ hostname
docker
# 第二次 hostname 执行为 docker，是宿主机的主机名，因为 exec 执行完后，exec 执行的命令替换掉了当前进程中的命令 /bin/bash
# 因此执行完后，会退出容器
```