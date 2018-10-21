# MXNet

## 简介

1.mxnet 是五大主流深度学习框架之一, 是其中唯一支持**所有**`R`函数的架构。允许在多台物理设备\(包括移动设备\)上去定义、训练、开发深度神经网络。mxnet 是构建在动态的、可依赖的调度上，能并行\(快速\)处理符号和命令操作。其顶层优化后的图层使得符号操作更加快速，内存利用更高效。

2.由深度学习**社区开发**的开源的分布式深度学习框架，是多所大学与公司联合开发的，不属于某一家产品。主要开发者与赞助商：

* Amazon
* Baidu
* Microsoft
* ...

3.特性/优点

* _**Flexible**_：灵活，同时支持命令式编程、符号式编程
* _**Portable**_：轻量级，可以运行在`CPU/GPU/Clusters/Servers/Desktop/Mobile Phone`
* _**Multiple Language**_：多语言支持，如 `Java, Python, C++, JS, R`
* _**Auto-Differentiation**_：自动演进，可根据训练模型，自动计算演进
* _**Distributed On Cloud**_：**可扩展、分布式**，支持在云平台\(AWS,Azure,YarnGCE\)上的CPU/GPU主机上进行**分布式训练**
  > MXNet 的分布式训练特性是由 parameter server 提供支持的
* _**Performance**_：高效，其`C++`后端引擎可以实现**并行IO与计算**

4.缺点

* API文档差，太少，不够全面

5.与其他深度学习框架的对比

| **框架** | **主语言** | **从语言** | **硬件支持** | **分布式支持** | **命令式编程** | **符号式编程** |
| :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| _**Caffe**_ | C++ | Python/Matalab | CPU/GPU | X | X | V |
| _**Torch**_ | Lua | - | CPU/GPU/FPGA | X | V | X |
| _**Theano**_ | Python | - | CPU/GPU | X | X | V |
| _**Tensorflow**_ | C++ | Python | CPU/GPU/Mobile | V | X | V |
| _**MXNet**_ | C++ | Pthon/R/Go | CPU/GPU/Mobile | V | V | V |

## 参考文献

1.官网：[http://mxnet.io/index.html](http://mxnet.io/index.html)

2.五大主流深度学习框架对比：[http://synchuman.baijia.baidu.com/article/579597](http://synchuman.baijia.baidu.com/article/579597)

3.MXNet设计笔记之深度学习的编程模式比较：[http://www.csdn.net/article/2015-10-11/2825883](http://www.csdn.net/article/2015-10-11/2825883)

4.MXNet设计和实现简介：[http://blog.csdn.net/isuker/article/details/52450749](http://blog.csdn.net/isuker/article/details/52450749)

5.CUDA官网：[http://www.nvidia.cn/object/cuda-toolkit-cn.html](http://www.nvidia.cn/object/cuda-about-cn.html)

6.CUDA博文：[http://bbs.csdn.net/topics/390798229](http://bbs.csdn.net/topics/390798229)

7.官网-深度学习程序模型：[http://mxnet.io/architecture/program\_model.html](http://mxnet.io/architecture/program_model.html)