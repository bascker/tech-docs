# 分布式案例

## 简介

MXNet 是训练，训练的结果是 model

## 需求

1.重新编译 MXNet 镜像，开启 KVStore 支持

2.运行 3 个MXNet 容器，形成分布式

3.使用 SSH 方式运行 job

4.下载数据集，成功运行 MXNet 官方案例：`~/mxnet/example/image-classfication/train_mnist.py`

> 数据集：[http://yann.lecun.com/exdb/mnist/](http://yann.lecun.com/exdb/mnist/)

5.预测训练结果

## 实例

### 训练

1.重新编译 mxnet 镜像，开启 KVStore 支持

2.基于新镜像，创建 3 个容器

```
# mxnet[1, 3]
$ docker run -itd --name mxnet1 -h mxnet1 --privileged --restart always  mxnet/kvstore
...
$ docker ps
CONTAINER ID        IMAGE               COMMAND    CREATED              STATUS              PORTS   NAMES
0faa055a8efa        greedywolf/mxnet    "bash"     About a minute ago   Up About a minute           mxnet3
94d31dc13b58        greedywolf/mxnet    "bash"     About a minute ago   Up About a minute           mxnet2
580c819cf456        greedywolf/mxnet    "bash"     About a minute ago   Up About a minute           mxnet1

# 各容器 ip
mxnet1    172.17.0.2
mxnet2    172.17.0.3
mxnet3    172.17.0.6

# 修改问题
$ ln -s /dev/null /dev/raw1394
$ pip install requests
```

3.配置SSH

```
$ vi /etc/ssh/sshd_config
PermitRootLogin yes

$ echo "root:123456" | chpasswd

$ mkdir /var/run/sshd
$ nohup /usr/sbin/sshd -D &
$ ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  18168  1888 ?        Ss+  06:12   0:00 /bin/bash
root        21  0.0  0.0  18176  2004 ?        Ss   06:13   0:00 bash
root       707  0.0  0.0  61388  3052 ?        S    06:28   0:00 /usr/sbin/sshd -D
root       708  0.0  0.0  15572  1120 ?        R+   06:28   0:00 ps aux

# 测试
$ ssh 172.17.0.3
The authenticity of host '172.17.0.3 (172.17.0.3)' can't be established.
ECDSA key fingerprint is b6:3a:9f:65:41:a9:c6:6b:aa:01:c6:3d:5d:72:f7:bc.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '172.17.0.3' (ECDSA) to the list of known hosts.
root@172.17.0.3's password:
Welcome to Ubuntu 14.04 LTS (GNU/Linux 3.13.0-91-generic x86_64)

 * Documentation:  https://help.ubuntu.com/

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.
root@mxnet2:~#
```

4.配置SSH无密钥登录

```
# 配置 mxnet1 无密码登录其他容器
$ ssh-keygen
ssh-copy-id -i ~/.ssh/id_rsa.pub 172.17.0.2
$ ssh-copy-id -i ~/.ssh/id_rsa.pub 172.17.0.3
ssh-copy-id -i ~/.ssh/id_rsa.pub 172.17.0.6
```

5.分布式训练

```
$ pwd
/root/mxnet/example/image-classification

$ vi hosts
172.17.0.2
172.17.0.3
172.17.0.6

# 每个容器内都创建一个目录
$ mkdir model

# 使用 mxnet 提供的工具来运行 job
$ ../../tools/launch.py -n 3 --launcher ssh -H hosts python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
../../tools/launch.py -n 3 --launcher ssh -H hosts python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
INFO:root:start with arguments Namespace(batch_size=64, disp_batches=100, gpus=None, kv_store='dist_sync', load_epoch=None, lr=0.05, lr_factor=0.1, lr_step_epochs='10', model_prefix='model/mnist', mom=0.9, monitor=0, network='lenet', num_classes=10, num_epochs=20, num_examples=60000, num_layers=None, optimizer='sgd', test_io=0, top_k=0, wd=0.0001)
INFO:root:start with arguments Namespace(batch_size=64, disp_batches=100, gpus=None, kv_store='dist_sync', load_epoch=None, lr=0.05, lr_factor=0.1, lr_step_epochs='10', model_prefix='model/mnist', mom=0.9, monitor=0, network='lenet', num_classes=10, num_epochs=20, num_examples=60000, num_layers=None, optimizer='sgd', test_io=0, top_k=0, wd=0.0001)
INFO:root:start with arguments Namespace(batch_size=64, disp_batches=100, gpus=None, kv_store='dist_sync', load_epoch=None, lr=0.05, lr_factor=0.1, lr_step_epochs='10', model_prefix='model/mnist', mom=0.9, monitor=0, network='lenet', num_classes=10, num_epochs=20, num_examples=60000, num_layers=None, optimizer='sgd', test_io=0, top_k=0, wd=0.0001)
...
INFO:root:Epoch[0] Batch [900]    Speed: 62.21 samples/sec    Train-accuracy=0.991875
INFO:root:Epoch[0] Train-accuracy=0.993666
INFO:root:Epoch[0] Time cost=978.951
INFO:root:Epoch[0] Train-accuracy=0.992399
INFO:root:Epoch[0] Time cost=978.986
INFO:root:Epoch[0] Train-accuracy=0.991132
INFO:root:Epoch[0] Time cost=979.060
INFO:root:Saved checkpoint to "model/mnist-2-0001.params"
INFO:root:Saved checkpoint to "model/mnist-0001.params"
INFO:root:Saved checkpoint to "model/mnist-1-0001.params"
INFO:root:Epoch[0] Validation-accuracy=0.988455
INFO:root:Epoch[0] Validation-accuracy=0.988455
INFO:root:Epoch[0] Validation-accuracy=0.988455
...
INFO:root:Epoch[1] Batch [400]    Speed: 62.32 samples/sec    Train-accuracy=0.996406
...
INFO:root:Epoch[10] Time cost=980.194
INFO:root:Saved checkpoint to "model/mnist-2-0011.params"
INFO:root:Saved checkpoint to "model/mnist-1-0011.params"
INFO:root:Saved checkpoint to "model/mnist-0011.params"
INFO:root:Epoch[10] Validation-accuracy=0.991143
INFO:root:Epoch[10] Validation-accuracy=0.991143
INFO:root:Epoch[10] Validation-accuracy=0.991143
...

# 程序运行完毕后，各容器 model 目录下都会存在训练结果
root@mxnet1:~/mxnet/example/image-classification/model# ll
total 33772
drwxr-xr-x 2 root root    4096 Mar 28 12:31 ./
drwxr-xr-x 7 root root    4096 Mar 28 06:48 ../
-rw-r--r-- 1 root root 1724796 Mar 28 07:04 mnist-2-0001.params
-rw-r--r-- 1 root root 1724796 Mar 28 07:21 mnist-2-0002.params
-rw-r--r-- 1 root root 1724796 Mar 28 07:39 mnist-2-0003.params
-rw-r--r-- 1 root root 1724796 Mar 28 07:56 mnist-2-0004.params
-rw-r--r-- 1 root root 1724796 Mar 28 08:13 mnist-2-0005.params
-rw-r--r-- 1 root root 1724796 Mar 28 08:30 mnist-2-0006.params
-rw-r--r-- 1 root root 1724796 Mar 28 08:48 mnist-2-0007.params
-rw-r--r-- 1 root root 1724796 Mar 28 09:05 mnist-2-0008.params
-rw-r--r-- 1 root root 1724796 Mar 28 09:22 mnist-2-0009.params
-rw-r--r-- 1 root root 1724796 Mar 28 09:39 mnist-2-0010.params
-rw-r--r-- 1 root root 1724796 Mar 28 09:56 mnist-2-0011.params
-rw-r--r-- 1 root root 1724796 Mar 28 10:14 mnist-2-0012.params
-rw-r--r-- 1 root root 1724796 Mar 28 10:31 mnist-2-0013.params
-rw-r--r-- 1 root root 1724796 Mar 28 10:48 mnist-2-0014.params
-rw-r--r-- 1 root root 1724796 Mar 28 11:05 mnist-2-0015.params
-rw-r--r-- 1 root root 1724796 Mar 28 11:22 mnist-2-0016.params
-rw-r--r-- 1 root root 1724796 Mar 28 11:40 mnist-2-0017.params
-rw-r--r-- 1 root root 1724796 Mar 28 11:57 mnist-2-0018.params
-rw-r--r-- 1 root root 1724796 Mar 28 12:14 mnist-2-0019.params
-rw-r--r-- 1 root root 1724796 Mar 28 12:31 mnist-2-0020.params
-rw-r--r-- 1 root root    3506 Mar 28 12:31 mnist-2-symbol.json

root@mxnet2:~/mxnet/example/image-classification/model# ll
total 33772
drwxr-xr-x 2 root root    4096 Mar 28 12:31 ./
drwxr-xr-x 7 root root    4096 Mar 28 06:43 ../
-rw-r--r-- 1 root root 1724796 Mar 28 07:04 mnist-1-0001.params
-rw-r--r-- 1 root root 1724796 Mar 28 07:21 mnist-1-0002.params
-rw-r--r-- 1 root root 1724796 Mar 28 07:39 mnist-1-0003.params
-rw-r--r-- 1 root root 1724796 Mar 28 07:56 mnist-1-0004.params
-rw-r--r-- 1 root root 1724796 Mar 28 08:13 mnist-1-0005.params
-rw-r--r-- 1 root root 1724796 Mar 28 08:30 mnist-1-0006.params
-rw-r--r-- 1 root root 1724796 Mar 28 08:48 mnist-1-0007.params
-rw-r--r-- 1 root root 1724796 Mar 28 09:05 mnist-1-0008.params
-rw-r--r-- 1 root root 1724796 Mar 28 09:22 mnist-1-0009.params
-rw-r--r-- 1 root root 1724796 Mar 28 09:39 mnist-1-0010.params
-rw-r--r-- 1 root root 1724796 Mar 28 09:56 mnist-1-0011.params
-rw-r--r-- 1 root root 1724796 Mar 28 10:14 mnist-1-0012.params
-rw-r--r-- 1 root root 1724796 Mar 28 10:31 mnist-1-0013.params
-rw-r--r-- 1 root root 1724796 Mar 28 10:48 mnist-1-0014.params
-rw-r--r-- 1 root root 1724796 Mar 28 11:05 mnist-1-0015.params
-rw-r--r-- 1 root root 1724796 Mar 28 11:22 mnist-1-0016.params
-rw-r--r-- 1 root root 1724796 Mar 28 11:40 mnist-1-0017.params
-rw-r--r-- 1 root root 1724796 Mar 28 11:57 mnist-1-0018.params
-rw-r--r-- 1 root root 1724796 Mar 28 12:14 mnist-1-0019.params
-rw-r--r-- 1 root root 1724796 Mar 28 12:31 mnist-1-0020.params
-rw-r--r-- 1 root root    3506 Mar 28 12:31 mnist-1-symbol.json

root@mxnet3:~/mxnet/example/image-classification/model# ll
total 33772
drwxr-xr-x 2 root root    4096 Mar 28 12:31 ./
drwxr-xr-x 7 root root    4096 Mar 28 06:44 ../
-rw-r--r-- 1 root root 1724796 Mar 28 07:04 mnist-0001.params
-rw-r--r-- 1 root root 1724796 Mar 28 07:21 mnist-0002.params
-rw-r--r-- 1 root root 1724796 Mar 28 07:39 mnist-0003.params
-rw-r--r-- 1 root root 1724796 Mar 28 07:56 mnist-0004.params
-rw-r--r-- 1 root root 1724796 Mar 28 08:13 mnist-0005.params
-rw-r--r-- 1 root root 1724796 Mar 28 08:30 mnist-0006.params
-rw-r--r-- 1 root root 1724796 Mar 28 08:48 mnist-0007.params
-rw-r--r-- 1 root root 1724796 Mar 28 09:05 mnist-0008.params
-rw-r--r-- 1 root root 1724796 Mar 28 09:22 mnist-0009.params
-rw-r--r-- 1 root root 1724796 Mar 28 09:39 mnist-0010.params
-rw-r--r-- 1 root root 1724796 Mar 28 09:56 mnist-0011.params
-rw-r--r-- 1 root root 1724796 Mar 28 10:14 mnist-0012.params
-rw-r--r-- 1 root root 1724796 Mar 28 10:31 mnist-0013.params
-rw-r--r-- 1 root root 1724796 Mar 28 10:48 mnist-0014.params
-rw-r--r-- 1 root root 1724796 Mar 28 11:05 mnist-0015.params
-rw-r--r-- 1 root root 1724796 Mar 28 11:22 mnist-0016.params
-rw-r--r-- 1 root root 1724796 Mar 28 11:40 mnist-0017.params
-rw-r--r-- 1 root root 1724796 Mar 28 11:57 mnist-0018.params
-rw-r--r-- 1 root root 1724796 Mar 28 12:14 mnist-0019.params
-rw-r--r-- 1 root root 1724796 Mar 28 12:31 mnist-0020.params
-rw-r--r-- 1 root root    3506 Mar 28 12:31 mnist-symbol.json
```

_**tools/launch.py **_参数解释：

* **-n**：`NUM_WORKERS`, 指定启动多少个工作节点，此处指定 3 个 worker
* **--launcher**：指定使用 ssh 来提供 laucher
  * local
  * ssh
  * mpi
  * sge
  * yarn
* **-H**：指定 hosts，传入集群主机 ip
  > 注：指定 -H 后就需要使用 ssh，否则报错：_RuntimeError: Unknown submission cluster type ssh_

_**train\_mnist.py**_ 参数解释：

* **--network**：指定使用哪种神经网络
  * mlp：默认值，多层感知机 MLP
  * lenet
* **--kv-store**：KVStore 类型
  * local
  * device
  * dist\_sync
  * dist\_device\_sync
  * dist\_async
* **--model-prefix**：指定 model 文件前缀。默认不保存训练出的模型数据，可通过该参数来保存到某目录

在 mxnet1 容器跑任务时，执行`ps auxf` 可以看到以下情况

```
# mxnet1:DMLC_SERVER_ID = 0
$ ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      1189  0.1  0.0  18172  1960 ?        Ss   06:49   0:00 bash
root      1209  0.0  0.0  15568  1092 ?        R+   06:50   0:00  \_ ps auxf
root        21  0.0  0.0  18180  2012 ?        Ss   06:13   0:00 bash
root       707  0.0  0.0  61388  3008 ?        S    06:28   0:00  \_ /usr/sbin/sshd -D
root      1070  0.0  0.0  93040  3776 ?        Ss   06:48   0:00  |   \_ sshd: root@notty
root      1104  0.0  0.0   9532  1152 ?        Ss   06:48   0:00  |   |   \_ bash -c export DMLC_SERVER_ID=0; export DMLC_PS_ROOT_URI=172.17.0.2; export DMLC_ROLE=server; export DMLC_PS_ROO
root      1106 20.2  0.5 1476968 44572 ?       Sl   06:48   0:25  |   |       \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root      1076  0.0  0.0  93040  3780 ?        Ss   06:48   0:00  |   \_ sshd: root@notty
root      1105  0.0  0.0   9532  1148 ?        Ss   06:48   0:00  |       \_ bash -c export DMLC_SERVER_ID=2; export DMLC_WORKER_ID=0; export DMLC_PS_ROOT_URI=172.17.0.2; export DMLC_ROLE=w
root      1107  231  3.6 1697896 285192 ?      Sl   06:48   4:51  |           \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root      1053  0.1  0.1 550704 10880 ?        Sl+  06:48   0:00  \_ python ../../tools/launch.py -n 3 --launcher ssh -H hosts python train_mnist.py --network lenet --kv-store dist_sync --m
root      1056  0.0  0.0   4452   652 ?        S+   06:48   0:00      \_ /bin/sh -c python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root      1059  0.5  0.4 1165740 38980 ?       Sl+  06:48   0:00      |   \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root      1057  0.0  0.0   4452   652 ?        S+   06:48   0:00      \_ /bin/sh -c ssh -o StrictHostKeyChecking=no 172.17.0.2 -p 22 'export DMLC_SERVER_ID=0; export DMLC_PS_ROOT_URI=172.17
root      1061  0.0  0.0  44164  2928 ?        S+   06:48   0:00      |   \_ ssh -o StrictHostKeyChecking=no 172.17.0.2 -p 22 export DMLC_SERVER_ID=0; export DMLC_PS_ROOT_URI=172.17.0.2; ex
root      1060  0.0  0.0   4452   652 ?        S+   06:48   0:00      \_ /bin/sh -c ssh -o StrictHostKeyChecking=no 172.17.0.3 -p 22 'export DMLC_SERVER_ID=1; export DMLC_PS_ROOT_URI=172.17
root      1064  0.0  0.0  44164  2928 ?        S+   06:48   0:00      |   \_ ssh -o StrictHostKeyChecking=no 172.17.0.3 -p 22 export DMLC_SERVER_ID=1; export DMLC_PS_ROOT_URI=172.17.0.2; ex
root      1063  0.0  0.0   4452   648 ?        S+   06:48   0:00      \_ /bin/sh -c ssh -o StrictHostKeyChecking=no 172.17.0.6 -p 22 'export DMLC_SERVER_ID=2; export DMLC_PS_ROOT_URI=172.17
root      1067  0.0  0.0  44164  2928 ?        S+   06:48   0:00      |   \_ ssh -o StrictHostKeyChecking=no 172.17.0.6 -p 22 export DMLC_SERVER_ID=2; export DMLC_PS_ROOT_URI=172.17.0.2; ex
root      1068  0.0  0.0   4452   652 ?        S+   06:48   0:00      \_ /bin/sh -c ssh -o StrictHostKeyChecking=no 172.17.0.2 -p 22 'export DMLC_SERVER_ID=2; export DMLC_WORKER_ID=0; expor
root      1072  0.0  0.0  44164  2924 ?        S+   06:48   0:00      |   \_ ssh -o StrictHostKeyChecking=no 172.17.0.2 -p 22 export DMLC_SERVER_ID=2; export DMLC_WORKER_ID=0; export DMLC_P
root      1069  0.0  0.0   4452   648 ?        S+   06:48   0:00      \_ /bin/sh -c ssh -o StrictHostKeyChecking=no 172.17.0.3 -p 22 'export DMLC_SERVER_ID=2; export DMLC_WORKER_ID=1; expor
root      1074  0.0  0.0  44164  2928 ?        S+   06:48   0:00      |   \_ ssh -o StrictHostKeyChecking=no 172.17.0.3 -p 22 export DMLC_SERVER_ID=2; export DMLC_WORKER_ID=1; export DMLC_P
root      1073  0.0  0.0   4452   648 ?        S+   06:48   0:00      \_ /bin/sh -c ssh -o StrictHostKeyChecking=no 172.17.0.6 -p 22 'export DMLC_SERVER_ID=2; export DMLC_WORKER_ID=2; expor
root      1075  0.0  0.0  44164  2924 ?        S+   06:48   0:00          \_ ssh -o StrictHostKeyChecking=no 172.17.0.6 -p 22 export DMLC_SERVER_ID=2; export DMLC_WORKER_ID=2; export DMLC_P
root         1  0.0  0.0  18168  1440 ?        Ss+  06:12   0:00 /bin/bash
root       720  0.0  0.0   4452   648 ?        S    06:35   0:00 /bin/sh -c python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root       724  0.7  0.4 1165744 36684 ?       Rl   06:35   0:06  \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root       934  0.0  0.0   4452   648 ?        S    06:37   0:00 /bin/sh -c python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root       937  0.1  0.4 1165740 36948 ?       Sl   06:37   0:01  \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root       979  0.0  0.0   9528  1148 ?        Ss   06:37   0:00 bash -c export DMLC_SERVER_ID=0; export DMLC_PS_ROOT_URI=172.17.0.2; export DMLC_ROLE=server; export DMLC_PS_ROOT_PORT=9092;
root       983  0.1  0.4 1313080 34956 ?       Sl   06:37   0:01  \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root       984  0.0  0.0   9532  1152 ?        Ss   06:37   0:00 bash -c export DMLC_SERVER_ID=2; export DMLC_WORKER_ID=0; export DMLC_PS_ROOT_URI=172.17.0.2; export DMLC_ROLE=worker; expor
root       985  0.5  3.4 1543268 273144 ?      Sl   06:37   0:03  \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist

# mxnet2:DMLC_SERVER_ID = 1
$ ps auxf
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root        21  0.0  0.0  18240  2064 ?        Ss   06:13   0:00 bash
root       704  0.0  0.0  61388  3064 ?        S    06:28   0:00  \_ /usr/sbin/sshd -D
root       841  0.0  0.0  95104  3852 ?        Ss   06:48   0:00  |   \_ sshd: root@notty
root       858  0.0  0.0   9528  1152 ?        Ss   06:48   0:00  |   |   \_ bash -c export DMLC_SERVER_ID=1; export DMLC_PS_ROOT_URI=172.17.0.2; export DMLC_ROLE=server; export DMLC_PS_ROO
root       862 30.8  0.6 1478788 48944 ?       Sl   06:48   0:49  |   |       \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root       842  0.0  0.0  95104  3852 ?        Ss   06:48   0:00  |   \_ sshd: root@notty
root       865  0.0  0.0   9532  1152 ?        Ss   06:48   0:00  |       \_ bash -c export DMLC_SERVER_ID=2; export DMLC_WORKER_ID=1; export DMLC_PS_ROOT_URI=172.17.0.2; export DMLC_ROLE=w
root       866  239  3.5 1698100 284416 ?      Sl   06:48   6:21  |           \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root       947  0.0  0.0  15568  1092 ?        R+   06:51   0:00  \_ ps auxf
root         1  0.0  0.0  18168  1892 ?        Ss+  06:12   0:00 /bin/bash
root       778  0.0  0.0   9532  1148 ?        Ss   06:37   0:00 bash -c export DMLC_SERVER_ID=2; export DMLC_WORKER_ID=1; export DMLC_PS_ROOT_URI=172.17.0.2; export DMLC_ROLE=worker; expor
root       782  0.4  3.5 1543264 278348 ?      Sl   06:37   0:03  \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root       783  0.0  0.0   9528  1152 ?        Ss   06:37   0:00 bash -c export DMLC_SERVER_ID=1; export DMLC_PS_ROOT_URI=172.17.0.2; export DMLC_ROLE=server; export DMLC_PS_ROOT_PORT=9092;
root       784  0.1  0.4 1313080 38880 ?       Sl   06:37   0:01  \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist

# mxnet3：DMLC_SERVER_ID = 2
$ ps auxf
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root        21  0.0  0.0  18180  2004 ?        Ss   06:13   0:00 bash
root       704  0.0  0.0  61388  3068 ?        S    06:28   0:00  \_ /usr/sbin/sshd -D
root       812  0.0  0.0  95104  3832 ?        Ss   06:48   0:00  |   \_ sshd: root@notty
root       834  0.0  0.0   9528  1304 ?        Ss   06:48   0:00  |   |   \_ bash -c export DMLC_SERVER_ID=2; export DMLC_PS_ROOT_URI=172.17.0.2; export DMLC_ROLE=server; export DMLC_PS_ROO
root       836 29.9  0.5 1477224 39932 ?       Sl   06:48   0:51  |   |       \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root       813  0.0  0.0  95104  3836 ?        Ss   06:48   0:00  |   \_ sshd: root@notty
root       835  0.0  0.0   9532  1308 ?        Ss   06:48   0:00  |       \_ bash -c export DMLC_SERVER_ID=2; export DMLC_WORKER_ID=2; export DMLC_PS_ROOT_URI=172.17.0.2; export DMLC_ROLE=w
root       837  232  3.6 1694764 286948 ?      Sl   06:48   6:37  |           \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
root       910  0.0  0.0  15568  1092 ?        R+   06:51   0:00  \_ ps auxf
root         1  0.0  0.0  18168  1896 ?        Ss+  06:13   0:00 /bin/bash
root       754  0.0  0.0   9528  1156 ?        Ss   06:37   0:00 bash -c export DMLC_SERVER_ID=2; export DMLC_PS_ROOT_URI=172.17.0.2; export DMLC_ROLE=server; export DMLC_PS_ROOT_PORT=9092;
root       755  0.1  0.4 1313084 36964 ?       Sl   06:37   0:01  \_ python train_mnist.py --network lenet --kv-store dist_sync --model-prefix model/mnist
```

### 预测

根据之前 MXNet 训练结果，加载 model，进行预测与应用。

```
$ pip install -U six                    # matplotlib 要求 six >= 1.6.0
$ pip install matplotlib
$ apt-get install -y python-tk
$ apt-get install -y Python-OpenCV      # 解决 ImportError: No module named cv2 的错误，centos：yum install opencv-python
```

## 参考文献

1.官方案例介绍：[http://www.jianshu.com/p/3f3b7e4d1281](http://www.jianshu.com/p/3f3b7e4d1281)

2.官网-处理欲训练模型：[http://mxnet.io/tutorials/python/predict\_imagenet.html](http://mxnet.io/tutorials/python/predict_imagenet.html)

3.**官网-图像处理**：[http://mxnet.io/tutorials/computer\_vision/image\_classification.html](http://mxnet.io/tutorials/computer_vision/image_classification.html)

4.**Run MXNet on Multiple CPU/GPUs with Data Parallel**：[http://mxnet.io/how\_to/multi\_devices.html](http://mxnet.io/how_to/multi_devices.html)

5.mxnet examples 实验笔记：[https://ask.julyedu.com/question/7542](https://ask.julyedu.com/question/7542)

6.官网-手写体数字识别：http://mxnet.io/tutorials/python/mnist.html