# fdisk
## 简介
用于观察硬盘实体使用情况，也可对硬盘分区。常用选项：

* **-b**：指定每个分区的大小
* **-l**：列出指定的外围设备的分区表状况
* **-s**：将指定的分区大小输出到标准输出上，单位为区块
* **-u**：搭配 **-l**参数列表，会用分区数目取代柱面数目，来表示每个分区的起始地址
* **-v**：显示版本信息

## 案例
```
$ lsblk
NAME            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
...
sdl               8:176  0 447.1G  0 disk
└─sdl1            8:177  0 447.1G  0 part /ssd


$ fdisk -l /dev/sdl
Disk /dev/sdl: 480.1 GB, 480103981056 bytes, 937703088 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: gpt

#         Start          End    Size  Type            Name
 1         2048    937703054  447.1G  Linux filesyste
```