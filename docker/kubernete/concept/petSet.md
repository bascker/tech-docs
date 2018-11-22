# PetSet
## 一、简介
petset 也是 rc 的一种变体，但不提供副本扩容的功能。利用 petset 创建的 pod 其名字是固定的，而不是随机的。 如定义时取得名字
为 rabbitmq,则若副本为3，则3个pod的名字分别为 rabbitmq-0, rabbitmq-1,rabbitmq-2。

缺点：
* 不提供副本扩容功能
* pod 启动节点不确定：与 deployment 一样，不确定 pod 在哪个节点上启动， 如副本为3的horizon，可能 3 个 horizon 都会在con1 上创建。