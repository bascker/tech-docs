# awk
## 一、简介
用于对文本和数据进行处理

## 二、案例
1.显示某一列
```
# 显示 test.txt 中的第二列文本，注意是单引号包裹
$ cat test.txt | awk '{print $2}'

# 获取文本最后一列
$ cat test.txt | awk '{print $NF}'

# 获取文本倒数第二列
$ cat test.txt | awk '{print $(NF-1)}'
```

2.组合列值
```
$ docker images | grep binary | grep 10| awk '{print $1":"$2}'
registry:5000/kolla/centos-binary-ceph-osd:3.0.0
registry:5000/kolla/centos-binary-ceilometer-api:3.0.0
```

3.显示匹配条件的数据
```
$ glance image-list
+--------------------------------------+---------------+
| ID                                   | Name          |
+--------------------------------------+---------------+
| 8b2905e9-64c2-43f4-91e2-4e8bb52a33b7 | cirros        |
| 849e3aa9-3208-4c77-954e-4342ba662e80 | parent_cirros |
| 855ce044-1edd-41f1-899f-57f3a62f03ef | son_cirros    |
| dc82bf6b-3293-4d6b-a842-91ab2d915c91 | son_cirros2   |
+--------------------------------------+---------------+

$ glance image-list | awk '/ cirros / {print $2}'
8b2905e9-64c2-43f4-91e2-4e8bb52a33b7
```

4.获取xml元素值
```
$ cat test.xml
<root>
  <name>bascker</name>
</root>

# 获取 name 标签元素值
$ cat test.xml | grep name | awk -F ">" '{print $2}' | awk -F "<" '{print $1}'
bascker
```