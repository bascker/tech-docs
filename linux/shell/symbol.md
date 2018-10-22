# 逻辑运算符
## &&：逻辑与

语法_**command1 && command2**_。_&&_左边的命令成功后，_&&_右边的命令才能够被执行，否则不执行。

```
$ touch b.txt
$ rm -f b.txt 1>/dev/null 2>&1 && echo "Delete Success..."
Delete Success...
```

## \|\|：逻辑或

语法 _**command1 \|\| command2**_。与 _&&_ 相反，\|\| 左边的命令失败后，\|\|右边的命令才能够被执行，否则不执行

```
$ rm a.txt 1>/dev/null 2>&1 || echo "The file is not exits..."
The file is not exits...
```

## _**\|\|**_ 与 _**&&**_ 的搭配注意

在使用 _\|\|_ 与 _&&_ 进行 shell 的编写时，一定得注意。举例如下：查看当前目录是否存在 test.txt，若不存在，则创建

\[错误写法\]

```
$ ll | grep test.txt || echo "test.txt is no exit" && echo "$(date)" > test.txt
```

这样写，其实际执行结果：

```
$ ( ll | grep test.txt || echo "test.txt is no exit" ) && echo "$(date)" > test.txt
```

执行顺序：

* 判断是否存在 test.txt，若不存在则打印 test.txt is no exit
* 将当前日期写入 test.txt：无论这个文件存不存在

\[正确写法\]

```
$ (ll | grep test.txt) || (echo "test.txt is no exit" && echo "$(date)" > test.txt)
```