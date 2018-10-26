# uniq
## 简介

用于报告或忽略文件中的重复行，一般与\`sort\`命令结合使用

## 选项
* _\`-c\`_：在每列旁边显示该行重复出现的次数
* _\`-d\`_：仅显示重复行列
* _\`-u\`_：仅显示出一次的行列，使用 uniq 时默认使用 -u 选项

## 案例

```
$ cat test.txt
111
333
222
aaa
bbcc
ff
ff
dd
111

$ sort test.txt | uniq
111
222
333
aaa
bbcc
dd
ff
```