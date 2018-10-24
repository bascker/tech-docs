# sshpass
## 简介

* 用于非交互的 ssh 密码验证：可以解决 shell 脚本进行 ssh 操作时，需要手动输入密码的问题
* 允许你用 -p 参数指定明文密码
* 支持密码从命令行,文件,环境变量中读取

## 案例

1.从命令行传入

```
$ sshpass -p kolla ssh 10.158.113.131
Last login: Thu Dec  8 14:28:35 2016 from 10.158.113.148
[root@server4 ~]# exit
logout
Connection to 10.158.113.131 closed.
```

2.从文件读取密码

```
$ echo "kolla" > passwd
$ sshpass -f passwd ssh 10.158.113.131
Last login: Thu Dec  8 15:41:37 2016 from 10.158.113.164
```

3.执行 scp 时，传入密码

```
$ sshpass -p 123456 scp -o StrictHostKeyChecking=no 10.158.113.15:~/template/* .
```