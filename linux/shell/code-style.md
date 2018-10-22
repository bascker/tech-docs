# Shell代码规范
## 命名规定

1.文件名、变量名、函数名不超过20个字符

2.只能使用英文字母，数字和下划线

3.只有一个英文单词时使用全拼，有多个单词时，使用下划线分隔，长度较长时，可以取单词前3～4个字母

4.文件名全部以小写命名，不能大小写混用

## 函数规定

1.函数名称应该采用小写的形式

2.函数名称应该容易让人理解

3.不要把函数名称命名为常见的命令名

4.除非绝对必要，则仅使用字母、数字和下划线作为函数名称

5.函数控制在50－100行，超出行数建议分成两个函数

6.所有函数定义应该在脚本主要代码执行之前

7.应该使用可移植性高的函数定义形式，即不带function关键字的形式

8.每行不要超过80字，如果超出，建议用“\”折行

9.命令替换符，最好用 _**$\(\)**_ 替代
：如 _a=\`docker ps\`_ 最好用 _a=$\(docker ps\)_ 替换，a 的结果都一样

## 参考文献

1.Shell代码规范：[http://blog.csdn.net/wirelessqa/article/details/18863403](http://blog.csdn.net/wirelessqa/article/details/18863403)

2.shell 编码规范：[http://blog.csdn.net/liuxincumt/article/details/7987712](http://blog.csdn.net/liuxincumt/article/details/7987712)