# sed
## 简介
用于字符串匹配替换，支持正则式

## 操作
1.追加文本

```
# 在第2行后添加文本 111
$ echo -e "aaa\nbbb\nccc" | sed "2a 111"
aaa
bbb
111
ccc

# sed 追加带空格的文本行：使用 \
$ echo -e "aaa\nbbb\nccc" | sed "1a\   222"
aaa
   222
bbb
ccc

# 某文本行 aaa 后追加数据 111
$ echo -e "aaa\nbbb\nccc" | sed "/aaa/a\111"
aaa
111
bbb
ccc
```

> a：表示 append，即追加

2.文本替换

```
# sed 中分割字符串不一定只能用 /，还可以使用 @, #
$ echo "11aa22bb" | sed "s@aa@cc@g"
11cc22bb

# 利用 @ 或 # 解决特殊字符的问题
$ a=/bin/bash
$ echo 111/bin/bash222bbb | sed "s@$a@$a ---@g"
111/bin/bash ---222bbb

$ echo 111/bin/bash222bbb | sed "s#$a#$a ---#g"
111/bin/bash ---222bbb

# 替换指定行的内容： sed "${lineNum}s/old_str/new_str/"
$ vim test.txt
111
222
333
aaa
444
444
ccc
444

$ cat aaa | sed "5s/444/bbb/"
111
222
333
aaa
bbb            # 被替换了
444
ccc
444
```

3.删除

```
# 删除2~4行：d表示delete,删除
$ echo -e "aaa\nbbb\nccc\nddd\eee\nfff" | sed "2,4d"

# 删除某文本行
$ echo -e "aaa\nbbb\nhello\nccc" | sed "/hello/d"
aaa
bbb
ccc
```

4.修改直接作用于文件,选项** -i **表示直接作用在文件

```
$ sed -i "${line_num}a INSECURE_REGISTRY='--insecure-registry 10.158.113.158:5000'" docker.conf

# 将 test.txt 中的 123456 替换成 aaaa
$ sed -i "s/123456/aaaa/g" test.txt
```

> 注：sed 一般使用单引号包裹，但若在 sed 中要使用变量，则不能用单引号包裹，只能用双引号