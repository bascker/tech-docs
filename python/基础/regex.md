# 正则表达式
分组正则式
```
import re

log = "2017-02-16T13:38:05.282+0800 [clientcursormon]  replication threads:32"
reg = "^(?P<time>\d[^\s]*)\s*(?P<message>\[\w*\].*)"
pattern = re.compile(reg)
match = re.match(pattern, log)

print match.group(0)
print match.group(1)
print match.group(2)

### 输出
2017-02-16T13:38:05.282+0800 [clientcursormon]  replication threads:32
2017-02-16T13:38:05.282+0800
[clientcursormon]  replication threads:32
```