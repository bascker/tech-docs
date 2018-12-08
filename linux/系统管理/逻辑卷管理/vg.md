# VG(Volume Group)系列命令
## 简介
用于管理卷组的相关命令
1. **vgscan**：检查当前系统是否存在 vg
2. **vgs**：显示所有vg
3. **vgcreate**：用于创建LVM卷组
4. **vgdisplay**：查看逻辑卷组

## 案例
1.创建逻辑卷组 cinder-volumes，并将 pv 卷 /dev/sdb 加入该LVM卷组
```
$ vgcreate cinder-volumes /dev/sdb
```

2.查看 vg 卷
```
$ vgscan
  Reading all physical volumes.  This may take a while...
  Found volume group "centos" using metadata type lvm2
  Found volume group "cinder-volumes" using metadata type lvm2

$ vgs
  VG              PV  LV  SN Attr   VSize  VFree
  centos           1   3   0 wz--n- 99.51g 64.00m
  cinder-volumes   1   0   0 wz--n- 50.00g 50.00g

$ vgs cinder-volumes
  VG              PV  LV  SN Attr   VSize  VFree
  cinder-volumes   1   0   0 wz--n- 50.00g 50.00g

$ vgdisplay cinder-volumes
  --- Volume group ---
  VG Name               cinder-volumes
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               50.00 GiB
  PE Size               4.00 MiB
  Total PE              12799
  Alloc PE / Size       0 / 0
  Free  PE / Size       12799 / 50.00 GiB
  VG UUID               1QKRQW-JmTK-2YV5-rmsr-mBw1-GmhH-cfDSCO
```