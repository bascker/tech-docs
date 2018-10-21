# MXNet多节点部署

## 环境说明

1.系统：CentOS7

2.主机

* 10.158.113.160
* 10.158.113.161

## 部署流程
MXNet想部署多节点环境，开启分布式训练，其他的步骤和单节点一致，唯一的区别就是，在**编译安装 mxnet 时**，需要**配置 **_**config.mk **_**的选项**，配置`USE_DIST_KVSTORE = 1`，开启分布式功能。

```
#----------------------------
# distributed computing
#----------------------------

# whether or not to enable multi-machine supporting
#USE_DIST_KVSTORE = 0
USE_DIST_KVSTORE = 1                    # 开启分布式支持

# whether or not allow to read and write HDFS directly. If yes, then hadoop is
# required
#USE_HDFS = 0
USE_HDFS = 1                            # 开启 HDFS 文件系统支持，需要 Hadoop 支持

# path to libjvm.so. required if USE_HDFS=1
LIBJVM=$(JAVA_HOME)/jre/lib/amd64/server

# whether or not allow to read and write AWS S3 directly. If yes, then
# libcurl4-openssl-dev is required, it can be installed on Ubuntu by
# sudo apt-get install -y libcurl4-openssl-dev
USE_S3 = 0                              # 若想支持 AWS_S3，则设置为 1
```

若之前没开启该选项，则执行以下步骤，重新开启分布式训练支持：

1.卸载 mxnet

```
$ pip uninstall mxnet
Uninstalling mxnet-0.9.4:
  /usr/lib/python2.7/site-packages/mxnet-0.9.4-py2.7.egg
Proceed (y/n)? y
  Successfully uninstalled mxnet-0.9.4
```

2.修改 config.mk，开启分布式支持

3.重新编译 mxnet

    $ make -j$(nproc)
    make CXX=g++ DEPS_PATH=/root/mxnet/deps -C /root/mxnet/ps-lite ps
    cd /root/mxnet/dmlc-core; make libdmlc.a USE_SSE=1 config=/root/mxnet/config.mk; cd /root/mxnet
    ...
    --2017-03-24 17:02:28--  https://raw.githubusercontent.com/mli/deps/master/build/zeromq-4.1.4.tar.gz
    make[1]: Entering directory `/root/mxnet/nnvm'
    make[1]: `lib/libnnvm.a' is up to date.
    make[1]: Leaving directory `/root/mxnet/nnvm'
    --2017-03-24 17:02:28--  https://raw.githubusercontent.com/mli/deps/master/build/protobuf-2.5.0.tar.gz
    Resolving raw.githubusercontent.com (raw.githubusercontent.com)... Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 151.101.100.133
    Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|151.101.100.133|:443... 151.101.100.133
    Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|151.101.100.133|:443... connected.
    ...
    libtool: finish: PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/sbin" ldconfig -n /root/mxnet/deps/lib
    ----------------------------------------------------------------------
    Libraries have been installed in:
       /root/mxnet/deps/lib

    If you ever happen to want to link against installed libraries
    in a given directory, LIBDIR, you must either use libtool, and
    specify the full pathname of the library, or use the `-LLIBDIR'
    flag during linking and do at least one of the following:
       - add LIBDIR to the `LD_LIBRARY_PATH' environment variable
         during execution
       - add LIBDIR to the `LD_RUN_PATH' environment variable
         during linking
       - use the `-Wl,-rpath -Wl,LIBDIR' linker flag
       - have your system administrator add LIBDIR to `/etc/ld.so.conf'

    See any operating system documentation about shared libraries for
    more information, such as the ld(1) and ld.so(8) manual pages.
    ----------------------------------------------------------------------
     /usr/bin/mkdir -p '/root/mxnet/deps/bin'
      /bin/sh ./libtool   --mode=install /usr/bin/install -c curve_keygen '/root/mxnet/deps/bin'
    libtool: install: /usr/bin/install -c .libs/curve_keygen /root/mxnet/deps/bin/curve_keygen
    make[4]: Leaving directory `/root/mxnet/ps-lite/zeromq-4.1.4'
    make[3]: Leaving directory `/root/mxnet/ps-lite/zeromq-4.1.4'
    make[2]: Leaving directory `/root/mxnet/ps-lite/zeromq-4.1.4'
    rm -rf zeromq-4.1.4.tar.gz zeromq-4.1.4
    98% [=================================
    ...
    a - build/customer.o
    a - build/postoffice.o
    a - build/van.o
    a - build/meta.pb.o
    rm src/meta.pb.h
    make[1]: Leaving directory `/root/mxnet/ps-lite'
    ar crv lib/libmxnet.a
    g++ -DMSHADOW_FORCE_STREAM -Wall ...

4.检查编译是否 ok：查看 mxnet/lib/ 目录下的 libmxnet.so 文件生成时间是否变动

```
# 由昨天的 16:56 变为今天的 17:06
$ ll
total 73944
-rw-r--r-- 1 root root 54580986 Mar 23 16:56 libmxnet.a
-rwxr-xr-x 1 root root 21135239 Mar 24 17:06 libmxnet.so
```

5.重新安装 mxnet

```
$ cd mxnet/python
$ python setup.py install
running install
running bdist_egg
running egg_info
...
Using /usr/lib64/python2.7/site-packages
Finished processing dependencies for mxnet==0.9.4

$ pip show mxnet
```