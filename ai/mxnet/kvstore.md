# KVStore

## 简介

使用  mxnet.kv 来创建 KVStore，提供分布式训练支持\(需要 GPU 的支持\)

```
mxnet.kvstore.create(name='local')     # 创建一个 KVStore 对象

class mxnet.kvstore.KVStore(handle)
    // 方法
    init(key, value)                    # 初始化一个或多个 key,value 键值对
    push(key, value, priority=0)        # 添加一个或多个键值对, 优先级越高，后台引擎执行 push 越快
    pull(key, out=None, priority=0)     # 获取对应一个或多个 key 的值
    set_optimizer(optimizer)
    save_optimizer_states(fname)        # 存储 optimizer/updater 的状态到文件
    load_optimizer_states(fname)

    // 属性
    type                                # kvstore 的存储类型
    rank                                # 当前工作节点在集群中的序列号 [0, get_num_workers())
    num_workers                         # 获取工作节点数
```

## 操作

1.**创建** KVStore 并**初始化**：`mxnet.kv.create() + kv.init()`

```
>>> import mxnet as mx
>>>
>>> kv = mx.kv.create('local');                     # 创建一个本地 kv 存储
>>> kv
<mxnet.kvstore.KVStore object at 0x7f73cb52c710>
>>>
>>> shape = (2, 3)
>>> kv.init(3, mx.nd.ones(shape) * 2)               # 初始化一个 key = 3 ,value = mx.nd.ones(shape) * 2 的键值对
>>> a = mx.nd.zeros(shape)
>>> a.asnumpy()
array([[ 0.,  0.,  0.],
       [ 0.,  0.,  0.]], dtype=float32)
>>>
>>> kv.pull(3, out = a)                             # 从 kvstore 中拉取 key = 3 的数据，并输出到 a
>>> a.asnumpy()
array([[ 2.,  2.,  2.],
       [ 2.,  2.,  2.]], dtype=float32)

# KVStore 支持生成一个 key,value 键值对列表
(1) 单设备上的方式
>>> keys = [5, 7, 9]
>>> kv.init(keys, [mx.nd.ones(shape)] * len(keys))
>>> kv.push(keys, [mx.nd.ones(shape)] * len(keys))
Update on key: 5
Update on key: 7
Update on key: 9

(2) 多设备上的方式
>>> b = [[mx.nd.ones(shape, gpu) for gpu in gpus]] * len(keys)
>>> kv.push(keys, b)
update on key: 5
update on key: 7
update on key: 9
>>> kv.pull(keys, out = b)
>>> print b[1][1].asnumpy()
[[ 11.  11.  11.]
 [ 11.  11.  11.]]
```

创建KVStore 后**不是必须先初始化**，再添加键值对，可以直接添加。

```
>>> kv = mx.kv.create("local")
>>>
>>> kv.push(3, mx.nd.ones((2, 3)))
>>> a = mx.nd.array([[1,2,3], [2, 3, 4]])
>>>
>>> kv.pull(3, out = a)
>>> a.asnumpy()
array([[ 1.,  1.,  1.],
       [ 1.,  1.,  1.]], dtype=float32)
```

2.**添加**新的 key,value并**获取**值：`push(key, value) + pull(key, out = variable)`

```
>>> key = 2
>>> value = mx.nd.ones(shape) * 3
>>> kv.push(key, value)                              # 创建一个新的 key,value 键值对
>>> kv.pull(key, out = a)                            # 拉取值
>>> print a.asnumpy()
[[ 3.  3.  3.]
 [ 3.  3.  3.]]
```

3.**聚合**：将多个值传给相同的一个 key，当 push 时，KVStore 会**存储**这些值的**总和**

```
>>> gpus = [mx.gpu(i) for i in range(4)]
>>> [gpu(0), gpu(1), gpu(2), gpu(3)]
>>>
>>> b = [mx.nd.ones(shape, gpu) for gpu in gpus]      # 可以变为 cpu()
>>> b
[<NDArray 2x3 @gpu(0)>, <NDArray 2x3 @gpu(1)>, <NDArray 2x3 @gpu(2)>, <NDArray 2x3 @gpu(3)>]
>>>
>>> kv.push(3, b)
>>> kv.pull(3, out = a)
>>> print a.asnumpy()
[[ 4.  4.  4.]
 [ 4.  4.  4.]]
```

> 单台主机：
>
> 1. 使用 cpu\(\) push 时会有问题，报错：Segmentation fault \(core dumped\) --&gt; 猜测是 CPU\(\) 不支持此操作
> 2. 使用 gpu\(\) 在 b 的赋值就报错了：_\[02:16:02\] /root/mxnet/dmlc-core/include/dmlc/./logging.h:300: \[02:16:02\] src/c\_api/c\_api\_ndarray.cc:274: Operator \_ones cannot be run; requires at least one of FCompute&lt;xpu&gt;, NDArrayFunction, FCreateOperator be registered. ---&gt; _猜测是主机没设置 GPU 支持，不支持 GPU 导致

4.**更新时动作**：可以通过`_set_updater()`设置 _**updater **_来指定更新 key 时要触发的动作，默认的 **updater **是 **ASSIGN**

```
# 旧值
>>> kv.pull(3, out = a)
>>> a.asnumpy()
array([[ 4.,  4.,  4.],
       [ 4.,  4.,  4.]], dtype=float32)

# 设置 updater
>>> def update(key, input, stored):
...     print 'Update on key: %d' % (key,)
...     stored += input * 3                     # 存储的值 = 原始值 + 输入值 * 3
...
>>> kv._set_updater(update)

# 更新
>>> kv.push(3, mx.nd.ones(shape) * 2)
Update on key: 3
>>>
>>> kv.pull(3, out = a)
>>> a.asnumpy()
array([[ 10.,  10.,  10.],
       [ 10.,  10.,  10.]], dtype=float32)
```

5.kv存储**类型**：`kv.type`

```
>>> kv = mx.kv.create("local")
>>> kv.type
'local'
```

## 数据并行处理

多设备情况下的分布式训练，KVStore 的类型：

* _**local**_：本地存储，默认使用。单机情况下一般不需要改变
* _**device**_
* _**dist\_sync**_：分布式同步KVStore
* _**dist\_device\_sync**_
* _**dist\_async**_：分布式异步 KVStore

> 注：dist\_\* 的类型需要 mxnet 以`USE_DIST_KVSTORE = 1` 进行编译

MXNet 提供 tools/launch.py 脚本，支持以下 4 种运行Job的方式：

* _**ssh**_：
* _**mpi**_：
* _**sge**_：
* _**yarn**_：

## 参考文献
1.Run MXNet on Multiple CPU/GPUs with Data Parallel：[http://mxnet.io/how\_to/multi\_devices.html](http://mxnet.io/how_to/multi_devices.html)