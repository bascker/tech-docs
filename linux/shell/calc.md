# 数字计算

## let 的使用

```
$ i=1

# let 中会自动读取变量值
$ let d=i+1
$ echo $d
2
$ echo $i
1

$ let i+=1
$ echo $i
2
```

_**\(\(\)\) **_的使用

```
$ i=1
$ echo $((i+1))
2
```

## 数字计算中 value too great for base 的进制问题

shell默认使用**八进制**。因此若在比较时使用 08, 09 来进行比较，则会报错。解决办法：告诉shell使用什么进制

```
$ i=09
$ if [[ $i -lt 10 ]]; then echo "$i < 10"; fi
-bash: [[: 09: value too great for base (error token is "09")

# 解决办法：告诉使用10进制。在数字变量前加上 "10#" 即可
$ if [[ 10#$i -lt 10 ]]; then echo "$i < 10"; fi
09 < 10
```