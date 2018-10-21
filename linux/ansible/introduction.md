# Ansible
## 简介
* 一个配置管理和应用部署工具
* 由 python 实现
* 默认通过 SSH 协议管理机器
* 配置目录：_**/etc/ansible**_
  * 配置文件：_ansible.cfg_
  * 默认inventory：_hosts_

## 安装
ansible 的安装很简单，只需执行一条命令即可
```
$ yum install -y ansible
$ ansibel --version
ansible 2.1.0.0
  config file = /etc/ansible/ansible.cfg
  configured module search path = Default w/o overrides
```