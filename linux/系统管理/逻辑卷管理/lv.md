# LV\(logic volume\)相关命令
## 简介
用于逻辑卷的相关命令

1. **lvscan**：检查当前系统是否存在 lv
2. **lvs**：列出所有 lv
3. **lvcreate**：创建 lv
4. **lvdisplay**：显示 lv 信息

## 案例
```
1. 查看分区
$ lsblk
NAME            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
...
sdb               8:16   0   1.8T  0 disk
├─sdb1            8:17   0   1.8T  0 part
└─sdb2            8:18   0     5G  0 part
sdc               8:32   0   1.8T  0 disk
└─sdc1            8:33   0   1.8T  0 part
...

2. 创建 pv 卷
$ pvcreate /dev/sdb1
$ pvcreate /dev/sdb2
$ pvcreate /dev/sdc1
$ pvs
  PV         VG         Fmt  Attr PSize   PFree
  /dev/sda2  centos     lvm2 a--    1.82t  60.00m
  /dev/sdb1  vg-sdb-sdc lvm2 a--    1.81t  34.62g
  /dev/sdb2  vg-sdb-sdc lvm2 a--    5.00g   5.00g
  /dev/sdc1  vg-sdb-sdc lvm2 a--    1.82t      0

3. 创建 vg 卷组
$ vgcreate vg-sdb-sdc /dev/sdb1 /dev/sdb2 /dev/sdc1
  Volume group "vg-sdb-sdc" successfully created

$ vgscan
  Reading all physical volumes.  This may take a while...
  Found volume group "vg-sdb-sdc" using metadata type lvm2

$ vgs
  VG         #PV #LV #SN Attr   VSize VFree
  vg-sdb-sdc   3   0   0 wz--n- 3.64t  3.64t

4. 创建 lv
$ lvcreate -L 3.6T -n lv-sdb-sdc vg-sdb-sdc
  Rounding up size to full physical extent 3.60 TiB
  Logical volume "lv-sdb-sdc" created.

$ lvs
  LV         VG         Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv-sdb-sdc vg-sdb-sdc -wi-a-----  3.60t

5. 创建文件系统
$ mkfs.xfs /dev/vg-sdb-sdc/lv-sdb-sdc
meta-data=/dev/vg-sdb-sdc/lv-sdb-sdc isize=256    agcount=4, agsize=241592064 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=0        finobt=0
data     =                       bsize=4096   blocks=966368256, imaxpct=5
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
log      =internal log           bsize=4096   blocks=471859, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

6. 挂载到目录
$ mkdir /sdb
$ mount -v /dev/vg-sdb-sdc/lv-sdb-sdc /sdb
mount: /sdb does not contain SELinux labels.
       You just mounted an file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
mount: /dev/mapper/vg--sdb--sdc-lv--sdb--sdc mounted on /sdb.

$ df -h
Filesystem                             Size  Used Avail Use% Mounted on
...
/dev/mapper/vg--sdb--sdc-lv--sdb--sdc  3.6T   33M  3.6T   1% /sdb
```