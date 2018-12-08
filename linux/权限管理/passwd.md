# passwd
## 一、简介
用于修改用户密码，对应文件`/etc/passwd`

## 二、案例
修改用户密码
```
# 修改用户 test 的密码
$ passwd test

# 从标准输入读取数据 123456 作为用户 test 的密码
# echo 123456 | passwd --stdin test
```

## 三、FAQ
### 3.1 密码修改失败
场景: 修改密码时报错如下
```
Passwd has been already used. choose another.
passwd: Have exhansted maximum numbers of retries for service
```

原因：当前修改时使用的密码近期已经使用过了

解决：换一个密码或者清空历史记录
1. 清除 `/ect/security/opasswd` 文件
2. 重新执行 passwd 命令
