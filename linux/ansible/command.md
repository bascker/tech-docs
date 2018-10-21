# 命令

### 介绍

ansible 的相关命令如下：

1. **ansible**：ansible 基本命令
2. **ansible-playbook**：用于执行 playbook 的命令
3. **ansible-doc**：查看模块的帮助文档
4. ansible-console：ansible 的命令控制台
5. **ansible-galaxy**：用于从[https://galaxy.ansible.com/](https://galaxy.ansible.com/) 站点下载第三方扩展模块
6. ansible-pull：用于从 git 上 checkout 一个关于配置指令的 repo，然后以该配置指令来运行 ansible-playbook
7. ansible-vault：用于加密/解密配置文件。主要对于playbooks中如涉及到配置密码时，对该指令加密

### 案例

1.查看任务所指定的 hosts 列表：**--list-hosts**

```
$ ansible-playbook playbook.yml --list-hosts
playbook: playbook.yml

  play #1 (node): node    TAGS: []
    pattern: [u'node']
    hosts (3):
      10.158.113.156
      10.158.113.157
      10.158.113.155
```

2.获取远程主机所有基本信息：**setup **模块

```
$ ansible node[0] -m setup
10.158.113.155 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "172.17.0.1",
            "10.158.113.155",
            "10.158.113.158"
        ],
        ...
        "ansible_interfaces": [
            "docker0",
            "br-tun",
            "lo",
            "ovs-system",
            "eno33557248",
            "br-int",
            "eno16777728",
            "br-ex"
        ],
        ...
```

3.**ansible-console** 的使用

```
# 使用 node 主机组：若不指定默认是 all
$ ansible-console node
Welcome to the ansible console.
Type help or ? to list commands.

# 列出所有节点
root@node (3)[f:5]$ list
10.158.113.155
10.158.113.156
10.158.113.157
root@node (3)[f:5]$
# ping 模块测试
root@node (3)[f:5]$ ping
10.158.113.155 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
10.158.113.156 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
10.158.113.157 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
# service 模块测试
root@node (3)[f:5]$ service name=glusterd state=restarted
10.158.113.155 | SUCCESS => {
...
# 退出
root@node (3)[f:5]$ exit
```