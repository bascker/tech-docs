# PV
## 一、简介
pv 是  Persistent Volume 的简称，即持久化卷， 用于抽象存储细节。 管理员通过 pv 提供存储功能，而不关注用户如何使用它，用户
通过 pvc 来申请 pv  中的存储资源，进行数据持久化的存储。
> 1 个 pv 只能绑定一个 pvc，即只能同时被一个 pvc 使用

pv 常见的后端存储技术
* AWSElasticBlockStore
* AzureFile
* NFS
* iSCSI
* RBD：ceph块存储
* Cinder：openstack块存储
* Glusterfs
* HostPath：宿主机目录

pv 的生命周期：
* Available： 管理员在集群中创建多个 pv 供用户使用
* Bound： 用户创建 pvc 并指定需要的资源和访问模式，3种访问模式
  * ReadWriteOnce：RWO,单节点读写
  * ReadOnlyMany：ROX,多节点只读
  * ReadWriteMany：RWX,多节点读写
* Release： 用户删除 pvc 来回收存储资源，pv 重新可用
* Recycle：3种回收策略
  * 保留(Retain)：允许人工处理保留的数据
  * 回收(Recycle)：将执行清除操作，之后可以被新的 pvc 使用，需要插件支持
  * 删除(Delete)：将删除 pv 和外部关联的存储资源，需要插件支持
  > 目前 NFS 和 HostPath 支持回收, AWS、EBS、GCE、PD 和 Cinder 支持删除

## 二、案例
使用 nfs 作为后端存储支持
```
$ vim nfs_pv.yml
# 使用 nfs 作为存储支持的 pv
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs                                          # pv 名
  annotations:
    volume.beta.kubernetes.io/storage-class: "slow"
spec:
  capacity:
    storage: 5Gi                                     # 设定 pv 容量
  accessModes:
    - ReadWriteOnce                                  # 设置访问模式
  persistentVolumeReclaimPolicy: Recycle             # 回收策略
  nfs:                                               # 后端存储策略：nfs
    path: /home/nfs
    server: nfs-server

$ kubectl create -f nfs_pv.yml
persistentvolume "nfs" created

$ kubectl get pv nfs
NAME      CAPACITY   ACCESSMODES   STATUS      CLAIM     REASON    AGE
nfs       5Gi        RWO           Available                       29s
```