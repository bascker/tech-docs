# tar
## 简介
对文件进行归档处理

## 使用
1.将文件输入进行归档成 tar 包

```
$ tar -cvf FILE.tar INPUT
```

2.将 tar 包进行解压

```
$ tar -xvf FILE.tar -C OUTPUT
```

3.将输入归档成tar，并使用 gzip 进行压缩

```
$ tar -zcvf FILE.tar.gz INPUT
```

4.列出归档内容\(不释放归档\)

```
$ tar -tvf FILE.tar
```

## 案例
```
# 普通归档，将 test1.txt test2.txt 归档到 test.tar
$ tar -cvf test.tar test1.txt test2.txt

# 解压到 /root/ 下，否则默认在命令执行的当前目录下
$ tar -xvf test.tar -C /root/

# 加压使用 gzip 格式压缩的文件
$ tar -zxvf test.tar.gz
```