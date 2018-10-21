# Docker部署
## 简介
MXNet 支持使用 docker 来进行环境部署，提供了 2 个 docker 镜像来运行 mxnet：
* MXNet Docker \(CPU\)：[https://hub.docker.com/r/kaixhin/mxnet/](https://hub.docker.com/r/kaixhin/mxnet/)
* MXNet Docker \(GPU\)：[https://hub.docker.com/r/kaixhin/cuda-mxnet/](https://hub.docker.com/r/kaixhin/cuda-mxnet/)

若想获得 CUDA 支持，就需要 NVIDIA Docker
* NVIDIA-Docker：[https://github.com/NVIDIA/nvidia-docker](https://github.com/NVIDIA/nvidia-docker)

## 部署
1.安装 docker
```
$ yum install -y docker-engine
$ systemctl enable docker
$ systemctl start docker
$ systemctl status docker
```

2.获取镜像
```
# CPU MXNET 镜像：使用的是 Ubuntu 14.04+ 的内核
$ docker pull kaixhin/mxnet

# GPU MXNEt 镜像
$ docker pull kaixhin/cuda-mxnet
```

3.运行
```
$ docker run -it kaixhin/mxnet
root@d00dc4e675e6:~/mxnet#
root@d00dc4e675e6:~/mxnet# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
27: eth0@if28: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.2/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe11:2/64 scope link
       valid_lft forever preferred_lft forever
root@d00dc4e675e6:~/mxnet#
root@d00dc4e675e6:~/mxnet# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.3  0.0  18160  1980 ?        Ss   05:25   0:00 /bin/bash
root        22  0.0  0.0  15560  1140 ?        R+   05:25   0:00 ps aux
root@d00dc4e675e6:~/mxnet#

# 后台运行
$ docker run -itd --name mxnet kaixhin/mxnet
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS      NAMES
763bc594f99f        kaixhin/mxnet       "/bin/bash"         4 seconds ago       Up 2 seconds                   mxnet
```

4.测试：若下面测试案例没有问题，就表明 MXNet 已经 ok

```
$ docker exec -it mxnet bash

# 解决 import mxnet 报错：libdc1394 error: Failed to initialize libdc1394
$ ln -s /dev/null /dev/raw1394

# 使用 mxnet 库
$ python
>>> import mxnet as mx
>>> a = mx.nd.ones((2,3), mx.cpu())      # 若是 MXNet-GPU 可以使用 mx.gpu()
>>> a
<NDArray 2x3 @cpu(0)>
>>> b = (a * 2).asnumpy()
>>> b
array([[ 2.,  2.,  2.],
       [ 2.,  2.,  2.]], dtype=float32)
>>> print (b)
[[ 2.  2.  2.]
 [ 2.  2.  2.]]
```

> 注：若导入 mxnet 包时报错 `libdc1394 error: Failed to initialize libdc1394`, 可以执行 `ln -s /dev/null /dev/raw1394` 来解决

5.运行官方案例：`~/mxnet/example/image-classification/train_mnist.py`

```
# train_mnist.py 需要 requests 模块，但容器内默认是没有安装的
$ pip install requests

# 建议配置 --model-prefix 保存后训练后的数据。默认不会保存
$ mkdir model                # 创建用于保存训练后模型数据的文件夹
$ python train_mnist.py --model-prefix model/mnist
INFO:root:start with arguments Namespace(batch_size=64, disp_batches=100, gpus=None, kv_store='device', load_epoch=None, lr=0.05, lr_factor=0.1, lr_step_epochs='10', model_prefix='model/mnist', mom=0.9, monitor=0, network='mlp', num_classes=10, num_epochs=20, num_examples=60000, num_layers=None, optimizer='sgd', test_io=0, top_k=0, wd=0.0001)
DEBUG:requests.packages.urllib3.connectionpool:Starting new HTTP connection (1): 10.158.113.150
DEBUG:requests.packages.urllib3.connectionpool:http://10.158.113.150:80 "GET /datas/train-labels-idx1-ubyte.gz HTTP/1.1" 200 28881
DEBUG:requests.packages.urllib3.connectionpool:Starting new HTTP connection (1): 10.158.113.150
DEBUG:requests.packages.urllib3.connectionpool:http://10.158.113.150:80 "GET /datas/train-images-idx3-ubyte.gz HTTP/1.1" 200 9912422
DEBUG:requests.packages.urllib3.connectionpool:Starting new HTTP connection (1): 10.158.113.150
DEBUG:requests.packages.urllib3.connectionpool:http://10.158.113.150:80 "GET /datas/t10k-labels-idx1-ubyte.gz HTTP/1.1" 200 4542
DEBUG:requests.packages.urllib3.connectionpool:Starting new HTTP connection (1): 10.158.113.150
DEBUG:requests.packages.urllib3.connectionpool:http://10.158.113.150:80 "GET /datas/t10k-images-idx3-ubyte.gz HTTP/1.1" 200 1648877
...
INFO:root:Epoch[0] Batch [900]    Speed: 396.92 samples/sec    Train-accuracy=0.955469
INFO:root:Epoch[0] Train-accuracy=0.957348
INFO:root:Epoch[0] Time cost=141.853
INFO:root:Saved checkpoint to "model/mnist-0001.params"
INFO:root:Epoch[0] Validation-accuracy=0.946457
...
INFO:root:Epoch[1] Batch [900]    Speed: 425.07 samples/sec    Train-accuracy=0.971719
INFO:root:Epoch[1] Train-accuracy=0.976351
INFO:root:Epoch[1] Time cost=145.648
INFO:root:Saved checkpoint to "model/mnist-0002.params"
INFO:root:Epoch[1] Validation-accuracy=0.969049
...
INFO:root:Epoch[2] Batch [900]    Speed: 462.13 samples/sec    Train-accuracy=0.975625
INFO:root:Epoch[2] Train-accuracy=0.982686
INFO:root:Epoch[2] Time cost=138.094
INFO:root:Saved checkpoint to "model/mnist-0003.params"
INFO:root:Epoch[2] Validation-accuracy=0.973826
...
INFO:root:Epoch[3] Batch [900]    Speed: 362.45 samples/sec    Train-accuracy=0.981563
INFO:root:Epoch[3] Train-accuracy=0.984375
INFO:root:Epoch[3] Time cost=152.184
INFO:root:Saved checkpoint to "model/mnist-0004.params"
INFO:root:Epoch[3] Validation-accuracy=0.975418
INFO:root:Epoch[3] Train-accuracy=0.984375
...
INFO:root:Epoch[4] Batch [900]    Speed: 374.75 samples/sec    Train-accuracy=0.984688
INFO:root:Epoch[4] Train-accuracy=0.987753
INFO:root:Epoch[4] Time cost=156.726
INFO:root:Saved checkpoint to "model/mnist-0005.params"
INFO:root:Epoch[4] Validation-accuracy=0.974224
...
INFO:root:Epoch[19] Batch [900]    Speed: 408.26 samples/sec    Train-accuracy=0.999844
INFO:root:Epoch[19] Train-accuracy=1.000000
INFO:root:Epoch[19] Time cost=144.617
INFO:root:Saved checkpoint to "model/mnist-0020.params"
INFO:root:Epoch[19] Validation-accuracy=0.982484

# 查看训练结果
$ cd model
$ ll
total 8572
drwxr-xr-x 2 root root   4096 Mar 31 07:18 ./
drwxr-xr-x 7 root root   4096 Mar 31 06:22 ../
-rw-r--r-- 1 root root 437834 Mar 31 06:28 mnist-0001.params
-rw-r--r-- 1 root root 437834 Mar 31 06:31 mnist-0002.params
-rw-r--r-- 1 root root 437834 Mar 31 06:33 mnist-0003.params
-rw-r--r-- 1 root root 437834 Mar 31 06:36 mnist-0004.params
-rw-r--r-- 1 root root 437834 Mar 31 06:39 mnist-0005.params
-rw-r--r-- 1 root root 437834 Mar 31 06:42 mnist-0006.params
-rw-r--r-- 1 root root 437834 Mar 31 06:45 mnist-0007.params
-rw-r--r-- 1 root root 437834 Mar 31 06:47 mnist-0008.params
-rw-r--r-- 1 root root 437834 Mar 31 06:50 mnist-0009.params
-rw-r--r-- 1 root root 437834 Mar 31 06:52 mnist-0010.params
-rw-r--r-- 1 root root 437834 Mar 31 06:55 mnist-0011.params
-rw-r--r-- 1 root root 437834 Mar 31 06:57 mnist-0012.params
-rw-r--r-- 1 root root 437834 Mar 31 07:00 mnist-0013.params
-rw-r--r-- 1 root root 437834 Mar 31 07:02 mnist-0014.params
-rw-r--r-- 1 root root 437834 Mar 31 07:05 mnist-0015.params
-rw-r--r-- 1 root root 437834 Mar 31 07:08 mnist-0016.params
-rw-r--r-- 1 root root 437834 Mar 31 07:10 mnist-0017.params
-rw-r--r-- 1 root root 437834 Mar 31 07:13 mnist-0018.params
-rw-r--r-- 1 root root 437834 Mar 31 07:15 mnist-0019.params
-rw-r--r-- 1 root root 437834 Mar 31 07:18 mnist-0020.params
-rw-r--r-- 1 root root   2100 Mar 31 07:18 mnist-symbol.json

$ cat mnist-symbol.json
{
  "nodes": [
    {
      "op": "null",
      "name": "data",
      "inputs": []
    },
    {
      "op": "Flatten",
      "name": "flatten0",
      "inputs": [[0, 0, 0]]
    },
    {
      "op": "null",
      "name": "fc1_weight",
      "attr": {"num_hidden": "128"},
      "inputs": []
    },
    {
      "op": "null",
      "name": "fc1_bias",
      "attr": {"num_hidden": "128"},
      "inputs": []
    },
    {
      "op": "FullyConnected",
      "name": "fc1",
      "attr": {"num_hidden": "128"},
      "inputs": [[1, 0, 0], [2, 0, 0], [3, 0, 0]]
    },
    {
      "op": "Activation",
      "name": "relu1",
      "attr": {"act_type": "relu"},
      "inputs": [[4, 0, 0]]
    },
    {
      "op": "null",
      "name": "fc2_weight",
      "attr": {"num_hidden": "64"},
      "inputs": []
    },
    {
      "op": "null",
      "name": "fc2_bias",
      "attr": {"num_hidden": "64"},
      "inputs": []
    },
    {
      "op": "FullyConnected",
      "name": "fc2",
      "attr": {"num_hidden": "64"},
      "inputs": [[5, 0, 0], [6, 0, 0], [7, 0, 0]]
    },
    {
      "op": "Activation",
      "name": "relu2",
      "attr": {"act_type": "relu"},
      "inputs": [[8, 0, 0]]
    },
    {
      "op": "null",
      "name": "fc3_weight",
      "attr": {"num_hidden": "10"},
      "inputs": []
    },
    {
      "op": "null",
      "name": "fc3_bias",
      "attr": {"num_hidden": "10"},
      "inputs": []
    },
    {
      "op": "FullyConnected",
      "name": "fc3",
      "attr": {"num_hidden": "10"},
      "inputs": [[9, 0, 0], [10, 0, 0], [11, 0, 0]]
    },
    {
      "op": "null",
      "name": "softmax_label",
      "inputs": []
    },
    {
      "op": "SoftmaxOutput",
      "name": "softmax",
      "inputs": [[12, 0, 0], [13, 0, 0]]
    }
  ],
  "arg_nodes": [0, 2, 3, 6, 7, 10, 11, 13],
  "node_row_ptr": [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15
  ],
  "heads": [[14, 0, 0]],
  "attrs": {"mxnet_version": ["int", 905]}
}
```

---

> 注：建议先将 yann.lecun.com 上的 4 个训练数据下载到本地，然后开启本地 httpd 服务，接着修改 train\_minist.py 源码指向本地服务器，以此加快速度

---

## 附录

### MXNet-CPU Dockerfile

```
#Start with Ubuntu base image
FROM ubuntu:14.04
MAINTAINER Kai Arulkumaran <design@kaixhin.com>

# Install build-essential, git, wget and other dependencies
RUN apt-get update && apt-get install -y \
        build-essential \
        git \
        libopenblas-dev \
        libopencv-dev \
        python-dev \
        python-numpy \
        python-setuptools \
        wget

# Clone MXNet repo and move into it
RUN cd /root && git clone --recursive https://github.com/dmlc/mxnet && cd mxnet && \
    # Copy config.mk
    cp make/config.mk config.mk && \
    # Set OpenBLAS
    sed -i 's/USE_BLAS = atlas/USE_BLAS = openblas/g' config.mk && \
    # Set USE_DIST_KVSTORE
    sed -i 's/USE_DIST_KVSTORE = 0/USE_DIST_KVSTORE = 1/g' config.mk && \
    # Make
    make -j"$(nproc)"

# Install Python package
RUN cd /root/mxnet/python && python setup.py install

# Add to Python path
RUN echo "export PYTHONPATH=$MXNET_HOME/python:$PYTHONPATH" >> /root/.bashrc

# Install pip
RUN easy_install -U pip

# Install graphviz and jupyter
RUN pip install graphviz jupyter

# Set ~/mxnet as working directory
WORKDIR /root/mxnet
```

### NVIDIA Docker

1.要求

| **软件** | **版本** |
| :--- | :--- |
| GNU/Linux x86\_64 | 内核版本 &gt; 3.10 |
| Docker | 1.9+ |
| NVIDIA GPU | 架构 &gt; Fermi\(2.1\) |
| NVIDIA drivers | &gt;= 340.29 |

```
$ yum install -y docker-engine
$
```

1.安装 nvidia -docker 和 nvidia-docker-plugin

```
$ wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker-1.0.1-1.x86_64.rpm
$ rpm -ivh /tmp/nvidia-docker*.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:nvidia-docker-1.0.1-1            ################################# [100%]
Configuring user
Setting up permissions
```

2.启动 nvidia-docker 服务

```
$ systemctl start nvidia-docker
```

## 参考文献
1.NVIDia-Docker：[http://blog.sina.com.cn/s/blog\_6de3aa8a0102w6eb.html](http://blog.sina.com.cn/s/blog_6de3aa8a0102w6eb.html)