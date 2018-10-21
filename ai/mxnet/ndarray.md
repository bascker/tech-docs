# NDArray

## 简介

_**NDArray **_即多维数组\(multidimensional array\)，是 MXNet 中非常重要的一个对象，由`mxnet.ndarray` 或`mxnet.nd` 提供，它和 _Python _科学计算包 _**numpy **_中的 `numpy.ndarray` 很类似。

## 创建

可以使用`mxnet.nd.array` 来创建.，并可以使用`asnumpy()`来将 _NDAarray _对象**强转**`numpy.ndarray`对象，并使用`print`输出其值。如下所示创建一个 1-dimension array：

```
>>> import mxnet as mx
>>>
>>> a = mx.nd.array([1,2,3])
>>> a.asnumpy()
array([ 1.,  2.,  3.], dtype=float32)
>>> print a.asnumpy()
[ 1.  2.  3.]
```

若只知道多维数组大小，而不知道其元素值，可以有以下方法来创建，并预先分配空间

1._**zeros\(\)**_：创建数组，并初始化元素值为 0

```
# 创建一个 2 * 3 的矩阵，其初始化元素值全部为 0
>>> a = mx.nd.zeros((2, 3))
>>> a.shape
(2L, 3L)
>>> a.asnumpy()
array([[ 0.,  0.,  0.],
       [ 0.,  0.,  0.]], dtype=float32)
```

2._**ones\(\)**_：创建数组，并初始化元素值为 1

```
>>> b = mx.nd.ones((2, 3))
>>> b.asnumpy()
array([[ 1.,  1.,  1.],
       [ 1.,  1.,  1.]], dtype=float32)
>>>
>>> a = mx.nd.ones((2, 3, 4))
>>> a.asnumpy()
array([[[ 1.,  1.,  1.,  1.],
        [ 1.,  1.,  1.,  1.],
        [ 1.,  1.,  1.,  1.]],

       [[ 1.,  1.,  1.,  1.],
        [ 1.,  1.,  1.,  1.],
        [ 1.,  1.,  1.,  1.]]], dtype=float32)
```

3._**full\(\(n,m,...\), value\)**_：创建数组，并初始化元素值为 value

```
>>> c = mx.nd.full((2, 3), 7)
>>> c.asnumpy()
array([[ 7.,  7.,  7.],
       [ 7.,  7.,  7.]], dtype=float32)
```

4._**empty\(\)**_：创建数组，并根据内存状态随机赋值

```
>>> d = mx.nd.empty((2, 3))
>>> d.asnumpy()
array([[  0.00000000e+00,   0.00000000e+00,   1.26738287e-21],
       [  4.57313754e-41,   4.48415509e-44,   0.00000000e+00]], dtype=float32)
```

## 属性

_**NDArray **_对象的重要属性有：

1._ndarray**.shape**_：数组维度，是一个整型的 tuple.如矩阵为 n 行，m 列，则 shape 返回值为 \(n, m\)

```
>>> import mxnet as mx
>>>
>>> a = mx.nd.array([1,2,3])                # 使用 list 创建 1维array，可以看成是定义了一个 3维空间坐标点(1,2,3)
>>> a
<NDArray 3 @cpu(0)>                         # 存储在 cpu 中
>>> type(a)
<class 'mxnet.ndarray.NDArray'>
>>> a.shape
(3L,)
>>>
>>> b = mx.nd.array([[1,2,3], [4,5,6]])    # 使用嵌套 list 创建一个 2-dimension array
>>> b
<NDArray 2x3 @cpu(0)>                      # 一个 2*3 的矩阵
>>> type(b)
<class 'mxnet.ndarray.NDArray'>
>>> b.shape
(2L, 3L)

# 嵌套 list 长度必须一致
>>> b = mx.nd.array([[1,2,3], [4,5]])
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/local/lib/python2.7/dist-packages/mxnet-0.9.4-py2.7.egg/mxnet/ndarray.py", line 994, in array
    raise TypeError('source_array must be array like object')
TypeError: source_array must be array like object
```

2._ndarray_._**dtype**_：一个 numpy 对象，用来描述元素类型. 默认值是 numpy.float32，可修改

```
>>> a.dtype
<type 'numpy.float32'>
>>>
>>> import numpy as np
>>> a = mx.nd.array([1,2,3], dtype=np.int32)
>>> a.dtype
<type 'numpy.int32'>
>>>
>>> a = mx.nd.array([1,2,3], dtype=np.float16)
>>> a.dtype
<type 'numpy.float16'>
```

3._ndarray_._**size**_：数组中的所有元素值，其值等于 ndarray.shape  返回 tuple 中各元素乘积

```
>>> a.size
3                        # 1 * 3
>>> b.size
6                        # 2 * 3
```

4._ndarray_._**context**_：存储数组的设备，可以是 CPU 或 GPU

```
>>>
>>> a.context
cpu(0)
>>> b.context
cpu(0)
```

## 基础操作

1.基础计算

```
>>> a = mx.nd.ones((2, 3))
>>> b = mx.nd.ones((2, 3))

# 加法
>>> c = a + b
>>> print c.asnumpy()
[[ 2.  2.  2.]
 [ 2.  2.  2.]]
>>> c += a
>>> c *= a

# 减法
>>> d = -c                              # 变负值，相当于 d = 0 - c
>>> print d.asnumpy()
[[-2. -2. -2.]
 [-2. -2. -2.]]

# 乘法
>>> a = mx.nd.full((2, 3), 3)
>>> b = mx.nd.full(a.shape, 2)
>>> c = a * b
>>> print c.asnumpy()
[[ 6.  6.  6.]
 [ 6.  6.  6.]]

# 除法
>>> c = a / b
>>> print c.asnumpy()
[[ 1.5  1.5  1.5]
 [ 1.5  1.5  1.5]]

# sin
>>> e = mx.nd.sin(c ** 2)
>>> print e.asnumpy()
[[-0.7568025 -0.7568025 -0.7568025]
 [-0.7568025 -0.7568025 -0.7568025]]

# 矩阵转置
>>> e = mx.nd.sin(c ** 2).T
>>> print e.asnumpy()
[[-0.7568025 -0.7568025]
 [-0.7568025 -0.7568025]
 [-0.7568025 -0.7568025]]

# 组成大矩阵
>>> f = mx.nd.maximum(a, c)
>>> print f.asnumpy()
[[ 2.  2.  2.]
 [ 2.  2.  2.]]

>>> print a.asnumpy()
[[ 1.  1.  1.]
 [ 1.  1.  1.]]
>>> b = mx.nd.array([[0, 1, 2], [2, 1, 0]])
>>> f = mx.nd.maximum(a, b)
>>>
>>> print f.asnumpy()
[[ 1.  1.  2.]
 [ 2.  1.  1.]]
```

2.索引与切片：切片操作符 **\[ \]**

```
>>> a = mx.nd.array(np.arange(6).reshape(3,2))
>>> print a.asnumpy()
[[ 0.  1.]
 [ 2.  3.]
 [ 4.  5.]]
>>>
>>> a[1:2] = 1
>>> print a.asnumpy()
[[ 0.  1.]
 [ 1.  1.]
 [ 4.  5.]]
>>>
>>> a[:].asnumpy()
array([[ 0.,  1.],
       [ 1.,  1.],
       [ 4.,  5.]], dtype=float32)

>>> a = mx.nd.array(np.arange(6).reshape(3,2))
>>> b = mx.nd.slice_axis(a, axis=1, begin=1, end=2)
>>> b[:].asnumpy()
array([[ 1.],
       [ 3.],
       [ 5.]], dtype=float32)
```

3.操作 shape：_**reshape\(\)**_

对象的 shape 可以在赋值后通过`reshape()`方法改变。

```
>>> import numpy as np
>>>
>>> np.arange(24)
array([ 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16,
       17, 18, 19, 20, 21, 22, 23])

# 一维数组，长度 24
>>> a = mx.nd.array(np.arange(24))
>>> print a.asnumpy()
[  0.   1.   2.   3.   4.   5.   6.   7.   8.   9.  10.  11.  12.  13.  14.
  15.  16.  17.  18.  19.  20.  21.  22.  23.]
>>> a.shape
(24L,)

# 改变 shape，变成 2 个 3行4列 的 2 维数组
>>> b = a.reshape((2, 3, 4))
>>> print b.asnumpy()
[[[  0.   1.   2.   3.]
  [  4.   5.   6.   7.]
  [  8.   9.  10.  11.]]

 [[ 12.  13.  14.  15.]
  [ 16.  17.  18.  19.]
  [ 20.  21.  22.  23.]]]
>>> b.shape
(2L, 3L, 4L)

# 若小于之前的长度，则超出部分舍去： 2 * 3* 3 = 18 < 24, 舍去 18~23 的值
>>> b = a.reshape((2, 3, 3))
>>> print b.asnumpy()
[[[  0.   1.   2.]
  [  3.   4.   5.]
  [  6.   7.   8.]]

 [[  9.  10.  11.]
  [ 12.  13.  14.]
  [ 15.  16.  17.]]]
```

4.reduce 操作：_**sum\(\), sum\_axis\(\)**_

```
>>> a = mx.nd.array([np.arange(6), np.arange(6)])
>>> print a.asnumpy()
[[ 0.  1.  2.  3.  4.  5.]
 [ 0.  1.  2.  3.  4.  5.]]
>>> a.shape
(2L, 6L)

# sum()：归纳求和成一个值
>>> b = mx.nd.sum(a)        # 1 + 2 + 3 + 4 + 5 + 1 + 2 + 3 + 4 + 5 = 30
>>> b.dtype
<type 'numpy.float32'>
>>> b
<NDArray 1 @cpu(0)>
>>> b.asnumpy()
array([ 30.], dtype=float32)

# sum_axis()：分组归纳
>>> c = mx.nd.sum_axis(a, axis=1)
>>> c.asnumpy()
array([ 15.,  15.], dtype=float32)
```

5.广播：_**broadcast\_to\(\)**_

```
>>> a = mx.nd.array(np.arange(6).reshape(6,1))
>>> a.asnumpy()
array([[ 0.],
       [ 1.],
       [ 2.],
       [ 3.],
       [ 4.],
       [ 5.]], dtype=float32)
>>> b = a.broadcast_to((6,2))
>>> b.asnumpy()
array([[ 0.,  0.],
       [ 1.,  1.],
       [ 2.,  2.],
       [ 3.,  3.],
       [ 4.,  4.],
       [ 5.,  5.]], dtype=float32)

>>> c = a.reshape((2,1,1,3))
>>> c.asnumpy()
array([[[[ 0.,  1.,  2.]]],


       [[[ 3.,  4.,  5.]]]], dtype=float32)
>>> d = c.broadcast_to((2,2,2,3))
>>> d.asnumpy()
array([[[[ 0.,  1.,  2.],
         [ 0.,  1.,  2.]],

        [[ 0.,  1.,  2.],
         [ 0.,  1.,  2.]]],


       [[[ 3.,  4.,  5.],
         [ 3.,  4.,  5.]],

        [[ 3.,  4.,  5.],
         [ 3.,  4.,  5.]]]], dtype=float32)
```

6.复制：_**copy\(\)**_

深度复制和浅度复制的区别：

* **浅度复制**：只复制对象的基本类型,对象类型, 两个对象的**引用还是一样**
  ```
  # 普通重复值，就是浅度复制，将两个对象的引用指向同一个内存块
  >>> a = mx.nd.ones((2,2))
  >>> b = a
  >>> b is a
  True
  ```
* **深度复制**：不仅复制对象的基本类型，也复制原对象中的对象，产生新的对象。二个对象的**引用不一样**
  ```
  # copy() 复制出来的对象完全是独立的新对象，指向新的一个内存块
  >>> b = a.copy()
  >>> b is a
  False
  ```

7.GPU支持：_**mx.gpu\(\)**_

MXNet 默认使用的上下文是 cpu, 若主机支持 GPU，可以切换到 GPU 进行计算

```
def f():
    a = mx.nd.ones((100,100))
    b = mx.nd.ones((100,100))
    c = a + b
    print(c)

# 若支持 GPU，则切换上下文到 GPU 环境
with mx.Context(mx.gpu()):
    f()

# 也可以在创建 NDArray 是指定使用 mx.gpu()
>>> a = mx.nd.ones((100, 100), mx.gpu(0))
>>> a
<NDArray 100x100 @gpu(0)>
```

> 若不支持 GPU，则切换到 GPU 会报错：_Operator \_ones cannot be run; requires at least one of FCompute&lt;xpu&gt;, NDArrayFunction, FCreateOperator be registered_

8.存取数据到文件：_**save\(\) + load\(\)**_

```
# 存
a = mx.nd.ones((2,3))
b = mx.nd.ones((5,6))
mx.nd.save("temp.ndarray", [a,b])

# 取
c = mx.nd.load("temp.ndarray")
```

## 延迟计算与自动并行化：Lazy Evaluation and Auto Parallelization

MXNet 使用**延迟计算**来优化执行速度。一般在 Python 中，执行一个计算任务，如`a = b + 1`，Python 线程会将任务扔给**后台引擎**，后台引擎执行完毕后，接受其计算结果。而这整个过程对前端客户是透明的。

MXNet可以显式调用 _**wait\_to\_read\(\)**_ 来等待所有计算任务完成

```
import time

def do(x, n):
    # 将任务推送给后端引擎
    return [mx.nd.dot(x,x) for i in range(n)]
def wait(x):
    # 阻塞，直到所以结果都可用
    for y in x:
        y.wait_to_read()

tic = time.time()
a = mx.nd.ones((1000,1000))
b = do(a, 50)
print('发送任务时间：\n %f sec' % (time.time() - tic))
wait(b)
print('所有计算任务结束时间:\n %f sec' % (time.time() - tic))
```