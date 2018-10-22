# 小技巧
## whereis 妙用

whereis 一般用于查找 linux 命令实现脚本的存在路径。可以利用它来查找某个命令文件的位置，然后查看该命令的源码，跟踪调试

## 在命令执行的过程中，不断的有信息刷出，如何定住输出？

* _ctrl + s_
  ：固定输出，便于查看分析
* _ctrl + q_
  ：释放，命令继续输出

> XShell验证通过，其他工具未测试

## 快速查找文件

利用 find 命令可以快速的找到某个/某些文件

```
$ find / -name [FILENAME | PATTERN]
```

## 执行命令获取其输出：$\(CMD\)

```
# 必须得加上-c,否则会以为后面的是个py脚本
$ a=$(python -c "import os,sys;print os.path.realpath('tox.ini')")
$ echo $a
```

## mv 移动目录时，目标目录非空，怎么办？

加上 -b 参数, 会在移动时给目标目录备份一份，备份文件会在目录目录名后加上 ~ 表示. 如_mv -b base /sdb/yum_

## ^ 的妙用

利用 _^old\_str^new\_str _找出上一次执行的命令，并将上次命令的**第一次**匹配的旧字符串 old\_str 替换成新字符串 new\_str

```
$ echo 111
111

# 将上一条命令 echo 111 中的第一个 1 替换成 2。即变成 echo 211.利用 ↑ 可以看到命令为 echo 211
$ ^1^2
echo 211
211

$ ^1^a
echo 2a1
2a1

$ ^2a1^aaa
echo aaa
aaa
```