# 注意事项
## 1._**\|\|**_ 与 _**&&**_ 的搭配注意

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

## 2.\(\) 中使用变量的注意

使用_**\(\)**_是在当前进程开启了一个子进程执行命令，若在其内使用了变量，则_**\(\)**_中变量值的修改，不会影响父进程的值。案例：

```
$ a=0
$ (let a+=1 && echo $a)
1

$ echo $a
0
```