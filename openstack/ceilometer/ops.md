# 常用操作

> ceilometer 查询 -q 的有效 key：\[_**'message\_id', 'meter', 'project', 'resource', 'search\_offset', 'source', 'timestamp', 'user'**_\]

1.查看计量项列表

```
$ ceilometer meter-list
```

2.查看资源列表

```
$ ceilometer resource-list
# 条件过滤
$  ceilometer resource-list -q resource=ff8c7fe4-a22c-471d-866a-e8d8e8a78f5c
+--------------------------------------+-----------+----------------------------------+----------------------------------+
| Resource ID                          | Source    | User ID                          | Project ID                       |
+--------------------------------------+-----------+----------------------------------+----------------------------------+
| ff8c7fe4-a22c-471d-866a-e8d8e8a78f5c | openstack | 5b739822c6ce4b8691d2d23e90ff0b7e | 7c9445d1db4e49ce9fe283829b199d6d |
+--------------------------------------+-----------+----------------------------------+----------------------------------+
```

3.查看某资源：

语法：**ceilometer resouce-show RESOURCE\_ID**

```
$ ceilometer resource-show ff8c7fe4-a22c-471d-866a-e8d8e8a78f5c
+-------------+--------------------------------------------------------------------------+
| Property    | Value                                                                    |
+-------------+--------------------------------------------------------------------------+
| metadata    | {u'state_description': u'', u'image_meta.base_image_ref':                |
|             | ...                                                                      |
| project_id  | 7c9445d1db4e49ce9fe283829b199d6d                                         |
| resource_id | ff8c7fe4-a22c-471d-866a-e8d8e8a78f5c                                     |
| source      | openstack                                                                |
| user_id     | 5b739822c6ce4b8691d2d23e90ff0b7e                                         |
+-------------+--------------------------------------------------------------------------+
```

# 参考文献
1.官网：[https://docs.openstack.org/admin-guide/telemetry-data-retrieval.html\#publishers](https://docs.openstack.org/admin-guide/telemetry-data-retrieval.html#publishers)