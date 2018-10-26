# free
## 简介
* 显示Linux系统中空闲的、已用的物理内存及swap内存,及被内核使用的buffer
* 空闲内存大小 =  _free + buff/cached = total - used_

## 案例
```
$ free -h
              total        used        free      shared  buff/cache   available
Mem:           125G         62G        609M         60M         62G         62G
Swap:          4.0G        3.8G        233M
```