# 数组
## 基础
Shell 支持数组的定义，但也**仅支持一维数组**。数组下标从 0 开始计数。

1.声明数组的语法如下：

```
# 以圆括号 () 包裹数组元素，数组元素以空格分离，也可回车
arr=(x y z ...)
arr=(x
     y
     z
     ...)
```

2.数组元素的读取

* 按下标获取：_**${arr\[index\]}**_

  ```
  $ arr=(1 2 3)
  $ echo ${arr[1]}
  2

  # $arr = ${arr[0]}
  $ echo ${arr}
  1
  $ echo $arr
  1
  ```

* 获取所有值：_**${arr\[@\]}**_ 或 _**${arr\[\*\]}**_

  ```
  $ echo ${arr[*]}
  1 2 3
  $ echo ${arr[@]}
  1 2 3
  ```

* 获取数组长度：_**${\#arr\[@\]}**_
  ```
  # 与获取字符串长度一样的写法
  $ echo ${#arr[@]}
  3
  $ echo ${#arr[*]}
  3

  # 获取字符串长度
  $ str=123456
  $ echo ${#str}
  6
  ```

## 案例
```
!/bin/bash
# test download img form glance

# 数组的声明
nums=(0 1 2 3 4 5 6 7 8 9)
source ~/admin-openrc.sh
img_id=$(glance image-list | awk '/ cirros / {print $2}')
echo $img_id

# for循环遍历数组
for i in ${nums[@]}
do
  echo "Download imgs as cirros$i..."
  glance image-download --file cirros$i $img_id
done
```