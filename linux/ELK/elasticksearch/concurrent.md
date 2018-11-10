# 并发
既然 Elasticsearch 是面向文档型数据库，那么就得面对并发的问题。对于 Elasticsearch，其并发冲突的情况有 2 种：
1. 由 Elasticsearch 存储数据的情况下，进行并发操作导致的数据不一致
2. 数据存储使用其他数据库(如 MariaDB)，Elasticsearch 负责检索的情况下，并发操作时，主数据库数据并更，数据拷贝到 Elasticsearch _时数据不一致

如何在并发情况下，避免丢失数据呢？

## 悲观并发控制（PCC）
此方法在关系数据库中被广泛使用。假设这种情况很容易发生，我们就可以阻止对这一资源的访问。典型案例：当我们在读取一个数据前先锁定这一行，然后确保只有读取到数据的这个线程
可以修改这一行数据。

## 乐观并发控制（OCC）
Elasticsearch 所使用的方法。假设这种情况并不会经常发生，也不会去阻止某一数据的访问。然而如果基础数据在我们读取和写入的间隔中发生了变化，更新就会失败。这时候就由程序
来决定如何处理这个冲突。例如，它可以重新读取新数据来进行更新，又或者它可以将这一情况直接反馈给用户。

## _version
Elasticsearch 使用 `_version`来确保所有改变操作都被正确排序，利用 `_version`确保程序修改的数据冲突不会造成数据丢失。每当有 PUT, DELETE 操作时，无论操作是否成
功，其 `_version`值都会增加
```
# 当文档的 _version 值为 2 时更新文档数据
$ curl -X PUT 'elastic:9200/github-2018.01.10/ceilometer/AVmHuCtvm_RLDnunMYID?version=2' -d '{"id": "29248", "modul": "ceilometer"}'
```

## retry_on_conflict
对局部更新的冲突来说，可以通过设置 retry_on_conflict 来设置自动完成这项请求的次数(默认值为 0)。该参数非常适用于类似于增加计数器这种无关顺序的请求
```
$ curl -X POST 'elastic:9200/github-2018.01.10/ceilometer/AVmHuCtvm_RLDnunMYID/_update?retry_on_conflict=5'
-d '{"id": "29248", "modul": "ceilometer"}'
```

## 使用外部数据库存储的情况
使用外部数据库存储数据的情况下，Elasticsearch 会检查当前的`_version`是否比指定的数值(数据库版本号)小。如果请求成功，那么外部的版本号就会被存储到文档中的`_version`中。

