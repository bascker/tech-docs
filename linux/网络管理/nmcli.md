# nmcli
## 简介

网络管理工具，即 NetworkManager command line tool 的简称

## 案例

### 查看网卡的UUID值

```
$ nmcli con
NAME         UUID                                  TYPE            DEVICE
docker0      4e531c5b-896f-492a-b290-730773224e84  bridge          docker0
eno16777728  8cedbaed-b1ed-aa77-7f3c-6b5a960f4bb5  802-3-ethernet  eno16777728
eno33557248  36bf3a6a-0946-49a9-9806-dad90519423e  802-3-ethernet  --
```