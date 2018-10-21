# 常用模块

> 所有模块都可以使用 ansible-doc 命令查看帮助文档

### command

在远程主机上执行**一条**命令。使用该模块，在解析时，会将** -a** 的**第一个**值作为**命令**，后面的值都当做命令的**参数**

> 注：是一条命令，不是多条

\[命令方式\]

```
$ ansible node -m command -a "echo aaa"
10.158.113.156 | SUCCESS | rc=0 >>
aaa
...

# 无法执行多条命令，即使用 && 连接也不行
$ ansible node -m command -a "echo aaa && echo bbb && echo ccc"
10.158.113.157 | SUCCESS | rc=0 >>
aaa && echo bbb && echo ccc
...
```

\[playbook方式\]

```
$ vim playbook.yml
---
- hosts: node
  tasks:
  - name: "Just a test"
    command: "echo aaa"

$ ansible-playbook playbook.yml
```

### shell

用于执行 shell 命令，可以实现执行多条命令。

\[命令方式\]

```
$ ansible node -m shell -a "echo aaa && echo bbb & echo ccc"
10.158.113.156 | SUCCESS | rc=0 >>
ccc
aaa
bbb
...
```

\[playbook方式\]

```
$ vim playbook.yml
---
- hosts: node
  tasks:
  - name: "Just a test"
    shell: "echo aaa && echo bbb && echo ccc"

$ ansible-playbook playbook.yml
```

对于 ansible，若使用 shell 来执行后台命令，当 ansible 将后台命令在所有远程主机上触发后，就认为该 task 结束，然后 kill 掉进程\(即使远程主机上的该后台命令没执行结束\)。因此若想执行后台命令，不建议使用那种很耗时的操作，会出错。如下：

```
$ vim playbook.yml
---
- hosts: node
  tasks:
  - name: "pull images"
    shell: "docker pull ubuntu&"

# 执行
$ ansible-playbook playbook.yml
PLAY [node] ********************************************************************

TASK [pull images] *************************************************************
Friday 20 January 2017  10:48:27 +0800 (0:00:00.089)       0:00:00.089 ********
changed: [10.158.113.156]
...
PLAY RECAP *********************************************************************
10.158.113.155             : ok=1    changed=1    unreachable=0    failed=0

Friday 20 January 2017  10:48:29 +0800 (0:00:01.760)       0:00:01.850 ********
===============================================================================
pull images ------------------------------------------------------------- 1.76s

# 查看结果: 并没有。因为该后台命令还未执行结束，就被 kill 掉了
$ (docker images | grep ubuntu) || echo "No such images"
No such images

$ tail /var/log/message
... error="rpc error: code = 2 desc = grpc: the client connection is closing" module=agent
```

### script

可以让被控制节点执行 ansible 节点上的脚本。

\[命令方式\]

```
$ vim rm_imgs.sh
#!/bin/bash

imgs=$(docker images | tail -n +2 | awk '{print $1":"$2}')
for img in $imgs
do
  docker rmi $img
  echo
done

$ ansible all -m script -a './rm_imgs.sh'
```

\[playbook方式\]

```
$ vim playbook_rm_imgs.yml
- hosts: all
  gather_facts: false
  tasks:
    - name: remove images
      script: /root/rm_imgs.sh
```

### copy

用于文件操作的模块，将 ansible 主机的文件拷贝到远程机器

\[命令方式\]

```
# 拷贝本地的 /root/test.txt 文件到 local 机组所有主机的 /root/test.txt~
$ ansible local -m copy -a "src=/root/test.txt dest=/root/test.txt~"

# 拷贝并设置权限
$ ansible all -m copy -a "src=test.txt dest=/root/test.txt owner=root group=root mode=0777"
```

\[playbook方式\]

```
$ vim playbook.yml
---
- hosts: node
  tasks:
  - name: "Just a test"
    copy: src=./a.txt dest=./a.txt.bak
```

### file

用于文件操作的模块，如新建文件、删除文件、权限更改。

重要参数 **state**：

* directory：目标目录不存在时则创建
* link：创建/更改软连接
* hard：创建/更改hardlinks
* absent：递归删除目录、文件、连接
* touch：搭配 path 属性使用，若 path 值不存在，则创建空白文件

\[命令方式\]

```
# 新建目录
$ ansible node -m file -a "dest=/root/newdir/a mode=755 owner=root group=root state=directory"

# 更改权限
$ ansible node -m file -a "dest=/root/newdir/a mode=600"

# 删除
$ ansible node -m file -a "dest=/root/newdir state=absent"
```

\[playbook方式\]

```
# touch 一个文件
$ vim playbook.yml
---
- hosts: node
  tasks:
  - name: "Just a test"
    file: path=/root/test.txt state=touch
```

### service

用于服务管理

\[命令方式\]

```
# 重启服务
$ ansible node -m service -a "name=glusterd state=restarted"
```

\[playbook方式\]

```
$ vim playbook.yml
---
- hosts: node
  tasks:
  - name: "Just a test"
    service: name=glusterd state=restarted
```

### when + with\_item 语句

when 用于条件判断， with\_item 用于迭代

```
# 案例1：when + with_item
$ vim playbook.yml
- hosts: node
  tasks:
  - name: "Test when and with_item"
    command: "echo {{ item }}"
    with_items: [0, 1, 2, 3]
    when: item > 2

$ ansible-playbook playbook.yml
...
TASK [Test when and with_item] *************************************************
skipping: [10.158.113.157] => (item=0)
skipping: [10.158.113.157] => (item=1)
skipping: [10.158.113.157] => (item=2)
...
changed: [10.158.113.157] => (item=3)

# 案例2：when + with_item + in
$ vim playbook.yml
- hosts: node
  tasks:
  - name: "Test when and with_item"
    command: "echo {{ item }}"
    with_items:
    - "ceilometer-api"
    - "ceilometer-central"
    - "ceilometer-notification"
    when: item in ["ceilometer-api", "ceilometer-compute"]
```

### template

用于根据 j2 模板文件生成指定文件

```
$ vim conf.j2
[DEFAULT]
username={{ username }}
userpass={{ userpass }}

$ vim playbook.yml
---
- hosts: test
  vars:
    username: "johnnie"
    userpass: "123456"
  tasks:
  - name: lookup test
    local_action: template src=./conf.j2 dest=./user.conf
    run_once: true

$ ansible-playbook playbook.yml

...

TASK [lookup test] *************************************************************
changed: [kolla-con1 -> localhost]

PLAY RECAP *********************************************************************
kolla-con1                 : ok=2    changed=1    unreachable=0    failed=0

$ cat user.conf
[DEFAULT]
username=johnnie
userpass=123456


# 不用 local_action, 这样会将文件生成到远程机器
$ vim playbook.yml
---
- hosts:
  - test
  vars:
    username: "johnnie"
    userpass: "123456"
  tasks:
  - name: lookup test
    template:
      src: /root/conf.j2
      dest: /root/user.conf
  run_once: true
```

> vars：用于设置变量；vars\_files：用于设置变量文件

### 循环与判断

#### with\_\*：循环

ansible playbook 中可以使用 with\_\* 来进行循环操作，常见如下：

1. with\_items：用于循环迭代
2. with\_first\_found：第一文件匹配
3. with\_nested：嵌套循环
4. with\_file：将文件内容作为 item 值

```
$ vim playbook.yml
---
- hosts:
  - all
  vars:
    username: "johnnie"
    userpass: "123456"
  tasks:
  - name: lookup test
    template:
      src: "{{ item }}"
      dest: /root/user.conf
    with_first_found:
    - "/root/test/conf.j2"
    - "/root/conf.j2"
```

#### when：判断

ansible 判断的关键字就是 when。支持 python 语法\(比较，in, not....\) 和 jinja2 的 filters. 常与循环搭配使用

```
$ vim playbook.yml
---
- hosts:
  - all
  tasks:
  - name: lookup test
    debug: msg="echo {{ item }}"
    with_items:
    - [1, 2, 3, 4, 5]
    when: item > 2

$ ansible-playbook playbook.yml

...

TASK [lookup test] *************************************************************
skipping: [kolla-con1] => (item=1)
skipping: [kolla-con1] => (item=2)
ok: [kolla-con1] => (item=3) => {
    "item": 3,
    "msg": "echo 3"
}
ok: [kolla-con1] => (item=4) => {
    "item": 4,
    "msg": "echo 4"
}
ok: [kolla-con1] => (item=5) => {
    "item": 5,
    "msg": "echo 5"
}

PLAY RECAP *********************************************************************
kolla-con1                 : ok=2    changed=0    unreachable=0    failed=0
```

> 注：when 中直接写变量名，不需要使用引号和双花括号包裹

### lookups

lookup 插件允许 ansible 从外部获取数据。其使用就像是 ansible 控制主机从被控节点上解析数据后变成一种可以被 ansible 模板系统使用的变量。

lookups 有如下类型：

1. _**file**_：读取文件内容
2. _**password**_：生成随机的明文密码，并存储到指定文件
3. **csvfile**：从 csv 文件中读取内容
4. **ini**：从 ini 配置文件中读取内容
5. **MongoDB**：从指定的 mongo 服务器中获取指定集合的 find\(\) 结果。2.3 版本支持
6. **env**：读取指定环境变量
7. **pipe**：运行某命令的执行结果
8. **template**：解析模板文件
9. **......**

> 注：
>
> 1.官方文档：[http://docs.ansible.com/ansible/playbooks\_lookups.html](http://docs.ansible.com/ansible/playbooks_lookups.html)
>
> 2.**lookup的数据获取是发生在 ansible 控制主机上**，而不是被控节点\(远程主机\)上
>
> 3.1.9版本开始，可以传入 wantlist=True 来让 lookups 使用 jinja2 的 for 关键字来迭代

1.**file lookup**：读取文件内容，是最基础的 lookup 类型

```
# 测试文件
$ vim a.txt
The file name is a.txt

$ pwd a.txt
/root/workspace

# 测试脚本
$ vim playbook.yml
---
- hosts: test
  vars:
    content: "{{ lookup('file', '/root/workspace/a.txt') }}"
  tasks:
  - name: lookup test
    debug: msg="{{ content }}"

# 执行
ansible-playbook playbook.yml

PLAY [test] ********************************************************************

TASK [setup] *******************************************************************
ok: [kolla-con1]

TASK [lookup test] *************************************************************
ok: [kolla-con1] => {
    "msg": "The file name is a.txt"
}

PLAY RECAP *********************************************************************
kolla-con1                 : ok=2    changed=0    unreachable=0    failed=0
```

2.**ini lookup**：解析配置文件

```
$ vim conf.ini
[DEFAULT]
username=johnnie
userpass=123456

$ vim playbook.yml
---
- hosts: test
  vars:
    content: "{{ lookup('ini', 'username section=DEFAULT file=/root/workspace/conf.ini') }}"
  tasks:
  - name: lookup test
    debug: msg="The user is {{ content }}"

$ ansible-playbook playbook.yml
...

TASK [lookup test] *************************************************************
ok: [kolla-con1] => {
    "msg": "The user is johnnie"
}
```

3.**env lookup**：读取环境变量

```
$ vimplaybook.yml
---
- hosts: test
  vars:
    content: "{{ lookup('env', 'HOSTNAME') }}"
  tasks:
  - name: lookup test
    debug: msg="The environment HOSTNAME is {{ content }}"

$ ansible-playbook playbook.yml
...

TASK [lookup test] *************************************************************
ok: [kolla-con1] => {
    "msg": "The environment HOSTNAME is kolla"
}
```

> 注：若不指定环境变量名，即写成 lookup\('env'\)，是不会去读取所有的环境变量值的，而是返回空列表 \[\]

4.**template lookup**

```
$ vim conf.j2
[DEFAULT]
username={{ username }}
userpass={{ userpass }}

$ vim playbook.yml
---
- hosts: test
  vars:
    username: "johnnie"
    userpass: "123456"
  tasks:
  - name: lookup test
    debug: msg="{{ lookup("template", "./conf.j2") }}"

$ ansible-playbook playbook.yml
...

TASK [lookup test] *************************************************************
ok: [kolla-con1] => {
    "msg": "[DEFAULT]\nusername=johnnie\nuserpass=123456\n"
}

# 注意：并没有替换模板文件
$ cat conf.j2
[DEFAULT]
username={{ username }}
userpass={{ userpass }}
```