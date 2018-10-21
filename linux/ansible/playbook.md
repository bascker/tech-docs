# Playbook

## 简介

* 一种运用 ansible 的方式
* 可以编排有序的执行过程,甚至于在多组机器间来回有序的执行指定操作.并且可以同步或异步的发起任务
* 格式：_YAML_语法
* 可结合 _jinja2 _模板来使用

## 基础

1.**hosts**： 内容是\(一个或多个\)组或主机的 _patterns_, 以逗号为分隔符

2.**tasks**：任务列表，包含多个子 task，每个 _task _顺序执行，且每一个 _task _必须有一个名称 _name_

3.**notify **：发生改动时执行的动作，触发的动作由 _handler _进行执行\(只执行一次\)

4.**vars**：变量定义

* 要求：以字母开头，由字母,数字以及下划线组合
* 引用：使用双花括号"_{{}}_"进行变量的引用

5.**组织结构**：使用 playbook 的最好的方式是使用 roles 进行项目的组织。良好的项目组织结构如下\(以 kolla-ansible 项目为例\)：

```
kolla-ansible
├── ansible
│   ├── action_plugins
│   ├── group_vars
│   │   └── all.yml                        # 全局的环境变量配置(最低优先级)
│   ├── inventory                          # inventory 文件目录
│   │   ├── all-in-one
│   │   └── multinode
│   ├── library                            # ansible 模块库
│   ├── roles                              # 角色
│   │   ├── ceilometer                     # ceilomter host
│   │   │   ├── defaults
│   │   │   │   └── main.yml               # ceilometer 的默认变量配置
│   │   │   ├── meta
│   │   │   │   └── main.yml               # 定义角色依赖
│   │   │   ├── tasks                      # 任务列表
│   │   │   │   ├── config.yml
│   │   │   │   ├── deploy.yml
│   │   │   │   ├── main.yml               # tasks 的主入口
│   │   │   │   ├── precheck.yml
│   │   │   │   ├── pull.yml
│   │   │   │   ├── reconfigure.yml
│   │   │   │   ...
│   │   │   │   └── upgrade.yml
│   │   │   └── templates                  # 存储模板文件
│   ├── site.yml                           # 入口文件，根据这个配置找到 role 的入口
...

$ cat site.yml
...
- name: Apply role ceilometer
  hosts:
    - ceilometer
    - compute
  serial: '{{ serial|default("0") }}'
  roles:
    - { role: ceilometer,
        tags: ceilometer,
        when: enable_ceilometer | bool }
...

$ cat meta.main.yml
---
dependencies:
  - { role: common }

$ cat tasks/main.yml
---
- include: "{{ action }}.yml"
```

## 案例
1.生成 mongodb 初始化集群脚本
[bootstrap_cluster.js.j2]

```
$ cat bootstrap_cluster.js.j2
printjson(rs.initiate(
  {
    "_id" : "{{ mongodb_replication_set_name }}",
    "version" : 1,
    "members" : [
      {% if orchestration_engine == 'ANSIBLE' %}
      {% for host in groups["mongodb"] %}
      {
        "_id" : {{ loop.index }},
        "host" : "{{ hostvars[host]['ansible_' + storage_interface]['ipv4']['address'] }}:{{ mongodb_port }}"
      }{% if not loop.last %},{% endif %}
      {% endfor %}
      {% else %}
      {
        "_id" : 1,
        "host" : "10.20.102.1:27017"
      },
	  {
        "_id" : 2,
        "host" : "10.20.102.2:27017"
      },
	  {
        "_id" : 3,
        "host" : "10.20.102.3:27017"
      }
      {% endif %}
    ]
  }
))
```


[gen-mongodb-bootstrap-script.yml]

```
$ cat gen-mongodb-bootstrap-script.yml
---
- hosts: mongodb
  gather_facts: false
  vars:
    mongodb_replication_set_name: "rs0"
    orchestration_engine: "KUBERNETES"
  tasks:
  - name: Copying the mongodb replication set bootstrap script
    local_action: template src=/root/bootstrap_cluster.js.j2 dest=/tmp/mongodb_bootstrap_replication_set.js
    run_once: True
```


[执行]


```
$ ansible-playbook -i /var/deploy/inventory gen-mongodb-bootstrap-script.yml

PLAY [mongodb] *****************************************************************

TASK [Copying the mongodb replication set bootstrap script] ********************
Monday 20 February 2017  17:51:18 +0800 (0:00:00.054)       0:00:00.054 *******
changed: [controller1-33 -> localhost]

PLAY RECAP *********************************************************************
controller1-33             : ok=1    changed=1    unreachable=0    failed=0

Monday 20 February 2017  17:51:19 +0800 (0:00:00.574)       0:00:00.628 *******
===============================================================================
Copying the mongodb replication set bootstrap script -------------------- 0.57s

$ cat /tmp/mongodb_bootstrap_replication_set.js
printjson(rs.initiate(
  {
    "_id" : "rs0",
    "version" : 1,
    "members" : [
      {
        "_id" : 1,
        "host" : "10.20.102.1:27017"
      },
	  {
        "_id" : 2,
        "host" : "10.20.102.2:27017"
      },
	  {
        "_id" : 3,
        "host" : "10.20.102.3:27017"
      }
    ]
  }
))
```
**_playbook _**中可以用 **_vars _**来**声明变量**，也可以使用 **_vars_files_** 来指定**变量文件**，甚至可以在执行 ansible-playbook 时使用 **_-e_** 来指定**变量文件**
[vars_files方式]
```
---
- hosts: mongodb
  gather_facts: false
  vars_files:
    - /root/kolla/ansible/roles/mongodb/defaults/main.yml
    - /etc/kolla/globals.yml
```

[-e 方式]
```
$ ansible-playbook -i /var/deploy/inventory \
    -e @/root/kolla/ansible/roles/mongodb/defaults/main.yml
    -e @/etc/kolla/globals.yml
    gen-mongodb-bootstrap-script.yml
```
> 注：使用  -e 指定变量文件是，必须在变量文件前加上@符号