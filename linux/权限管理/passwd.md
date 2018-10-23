# passwd
## 简介
用于修改用户密码，对应文件`/etc/passwd`

## 案例
```
# 修改用户 test 的密码
$ passwd test

# 从标准输入读取数据 123456 作为用户 test 的密码
# echo 123456 | passwd --stdin test
```