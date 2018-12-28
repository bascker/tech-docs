# dos2unix
## 一、简介
用于将 DOS 格式文本转为 Unix 格式。在 windows 下编辑后的文件，传送到 unix 系统后，
常发生格式错误（比如 windows 下编辑的 shell脚本，传到 linux 后，运行报`xxx \r`），
这时候就可以使用 `dos2unix` 来解决。

## 二、使用
基础使用如下
```
$ dos2unix [-hkqV] [-c convmode] [-o file ...] [-n infile outfile ...]
-h  --help               帮助文档
-k  --keepdate           保持时间戳一致
-q  --quite              安静模式，禁止所有警告
-V  --version            显示版本
-c  --convmode           转换模式, ASCII（默认）, 7bit, ISO, Mac
-l  --newline            除MAC模式外，新增一行
-o  --oldfile            写旧文件
file ...                 转成旧文件
-n  --newfile            写新文件
infile                   原始文件
outfile                  输出文件
```

将当前目录下的所有文件，转为 unix 格式
```
$ doc2unix *
```