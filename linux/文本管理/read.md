# read
## 简介
获取用户输入

## 案例
```
$ vim test_read.sh
#!/usr/bin/env bash

echo -n "[info]Are you sure delete all old images[y/n]?"
read isDel
if [[ "$isDel" == "Y" || "$isDel" == "y" ]];then
  docker rmi $(docker images | grep kolla | awk '{print $3}')
fi
```