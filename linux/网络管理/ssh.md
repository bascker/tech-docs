# ssh
## 简介
用于远程连接，默认使用 22 端口，基本使用：_ssh username@REMOTE\_IP_

## 案例

1.利用 ssh 来远程执行命令

```
1.在 148 上执行 echo 123 和 ps 命令
$ ssh root@10.158.113.148 "echo 123 && ps aux | grep docker"

# 注：多条远程命令必须要用双引号包裹；不能写成 ssh root@10.158.113.148 echo 123 && ps aux | grep docker
# 这样表示，先在 148 节点上执行 echo 命令，然后再在本节点上执行 ps 命令

2.远程执行多条命令
$ ssh kolla-com2
$ cd ~/workspace
$ vim com2.sh
#!/bin/bash

echo "I'm in com2..."

# 不加 —C 标志也一样
$ ssh kolla-com2 -C "echo aaa && cd ~/workspace && ./com2.sh"
aaa
I'm in com2...
```

2.生成密钥：ssh-keygen

```
$ ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
```

3.拷贝密钥：ssh-copy-id

```
$ ssh-copy-id -i ~/.ssh/id_rsa.pub 10.158.113.158
```

## FAQ

1.解决 ssh 提示：_Are you sure you want to continue connecting \(yes/no\)_? 的问题

```
# 修改 StrictHostKeyChecking 为 no 即可
# 方法1
$ sed -i "s/StrictHostKeyChecking ask/StrictHostKeyChecking no/g" /etc/ssh/ssh_config

# 方法2
$ sshpass -p kolla ssh 10.158.113.148 -o StrictHostKeyChecking=no -C "echo aaa"
aaa
```

2.解决 ssh 执行远程后台命令不退出的问题

\[Q\] 利用 ssh 在执行远程后台命令时，会由于远程命令是后台执行的，ssh 会一直处于连接状态，不退出

\[A\] 解决办法：ssh 远程命令重定向 + 后台执行 ==&gt;  类似 SSH 异步执行远程命令

```
# 远程机器 22-cdvm
$ vim while.sh
#!/bin/bash

while [ True ];
do
    echo "111..."
done

$ vim test.sh
#!/bin/bash

sh while.sh &                          # 后台执行 while 循环

# 测试机器
$ ssh 22-cdvm -C "sh ~/test.sh"        # 将一直处于连接状态，不退出

# 解决办法
$ ssh 22-cdvm -C "sh ~/test.sh > /dev/null 2>&1 &"
```