# Module

## 简介

MXNet将数据集进行训练，训练的结果就是模型。训练和预测模型的接口就是 **module**\(简称 **mx.mod**\)，该包为执行预定义网络提供了中间层和高层接口。

一个`Module`包含着 1 个`Symbol`和 1个或多个`Executor`，一个 Module 代表着一个计算组件，设计 Module 的目的是可以抽象出一个可以接受 symbol 编程和数据的计算"Machine", 基于此可以向前、向后、更新 parameters 等等。

## 状态

一个 Module 有以下几个状态：

1._**Initial state**_：初始化状态，内存尚未分配，还没有做好计算准备

```
mod = mx.mod.Module(symbol=net)
```

2._**Binded**_：绑定状态，输入、输出的 shape 以及 paramters 都已经知道了，分配好内存，做好了计算准备

```
# 告诉 module 数据和标签类型后，开始进行内存分配
mod.bind(data_shapes=train_iter.provide_data, label_shapes=train_iter.provide_label)
```

3._**Parameter initialized**_：初始化 Parameter

```
mod.init_params(initializer=mx.init.Xavier(magnitude=2.))
```

4._**Optimized installed**_：将优化器加入 module。

```
mod.init_optimizer(optimizer='sgd', optimizer_params=(('learning_rate', 0.1), ))
```

## 基础

1.**创建** module：_**mx.mod.Mudule\(\)**_

创建 module 的语法格式如下：

```
mod = mx.mod.Module(symbol=net,
                    context=mx.cpu(),
                    data_names=['data'],
                    label_names=['softmax_label'])
```

参数解释：

* _**symbol**_：网络标志
* _**context**_：执行上下文，默认值是 mx.cpu\(\)，若支持 gpu，可以指定使用 mx.gpu\(\)
* _**data\_names**_：数据集名称
* _**label\_names**_：标签集名称

2.**加载**数据 params：_**load\_checkpoint\(model\_prefix, index\)**_

可以利用 _**load\_checkpoint\(model\_prefix, index\) **_从以训练的模型数据中获取 symbol 和相关数据

```
# 从 mnist-00003.params 中获取数据
model_prefix = "mnist"
sym, arg_params, aux_params = mx.model.load_checkpoint(model_prefix, 3)
```

3.**保存**数据 params：_**mx.callback.do\_checkpoint\(model\_prefix\)**_

利用 _**mx.callbac：k.do\_checkpoint\(model\_prefix\) **_来保存每次 epoch 训练 model params 数据

```
# construct a callback function to save checkpoints
model_prefix = 'mx_mlp'
checkpoint = mx.callback.do_checkpoint(model_prefix)

mod = mx.mod.Module(symbol=net)
mod.fit(data.get_iter(batch_size), num_epoch=5, epoch_end_callback=checkpoint)

### 输出
INFO:root:Epoch[0] Train-accuracy=0.140625
INFO:root:Epoch[0] Time cost=0.062
INFO:root:Saved checkpoint to "mx_mlp-0001.params"
INFO:root:Epoch[1] Train-accuracy=0.106250
INFO:root:Epoch[1] Time cost=0.075
INFO:root:Saved checkpoint to "mx_mlp-0002.params"
...
```

4.**继续**训练：_**fit\(\) + begin\_epoch\(\)**_

可以利用 _**fit\(\) + begin\_epoch\(\)**_ 来继续从某一个 epoch 开始训练

```
mod = mx.mod.Module(symbol=sym)
mod.fit(data.get_iter(batch_size),
        num_epoch=5,
        arg_params=arg_params,
        aux_params=aux_params,
        begin_epoch=3)

### 输出
INFO:root:Epoch[3] Train-accuracy=0.115625
INFO:root:Epoch[3] Time cost=0.064
INFO:root:Epoch[4] Train-accuracy=0.115625
INFO:root:Epoch[4] Time cost=0.058
...
```

### 案例：使用简单的 mlp 来处理数据集

_**mlp**_ 即 _**multilayer preception**_，译为**多层感知机**，是一种**前向结构**的**人工神经网络**，将一组输入向量映射到一组输出向量，由多个节点层所组成，每一层都全连接到下一层。除了输入节点，每个节点都是一个带有非线性激活函数的神经元（或称处理单元）。使用 反向传播算法 Backpropagation 进行训练。**克服了感知机不能对线性不可分数据进行识别的弱点**。

## 参考文献
1.官方API：[http://mxnet.io/tutorials/python/module.html](http://mxnet.io/tutorials/python/module.html)