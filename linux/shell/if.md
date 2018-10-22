# if 判断

## 判断变量是否存在: _\[ -e "${VARIABLE}" \]_

利用 _**\[ -e "${VARIABLE}" \]**_

## if 关键字

shell 中 0 为真，非 0 为假；常用判断如下

1.**==**：判断字符串是否相等

```
$ if [ $img == "cirros" ]; then  echo cirros; fi
```

2.**-a**：如果 FILE 存在则为真

3.**-f**：如果文件存在

4.**-d**：如果 FILE 存在且是一个目录则为真

5.**-s**：如果 FILE 存在且大小不为 0 则为真

```
# 删除当前目录下所有无效文件
$ files=`ll | awk '{print $9}'`
$ for file in $files; do    if [ ! -s $file ];then     echo $file; rm -f $file;   fi; done
```

6.**-r**：如果 FILE 存在且是可读的则为真

```
if [ -r ~/a.txt ]; then     # 若要取反，则写成 [ ! -r ~/a.txt ]
    cat a.txt
else
    cat no such file
fi
```

7.判断变量是否存在

* 方法1：使用 _**\[ -e "${VARIABLE}" \]**_  可以判断变量是否存在

```
$ [ -e "${aaa}" ] || echo "Not the variable aaa..."
Not the variable aaa...
```

* 方法2：使用 _**\[ ! $VAR \]**_ 判断变量是否存在.通过，则表示不存在，不通过表示存在

```
$ echo $b
$ if [ ! $b ];then
    echo "Var b is null!"
  else
    echo "Var b not null!"
  fi

### 输出
Var b is null!
```

8.数字比较

* -**ne**：不等于
* -**eq**：等于
* -**lt**：小于
* -**le**：小于等于
* -**gt**：大于
* -**ge**：大于等于