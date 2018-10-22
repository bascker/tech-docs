# set 设置
## 简介

* 用于显示系统中已存在的 shell 变量，以及设置新变量
* 用于开启/关闭 shell 的特性
* 使用 "**-**" 和 "**+**" 分别表示：开启选项，关闭选项
* 开启特性的 2 种方法：
  1. 使用 set -\[特性简称\]的方式：如 set -e 开启 errexit
  2. 使用 set -o 显式指定

## 案例

1.查看当前的set选项配置情况：_set -o _

```
$ set -o
allexport          off
braceexpand        on
emacs              on
errexit            off
errtrace           off
functrace          off
hashall            on
histexpand         on
history            on
...
vi                 off
xtrace             off            # 追踪程序执行情况，可用于 bash 调试
```

2.开启 errexit 特性：命令执行失败时，shell 退出

```
$ vim test.sh
#!/bin/bash

set -o errexit        # 开启 errexit
sh a.sh
echo "a.sh"

echo aa

echo bcd
sh b.sh
sh c.sh
set +o errexit        # 关闭 errexit
```

> 注： set -e  也是指定开启 errexit 特性， 和 set -o errexit 一样的效果

3.开启 xtrace

```
$ vim test.sh
#!/bin/bash
set -o xtrace
set -o errexit
sh a.sh
echo "a.sh"

set +o errexit

$ sh test.sh
+ set -o errexit
+ sh a.sh
sh: a.sh: No such file or directory
```