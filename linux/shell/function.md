# 函数
## 基础

1.**声明**：使用 _**function **_关键字

```
function print(){
    str=$1                 # 获取传递的参数
    echo $str
}
```

2.**调用**：直接使用函数名

```
$ print aaa                 # 调用 print 函数，传入参数 aaa
```

3._**local**_ 关键字：**只能用于函数中**声明局部变量。shell 默认都是全局变量

4.**参数获取**：$XXX

* _**$\#**_：参数个数
* _**$0**_：脚本执行名字。若在脚本的函数中使用，则表示传入函数的第一个参数
* _**$n**_：第n个参数值
* _**$\***_：所有参数,此选项参数可超过9个
* _**$$**_：脚本PID，当前进程ID
* _**$?**_：执行上一个指令的返回值，0表示没有错误，其他任何值表明有错误
* _**$@**_：跟 _**$\***_ 类似，但是可以当作数组用

5.**返回字符串类型数据**

shell 函数 _**return **_**只能返回整数类型的数据**，而无法返回字符串类型的数据。那么如何来通过函数获取一个字符串的返回呢？

```
$ vim common.conf
[DEAULT]
uname = johnnie
upass = 123456

$ vim test.sh
#!/bin/bash

function get_value() {
    key=$1
    grep $key common.conf | awk '{print $3}'
}

uname=$(get_value uname)
echo $uname

$ sh test.sh
johnnie
```

若该为 return 返回，则会报：_numeric argument required_

```
$ vim test.sh
function get_value() {
    key=$1
    value=$(grep $key common.conf | awk '{print $3}')
        return $value
}
...

$ sh test.sh
test.sh: line 6: return: johnnie: numeric argument required
```