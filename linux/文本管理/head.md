# head
## 简介

显示输出前 n 行，默认是 10

## 案例

1.显示输出前 1 行

```
$ head -n 1 test.py
#!/usr/bin/evn python
```

2.显示除最后160行外的所有行

```
$ head -n -160 test.py
#!/usr/bin/evn python
# -*- coding:utf-8 -*-

import sys
from optparse import OptionParser

def validate_arg_value(arg_val):
```