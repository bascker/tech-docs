# MXNet单节点部署

MXNet 可以运行在 Amazon Linux、Ubuntu、Debian、OS X、Windows 上，甚至可以运行在 docker、嵌入式设备。

## 部署流程

### 环境说明

1.系统：CentOS7.2

2.主机：10.158.113.160

### 基础环境

```
# 要求 gcc, gcc-c++ 版本 > 4.8
$ yum install -y gcc gcc-c++ clang git
$ yum groupinstall -y "Development Tools"

# 安装 python2.7 版本--> 有就不用安装
$ yum install -y python27 python27-setuptools python27-tools

# 安装 pip, numpy
$ yum install -y python-devel python-pip python-numpy

$ pip install graphviz
$ pip install jupyter
```

### 安装OpenBLAS

    $ git clone https://github.com/xianyi/OpenBLAS
    $ cd OpenBLAS/

    # 编译 OpenBLAS
    $ make -j $(($(nproc) + 1))
    ...
    rm -f linktest
    make[1]: Leaving directory `/root/OpenBLAS/exports'

     OpenBLAS build complete. (BLAS CBLAS)

      OS               ... Linux
      Architecture     ... x86_64
      BINARY           ... 64bit
      C compiler       ... GCC  (command line : gcc)
      Library Name     ... libopenblas_sandybridgep-r0.2.20.dev.a (Multi threaded; Max num-threads is 8)

    To install the library, you can run "make PREFIX=/path/to/your/installation install".

    # 安装 OpenBLAS 到 /usr/local/openblas
    $ make PREFIX=/usr/local install
    make -j 8 -f Makefile.install install
    make[1]: Entering directory `/root/OpenBLAS'
    Generating openblas_config.h in /usr/local/include
    Generating f77blas.h in /usr/local/include
    Generating cblas.h in /usr/local/include
    Copying the static library to /usr/local/lib
    Copying the shared library to /usr/local/lib
    Generating openblas.pc in /usr/local/lib/pkgconfig
    Generating OpenBLASConfig.cmake in /usr/local/lib/cmake/openblas
    Generating OpenBLASConfigVersion.cmake in /usr/local/lib/cmake/openblas
    Install OK!
    make[1]: Leaving directory `/root/OpenBLAS'

### 安装CUDA

安装CUDA是可选项，若主机不是GPU机器，或者想使用 CPU 进行训练，那么可以跳过这部分，并安装 OpenCV。

```
# 判断主机是否支持 CUDA：若输出的GPU型号是NVIDIA的,并且在 http://developer.nvidia.com/cuda­gpus 列表内,则支持
$ yum install -y pciutils
$ lspci | grep -i nvidia
```

若想使用GPU，就需要安装 CUDA 和 CUDNN

1.下载 **CUDA 8 toolkit**：[https://developer.nvidia.com/cuda-toolkit](https://developer.nvidia.com/cuda-toolkit)

2.下载** cudnn 5**：[https://developer.nvidia.com/cudnn](https://developer.nvidia.com/cudnn)

3.解压文件并改变 cudnn 根目录

```
$ tar xvzf cudnn-8.0-linux-x64-v5.1-ga.tgz
$ cp -P cuda/include/cudnn.h /usr/local/cuda/include
$ cp -P cuda/lib64/libcudnn* /usr/local/cuda/lib64
$ chmod a+r /usr/local/cuda/include/cudnn.h /usr/local/cuda/lib64/libcudnn*
$ ldconfig
```

### 安装 opencv

> 虽然是可选项，但**强烈推荐**安装

```
# 安装依赖
$ yum install -y cmake gtk2-devel gtk3-devel gimp-devel gimp-devel-tools gimp-help-browser zlib-devel libtiff-devel libjpeg-devel \
                 libpng-devel gstreamer-devel libavc1394-devel libraw1394-devel libdc1394-devel jasper-devel \
                 jasper-utils swig python libtool nasm

# 下载源码
$ git clone https://github.com/opencv/opencv
$ cd opencv
$ mkdir -p build
$ cd build
$ pwd
/root/opencv/build

# ippicv 是个并行计算库
# 预先下载 ippicv_linux_20151201.tgz，并将其放到 opencv 源码目录下：编译 opencv 时需要下载它，若不预先下载，很可能编译失败
$ cp ~/ippicv_linux_20151201.tgz ~/opencv/3rdparty/ippicv/downloads/linux-808b791a6eac9ed78d32a7666804320e/

# 编译
$ cmake -D BUILD_opencv_gpu=OFF -D WITH_EIGEN=ON -D WITH_TBB=ON -D WITH_CUDA=OFF -D WITH_1394=OFF -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local ..
-- Detected version of GNU GCC: 48 (408)
-- Could NOT find PythonInterp: Found unsuitable version "2.7.5", but required is at least "3.4" (found /usr/bin/python)
-- Could NOT find PythonInterp: Found unsuitable version "2.7.5", but required is at least "3.2" (found /usr/bin/python)
-- POPCNT is not supported by C++ compiler
-- FP16: Feature disabled
-- Found ZLIB: /lib64/libz.so (found suitable version "1.2.7", minimum required is "1.2.3")
...
--   Install path:                  /usr/local
--
--   cvconfig.h is in:              /root/opencv/build
-- -----------------------------------------------------------------
--
-- Configuring done
-- Generating done
-- Build files have been written to: /root/opencv/build

# 安装
$ make PREFIX=/usr/local install
make PREFIX=/usr/local install
Scanning dependencies of target libwebp
[  0%] Building C object 3rdparty/libwebp/CMakeFiles/libwebp.dir/dec/alpha_dec.c.o
[  0%] Building C object 3rdparty/libwebp/CMakeFiles/libwebp.dir/dec/buffer_dec.c.o
[  0%] Building C object 3rdparty/libwebp/CMakeFiles/libwebp.dir/dec/frame_dec.c.o
[  0%] Building C object 3rdparty/libwebp/CMakeFiles/libwebp.dir/dec/idec_dec.c.o
[  0%] Building C object 3rdparty/libwebp/CMakeFiles/libwebp.dir/dec/io_dec.c.o
[  1%] Building C object 3rdparty/libwebp/CMakeFiles/libwebp.dir/dec/quant_dec.c.o
[  1%] Building C object 3rdparty/libwebp/CMakeFiles/libwebp.dir/dec/tree_dec.c.o
[  1%] Building C object 3rdparty/libwebp/CMakeFiles/libwebp.dir/dec/vp8_dec.c.o
[  1%] Building C object 3rdparty/libwebp/CMakeFiles/libwebp.dir/dec/vp8l_dec.c.o
...
[ 99%] Built target opencv_visualisation
Scanning dependencies of target opencv_version
[100%] Building CXX object apps/version/CMakeFiles/opencv_version.dir/opencv_version.cpp.o
Linking CXX executable ../../bin/opencv_version
[100%] Built target opencv_version
Install the project...
...
-- Installing: /usr/local/bin/opencv_version
-- Set runtime path of "/usr/local/bin/opencv_version" to "/usr/local/lib"

# 会生成如下命令
$ ll /usr/local/bin/opencv*
-rwxr-xr-x 1 root root  34818 Mar 23 16:15 /usr/local/bin/opencv_annotation
-rwxr-xr-x 1 root root  41535 Mar 23 16:15 /usr/local/bin/opencv_createsamples
-rwxr-xr-x 1 root root 457822 Mar 23 16:15 /usr/local/bin/opencv_traincascade
-rwxr-xr-x 1 root root  13988 Mar 23 16:15 /usr/local/bin/opencv_version
-rwxr-xr-x 1 root root  69792 Mar 23 16:15 /usr/local/bin/opencv_visualisation

$ opencv_version
3.2.0-dev
```

### 安装 MXNet

```
# 获取源码
$ mkdir ~/mxnet
$ git clone https://github.com/dmlc/mxnet.git ~/mxnet --recursive
Cloning into '/root/mxnet'...
...
Resolving deltas: 100% (22335/22335), done.
Submodule 'cub' (https://github.com/NVlabs/cub) registered for path 'cub'
Submodule 'dmlc-core' (https://github.com/dmlc/dmlc-core.git) registered for path 'dmlc-core'
Submodule 'mshadow' (https://github.com/dmlc/mshadow.git) registered for path 'mshadow'
Submodule 'nnvm' (https://github.com/dmlc/nnvm) registered for path 'nnvm'
Submodule 'ps-lite' (https://github.com/dmlc/ps-lite) registered for path 'ps-lite'
Cloning into 'cub'...
...
Cloning into 'dmlc-core'...
...
Cloning into 'mshadow'...
...
Cloning into 'nnvm'...
...
Cloning into 'dmlc-core'...
...
Cloning into 'plugin/nnvm-fusion'...
...
Cloning into 'ps-lite'...
...

$ cd mxnet
$ cp make/config.mk .

# 注：若使用其他的 BLAS lib，将下面的配置自行替换
$ echo "USE_BLAS=openblas" >>config.mk
$ echo "ADD_CFLAGS += -I/usr/include/openblas" >>config.mk
$ echo "ADD_LDFLAGS += -lopencv_core -lopencv_imgproc -lopencv_imgcodecs" >>config.mk

# 注：若想进行 GPU 支持，则需要运行下列命令添加 GPU 的依赖配置到 config.mk
$ echo "USE_CUDA=1" >>config.mk
$ echo "USE_CUDA_PATH=/usr/local/cuda" >>config.mk
$ echo "USE_CUDNN=1" >>config.mk

# 编译
$ make -j$(nproc)
g++ -std=c++11 -c -DMSHADOW_FORCE_STREAM -Wall -Wsign-compare -O3 -I/root/mxnet/mshadow/ -I/root/mxnet/dmlc-core/include -fPIC -I/root/mxnet/nnvm/include -Iinclude -funroll-loops -Wno-unused-variable -Wno-unused-parameter -Wno-unknown-pragmas -Wno-unused-local-typedefs -msse3 -DMSHADOW_USE_CUDA=0 -DMSHADOW_USE_CBLAS=1 -DMSHADOW_USE_MKL=0 -DMSHADOW_RABIT_PS=0 -DMSHADOW_DIST_PS=0 -DMSHADOW_USE_PASCAL=0 -DMXNET_USE_OPENCV=1 -I/usr/local/include/opencv -I/usr/local/include   -fopenmp  -I/usr/include/openblas -DMXNET_USE_NVRTC=0 -MMD -c src/operator/tensor/elemwise_binary_broadcast_op_basic.cc -o build/src/operator/tensor/elemwise_binary_broadcast_op_basic.o
g++ -std=c++11 -c -DMSHADOW_FORCE_STREAM -Wall -Wsign-compare -O3 -I/root/mxnet/mshadow/ -I/root/mxnet/dmlc-core/include -fPIC -I/root/mxnet/nnvm/include -Iinclude -funroll-loops -Wno-unused-variable -Wno-unused-parameter -Wno-unknown-pragmas -Wno-unused-local-typedefs -msse3 -DMSHADOW_USE_CUDA=0 -DMSHADOW_USE_CBLAS=1 -DMSHADOW_USE_MKL=0 -DMSHADOW_RABIT_PS=0 -DMSHADOW_DIST_PS=0 -DMSHADOW_USE_PASCAL=0 -DMXNET_USE_OPENCV=1 -I/usr/local/include/opencv -I/usr/local/include   -fopenmp  -I/usr/include/openblas -DMXNET_USE_NVRTC=0 -MMD -c src/operator/tensor/elemwise_binary_broadcast_op_extended.cc -o build/src/operator/tensor/elemwise_binary_broadcast_op_extended.o
g++ -std=c++11 -c -DMSHADOW_FORCE_STREAM -Wall -Wsign-compare -O3 -I/root/mxnet/mshadow/ -I/root/mxnet/dmlc-core/include -fPIC -I/root/mxnet/nnvm/include -Iinclude -funroll-loops -Wno-unused-variable -Wno-unused-parameter -Wno-unknown-pragmas -Wno-unused-local-typedefs -msse3 -DMSHADOW_USE_CUDA=0 -DMSHADOW_USE_CBLAS=1 -DMSHADOW_USE_MKL=0 -DMSHADOW_RABIT_PS=0 -DMSHADOW_DIST_PS=0 -DMSHADOW_USE_PASCAL=0 -DMXNET_USE_OPENCV=1 -I/usr/local/include/opencv -I/usr/local/include   -fopenmp  -I/usr/include/openblas -DMXNET_USE_NVRTC=0 -MMD -c src/operator/tensor/broadcast_reduce_op_value.cc -o build/src/operator/tensor/broadcast_reduce_op_value.o
...
a - build/src/executor/graph_executor.o
a - build/src/executor/attach_op_execs_pass.o
a - build/src/executor/attach_op_resource_pass.o
a - build/src/kvstore/kvstore.o
a - build/src/resource.o
a - build/src/initialize.o

# 成功后在 mxnet/lib 下生成 libmxnet.so 库
$ pwd
/root/mxnet/lib
$ ll
total 86112
-rw-r--r-- 1 root root 54580986 Mar 23 16:56 libmxnet.a
-rwxr-xr-x 1 root root 21135239 Mar 23 16:56 libmxnet.so
```

### 安装 MXNet 对 Python 的支持

```
$ pwd
/root/mxnet/python
$ python setup.py install
running install
running bdist_egg
running egg_info
creating mxnet.egg-info
writing requirements to mxnet.egg-info/requires.txt
writing mxnet.egg-info/PKG-INFO
...
Installed /usr/lib/python2.7/site-packages/mxnet-0.9.4-py2.7.egg
Processing dependencies for mxnet==0.9.4
Searching for numpy==1.7.1
Best match: numpy 1.7.1
Adding numpy 1.7.1 to easy-install.pth file

Using /usr/lib64/python2.7/site-packages
Finished processing dependencies for mxnet==0.9.4

$ pip show mxnet
---
Metadata-Version: 1.0
Name: mxnet
Version: 0.9.4
Summary: MXNet Python Package
Home-page: None
Author: None
Author-email: None
License: None
Location: /usr/lib/python2.7/site-packages/mxnet-0.9.4-py2.7.egg
Requires: numpy
Classifiers:
```

### 测试

```
>>> import mxnet as mx
>>> a = mx.nd.array([1, 2, 3])
>>> print a.asnumpy()
[ 1.  2.  3.]
```

## 附录：部署FAQ

### 1.编译 opencv 时，下载 ippicv 失败

**场景**：编译 opencv 时，在下载 ippicv 时失败

**解决**：预先下载`ippicv_linux_20151201.tgz`，并将其放到`opencv`源码目录下 `~/opencv/3rdparty/ippicv/downloads/linux*`下

### 2.编译 MXNet 报错

**场景**：编译 mxnet 报错

    Package opencv was not found in the pkg-config search path.
    Perhaps you should add the directory containing `opencv.pc'
    to the PKG_CONFIG_PATH environment variable
    No package 'opencv' found

解决：设置 `PKG_CONFIG_PATH`环境变量

```
$ PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
$ export PKG_CONFIG_PATH
```

## 参考文献

1.官网：[http://mxnet.io/get\_started/centos\_setup.html](http://mxnet.io/get_started/centos_setup.html)

2.MXnet实战深度学习：[http://www.open-open.com/lib/view/open1448030000650.html](http://www.open-open.com/lib/view/open1448030000650.html)

3.MXNet安装教程：[http://blog.csdn.net/u012759136/article/details/50196685](http://blog.csdn.net/u012759136/article/details/50196685)

5.ubuntu安装CUDA：[http://blog.csdn.net/a350203223/article/details/50262535](http://blog.csdn.net/a350203223/article/details/50262535)