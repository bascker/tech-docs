# ssh
## 一、简介
用于远程连接，默认使用 22 端口，基本使用：`ssh username@REMOTE_IP`
* -v 选项可以帮助打印 ssh 连接过程中的信息，用于 debug
* sshd 配置文件：`/etc/ssh/sshd_config`
* 日志文件：`/var/log/secure`
* 访问控制文件：
    * `/etc/hosts.allow`: 允许指定 ip 远程登录，该配置中规则优先级高于 hosts.deny
    * `/etc/hosts.deny`：拒绝指定 ip 远程登录

## 二、SSH 配置
| 配置项 | 描述 | 备注 | 示例
|-------|------|-----|------
| AcceptEnv | 指定客户端发送的哪些环境变量将会被传递到会话环境中 | 只有SSH-2协议支持环境变量的传递
| AddressFamily | 使用哪种地址族 | any(默认), inet4(仅ipv4), inet6(仅ipv6)
| AllowGroups | 访问控制，指定哪些用户组可以ssh登录 | 可使用"*"和"?"通配符，优先级：DenyUsers > AllowUsers > DenyGroups > AllowGroups
| AllowTcpForwarding | 是否允许TCP转发, 默认为"yes" |
| AuthorizedKeysFile | 存放该用户可以用来登录的 RSA/DSA 公钥， 默认值是".ssh/authorized_keys" | %% 表示'%'、%h 表示用户的主目录、%u 表示该用户的用户名
| Banner | 将这个指令指定的文件中的内容在用户进行认证前显示给远程用户 | 仅能用于SSH-2
| ChallengeResponseAuthentication | 是否允许质疑-应答(challenge-response)认证。默认值是"yes"
| Ciphers | 指定SSH-2允许使用的加密算法
| Compression | 是否对通信数据进行加密，还是延迟到认证成功之后再对通信数据加密 | yes, delayed(默认), no
| HostKey | 主机私钥文件的位置 | SSH-1 默认是 `/etc/ssh/ssh_host_key`， SSH-2默认是 `/etc/ssh/ssh_host_rsa_key` 和 `/etc/ssh/ssh_host_dsa_key`
| ListenAddress | 指定监听的网络地址，默认监听所有地址
| LoginGraceTime | 限制用户必须在指定的时限内认证成功，0 表示无限制 | 默认值是 120 秒
| LogLevel | 指定日志等级
| MaxAuthTries |  指定每个连接最大允许的认证次数。默认值是 6 | 失败认证的次数超过该值的一半，连接将被强制断开，且会生成额外的失败日志消息
| MaxStartups | 最大允许保持多少个未认证的连接。默认值是 10
| PasswordAuthentication | 是否允许使用基于密码的认证
| PermitEmptyPasswords | 是否允许密码为空的用户远程登录。默认为"no"。
| PermitRootLogin | 是否允许 root 登录
| PidFile |  指定在哪个文件中存放SSH守护进程的进程号 | 默认为 /var/run/sshd.pid
| Port | 指定守护进程监听的端口号 | 默认为 22

## 三、案例
### 3.1 远程执行命令
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

### 3.2 生成密钥
利用 ssh-keygen 来生成密钥
```
$ ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
```

### 3.3 拷贝密钥
利用 ssh-copy-id 拷贝密钥，可用做 ssh 无密钥登录
```
$ ssh-copy-id -i ~/.ssh/id_rsa.pub 10.158.113.158
```

### 3.4 设置 ssh 登录限制
1.ssh 白名单：只允许指定用户登录
```
# 只允许 bascker 以及从 ip 为 192.168.1.144 的用户 tim 远程登录
$ vim /etc/ssh/sshd_config
AllowUsers  bascker   tim@192.168.1.144

$ systemctl restart sshd
```

2.ssh 黑名单：拒绝某用户登录
```
$ vim /etc/ssh/sshd_config
DenyUsers   paul lisa

$ systemctl restart sshd
```

3.允许指定ip登录
```
$ vim /etc/hosts.allow
sshd:192.168.1.144:allow        # 允许 192.168.1.144 SSH 登录
sshd:192.168.2.:allo            # 允许 192.168.2.0/24 网段的用户登录，多个网段以逗号分割

# 允许全部的ssh登录
sshd:ALL
```

### 3.5 登陆失败后，解锁用户
SSH 登录失败达到最大次数后，用户将被锁定。此时可使用 pamtally2 命令解锁。语法`pamtally2 -u USERNAME -r`
```
$ pamtally2 -u service -r
```

### 3.6 设置不断开 ssh 连接
ssh 连接成功后，一定时间内没有操作时，会自动断开连接。要保持 ssh 连接不断开，则执行如下操作。
```
$ TMOUT=0
```

## 四、FAQ
### 4.1 解决 ssh 提示：Are you sure you want to continue connecting(yes/no)?
解决 ssh 提示：Are you sure you want to continue connecting (yes/no)? 的问题
```
# 修改 StrictHostKeyChecking 为 no 即可
# 方法1
$ sed -i "s/StrictHostKeyChecking ask/StrictHostKeyChecking no/g" /etc/ssh/ssh_config

# 方法2
$ sshpass -p kolla ssh 10.158.113.148 -o StrictHostKeyChecking=no -C "echo aaa"
aaa
```

### 4.2 ssh 执行远程后台命令不退出的问题
利用 ssh 在执行远程后台命令时，会由于远程命令是后台执行的，ssh 会一直处于连接状态，不退出。

解决办法：ssh 远程命令重定向 + 后台执行，类似 SSH 异步执行远程命令
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

### 4.3 ssh 远程登录失败
背景：节点下电重启后，使用 root, service 用户进行 ssh 登录失败。

原因：在添加 `opsadmin:admingroup` 用户时，在 `/etc/ssh/sshd_config` 配置文件中加入了 `AllowGroups adminGroup` 这个配置。而该配置指定只允许用户组为
adminGroup 的用户进行登录。
> sshd 的配置项是有优先级别的，AllowGroups 和 AllowUsers 的优先级别高于其他，比如高于 PermitRootLogin

解决：执行以下命令。
```
# 删除 AllowGroups 配置
$ sed -i "/AllowGroups adminGroup/d" /etc/ssh/sshd_config

# 重启 sshd 服务
$ systemctl restart sshd
$ systemctl status sshd
```

### 4.4 ssh 排查
ssh 出问题后，排查办法：
1. 检测防火墙是否关闭
2. sshd 进程是否正常
3. sshd 配置文件是否正确
4. ssh -v 搭配看日志