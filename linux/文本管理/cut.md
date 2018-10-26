# cut
## 简介

1.用于文本处理，如显示行中的指定部分、删除文件中指定字段。

2.可用于显示文本内容

3.用于连接多个文件，将多个文件内容拼接成一个文件

4.常用选项

* -b：以字节为单位分割，仅显示行中指定范围的内容
* -c：以字符为单位分割，仅显示行中指定范围内的字符
* -d：指定字段分隔符。默认为 _**TAB**_
* -f：显示指定字段的内容
* -n：与 -b 连用，不分割多字节字符
* --complement：取补集，即显示指定范围外的内容

## 案例

1.分割 CIDR 地址：使用 -d 指定字段分隔符为 /。使用 -f 指定显示分隔后第 n 列值

```
$ cidr="10.158.113.33/24"

# 第一列值：ip
$ echo $cidr | cut -d / -f 1
10.158.113.33

# 第二列值掩码
$ echo $cidr | cut -d / -f 2
24
```

2.读取文本内容

```
$ cat file.txt
111
222
333
aaa
bbb ccc
ddd

$ cut -f 1 file.txt
111
222
333
aaa
bbb ccc
ddd

# 每行按空格分割
$ cat file.txt | cut -d " " -f 1
111
222
333
aaa
bbb
ddd

$ cat file.txt | cut -d " " -f 2
111
222
333
aaa
ccc
ddd
```

> 注：根据显示结果可知，根据指定分隔符分割文本的话，若某行根据该分隔符无法分割，则显示整行

3.按空格分割文本

```
$ s="11 22 33"
$ echo $s | cut -d " " -f 1
11
```

4.取补集

```
$ s="11 22 33"
$ echo $s | cut -d " " -f 3
33
$ echo $s | cut -d " " -f 3 --complement
11 22
```

5.字符串处理

```
# 获取字符串中的的某字符
$ str=node5
$ echo $str | cut -c 1                        # 获取首字符
n
$ echo $str | cut -c 3                        # 获取第3个元素
d
$ echo $str | cut -c ${#str}                  # 获取最后一个元素
5

# 获取字符串的子串
$ echo $str | cut -c 1,${#str}                # 获取首尾字符串拼接后的子串
n5
$ echo $str | cut -c -2                       # 获取前2个字符组成的子串
no
$ echo $str | cut -c -4                       # 获取前四个字符组成的子串
node
$ echo $str | cut -c -2,${#str}               # 获取前2个字符和尾字符组成的子串
no5

# 分割字符串
$ str=1,2,3,4,5
$ echo $str | cut -d "," -f 2                 # 按逗号分割，取分割后的第二列值
2
$ echo $str | cut -d "," -f 1 --complement    # 取补集
2,3,4,5
```