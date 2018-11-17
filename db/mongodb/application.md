# 应用
## 海量数据的处理
场景：PB级别数据存储，从中获取访问次数最多的 ip 地址。

1.准备测试数据：以 uuid表示 ip
```
$ vim mongo_insert.sh
#!/bin/bash
set -o errexit

i=0
while [[ 10#$i -lt 10000 ]]
do
  echo "[Info] Current i = $i, Insert Data, uuid:$uuid, count:$count"
  uuid=$(uuidgen)
  count=$RANDOM
  mongo --host master2 --eval "db=db.getSiblingDB(\"local\");db.cols.insert({\"uuid\": \"$uuid\", \"count\": \"$count\"})"
  echo
  let i=i+1
done

$ ./mongo_insert.sh
...
[Info] Current i = 9998, Insert Data, uuid:8905e0aa-0885-4564-a951-c65f75ab8f53, count:22527
MongoDB shell version: 2.6.11
connecting to: bascker-master2:27017/test
WriteResult({ "nInserted" : 1 })

[Info] Current i = 9999, Insert Data, uuid:33fa0bf5-d757-4888-827a-871b1659a22e, count:25949
MongoDB shell version: 2.6.11
connecting to: bascker-master2:27017/test
WriteResult({ "nInserted" : 1 })

$ mongo --host master2
rs0:PRIMARY> db.cols.findOne()
{
    "_id" : ObjectId("58bd266bfee639391542fde6"),
    "uuid" : "0a3b37ee-e19e-49e7-b9af-c10f4856df08",
    "count" : "2083"
}
```

2.统计值
```
# 访问次数为 2083 的 ip 地址有多少个
rs0:PRIMARY> db.cols.count({"count": "2083"})
2

# 获取访问最多次的 ip
rs0:PRIMARY> db.cols.find().sort({"count": -1}).limit(1).pretty()
{
    "_id" : ObjectId("58bd26ed836ca5cb38c4eea2"),
    "uuid" : "bb761529-88b2-4e53-bdfb-c60797415eb6",
    "count" : "9990"
}

rs0:PRIMARY> db.cols.find().sort({"count": -1})
{ "_id" : ObjectId("58bd26ed836ca5cb38c4eea2"), "uuid" : "bb761529-88b2-4e53-bdfb-c60797415eb6", "count" : "9990" }
{ "_id" : ObjectId("58bd27b55519b46fd8afbfff"), "uuid" : "8dbcbec0-2cba-4e4e-82e5-19369312425c", "count" : "9988" }
{ "_id" : ObjectId("58bd26ec338fe924d5474f9a"), "uuid" : "cdec5ffe-7ae2-4d60-bc1c-742dc03b4ce1", "count" : "9987" }
{ "_id" : ObjectId("58bd2765e8bbd93d107399cc"), "uuid" : "9cfd6a8b-d5ec-4a59-b0f9-1969361b48c1", "count" : "9984" }
{ "_id" : ObjectId("58bd28a39ecfd23dad4064a0"), "uuid" : "a34e66da-ac35-4ddb-963c-c9bba104aa1f", "count" : "9984" }
{ "_id" : ObjectId("58bd27f45103be40cfe7b1aa"), "uuid" : "53c70f17-ef2a-422a-a540-998654a8f854", "count" : "9981" }
{ "_id" : ObjectId("58bd269af6ac26ac13213f48"), "uuid" : "6696a5cf-c705-4233-a588-9d91e90c9e42", "count" : "9980" }
{ "_id" : ObjectId("58bd26eac6d0fa3fc34ad1bc"), "uuid" : "30940b2b-2e16-4a29-8c85-7d76a2323709", "count" : "9976" }
{ "_id" : ObjectId("58bd2915f3eae4d5759b1401"), "uuid" : "3f6e9c33-a4c3-49e6-b4d8-a18a15496cdf", "count" : "9974" }
{ "_id" : ObjectId("58bd272ab0bfb0595375f39a"), "uuid" : "ddda103c-97f9-481b-b1fa-9605e55a400f", "count" : "9969" }
{ "_id" : ObjectId("58bd297b973051032cb93add"), "uuid" : "e48635df-d60a-4cbc-a7da-fcf234233f82", "count" : "9961" }
{ "_id" : ObjectId("58bd28565cc1c060e377b8ea"), "uuid" : "105d3552-1fe2-4602-a675-5456d2886918", "count" : "9960" }
{ "_id" : ObjectId("58bd27489b1e77c913473580"), "uuid" : "111d47e9-977a-43c3-b01e-289efeec3082", "count" : "9958" }
{ "_id" : ObjectId("58bd26b888f278b0abb3a7df"), "uuid" : "c590f500-24e3-4e29-9952-9728cdee9132", "count" : "9957" }
{ "_id" : ObjectId("58bd28a9391414fca90cbbc2"), "uuid" : "ecebbf86-665f-4aeb-9a22-fc3ef38c0f17", "count" : "9950" }
{ "_id" : ObjectId("58bd2959e8b9fa7370ad0343"), "uuid" : "1ec8eb88-8664-4a4d-817a-6c7cfb7a6f8c", "count" : "9945" }
{ "_id" : ObjectId("58bd26890c7a12b790add4c2"), "uuid" : "009dbcb9-d32c-4d86-986f-b84a98b5e756", "count" : "9935" }
{ "_id" : ObjectId("58bd274b3c33a9ee2e5abe90"), "uuid" : "a11600cf-0c91-413c-b76a-c66733b9df93", "count" : "9935" }
{ "_id" : ObjectId("58bd276d2b3db848414c5562"), "uuid" : "d6f6d9ef-0384-4d62-bf65-aecfa26feca6", "count" : "9935" }
{ "_id" : ObjectId("58bd27ea8332f1b06a9792ec"), "uuid" : "b3cb7cca-1e97-478c-be45-0a0c904104df", "count" : "993" }
```