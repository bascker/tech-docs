# 调试

调试是个很重要的技能，shell 调试有以下几种方法：

1.在 bash 行后加上 _**set -o xtrace，**_可以看到脚本的每个执行步骤

```
$ vim test.sh
#!/bin/bash
set -o xtrace

echo "aaa"
echo "bbb"

$ sh test.sh
+ echo aaa
aaa
+ echo bbb
bbb
```

2.使用 bash -x 开启 bash 调试

```
$ vim test.sh
#!/bin/bash

echo "aaa"
echo "bbb"

$ bash -x test.sh
+ echo aaa
aaa
+ echo bbb
bbb
```

3.代码块调试：使用 set -x 和 set +x 包裹

```
$ vim test.sh
#!/bin/bash

set -x
echo "aaa"
echo "bbb"
set +x

echo "ccc"
echo "111"
echo "222"

$ sh test.sh
+ echo aaa
aaa
+ echo bbb
bbb
+ set +x
ccc
111
222
```