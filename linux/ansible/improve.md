# 性能优化

### 参考文献
1.Ansible 进阶技巧：[http://www.tuicool.com/articles/ZRFfUvE](http://www.tuicool.com/articles/ZRFfUvE)
2.Anisble 的配置文件：[http://ansible-tran.readthedocs.io/en/latest/docs/intro\_configuration.html\#control-path](http://ansible-tran.readthedocs.io/en/latest/docs/intro_configuration.html#control-path)

## 准备：收集数据，利用 ansible-profile 任务计时插件
性能优化之前首先需要做的是收集一些统计数据，这样才能为后面做的性能优化提供数据支持，对比优化前后的结果。利用 **ansible-profile** 任务计时插件可以收集各任务的耗时。
ansible-profile：
* Ansible 任务计时插件
* git地址：[https://github.com/jlafon/ansible-profile](https://github.com/jlafon/ansible-profile)
* 安装流程：
  ```
  # 获取
  $ cd /etc/ansible
  $ mkdir -p /etc/ansible/callback_plugins
  $ curl -O https://raw.githubusercontent.com/jlafon/ansible-profile/master/callback_plugins/profile_tasks.py

  # 配置：设置 callback_whitelist 为 profile_tasks
  $ sed -i 's/\#callback_whitelist = timer, mail/callback_whitelist = profile_tasks/g' /etc/ansible/ansible.cfg

  # 使用测试
  $ vim playbook_test.yml
  ---
  - hosts: kvm
    tasks:
    - name: test connection
      ping:

  $ ansible-playbook  playbook_test.yml

  PLAY [kvm] *********************************************************************

  TASK [setup] *******************************************************************
  Tuesday 17 January 2017  13:19:32 +0800 (0:00:00.068)       0:00:00.068 *******
  ok: [10.158.113.253]

  TASK [test connection] *********************************************************
  Tuesday 17 January 2017  13:19:37 +0800 (0:00:04.732)       0:00:04.801 *******
  ok: [10.158.113.253]

  PLAY RECAP *********************************************************************
  10.158.113.253             : ok=2    changed=0    unreachable=0    failed=0

  Tuesday 17 January 2017  13:19:37 +0800 (0:00:00.351)       0:00:05.152 *******
  ===============================================================================
  setup ------------------------------------------------------------------- 4.73s    # setup 任务计时
  test connection --------------------------------------------------------- 0.35s    # test connection 任务计时
  ```

## 开启 SSH pipelining
SSH pipelining 是一个加速 Ansible 执行速度的简单方法，该选项在 _/etc/ansible/ansible.cfg_ 中进行配置，默认是 False。
```
# Enabling pipelining reduces the number of SSH operations required to
# execute a module on the remote server. This can result in a significant
# performance improvement when enabled, however when using "sudo:" you must
# first disable 'requiretty' in /etc/sudoers
#
# By default, this option is disabled to preserve compatibility with
# sudoers configurations that have requiretty (the default on many distros).
#
# pipelining = False
```
该选项可以减少 ansible 执行远程模块时所要求的 ssh 操作数，打开它可以有效提高性能。默认这个选项为了保证与sudoers requiretty的设置（在很多发行版中时默认的设置）的兼容性是禁用的. 但是为了提高性能强烈**建议开启**这个设置

> 注：当使用 sudo 时，需要先在 /etc/sudoers 中关闭 requiretty 选项

\[**开启前后对比：6台远程主机**\]
关闭 pipelining 的情况下：
```
$ ansible-playbook -f 10 -i /var/deploy/inventory /var/deploy/pre/playbook_copy_rsa

PLAY [all] *********************************************************************

TASK [ssh-copy] ****************************************************************
Tuesday 17 January 2017  15:29:53 +0800 (0:00:00.076)       0:00:00.076 *******
ok: [controller3]
ok: [computer1]
ok: [computer3]
ok: [computer2]
ok: [controller1]
ok: [controller2]

PLAY [localhost] ***************************************************************

TASK [copy-etc-hosts] **********************************************************
Tuesday 17 January 2017  15:29:54 +0800 (0:00:00.970)       0:00:01.046 *******
changed: [localhost] => (item=controller1)
changed: [localhost] => (item=controller2)
changed: [localhost] => (item=controller3)
changed: [localhost] => (item=computer1)
changed: [localhost] => (item=computer2)
changed: [localhost] => (item=computer3)

PLAY RECAP *********************************************************************
computer1                  : ok=1    changed=0    unreachable=0    failed=0
computer2                  : ok=1    changed=0    unreachable=0    failed=0
computer3                  : ok=1    changed=0    unreachable=0    failed=0
controller1                : ok=1    changed=0    unreachable=0    failed=0
controller2                : ok=1    changed=0    unreachable=0    failed=0
controller3                : ok=1    changed=0    unreachable=0    failed=0
localhost                  : ok=1    changed=1    unreachable=0    failed=0

Tuesday 17 January 2017  15:29:56 +0800 (0:00:02.139)       0:00:03.185 *******
===============================================================================
copy-etc-hosts ---------------------------------------------------------- 2.14s
ssh-copy ---------------------------------------------------------------- 0.97s
```

开启 pipelining  的情况:
```
$ ansible-playbook -f 10 -i /var/deploy/inventory /var/deploy/pre/playbook_copy_rsa

PLAY [all] *********************************************************************

TASK [ssh-copy] ****************************************************************
Tuesday 17 January 2017  15:30:37 +0800 (0:00:00.068)       0:00:00.068 *******
ok: [controller3]
...

PLAY [localhost] ***************************************************************

TASK [copy-etc-hosts] **********************************************************
Tuesday 17 January 2017  15:30:37 +0800 (0:00:00.598)       0:00:00.666 *******
changed: [localhost] => (item=controller1)
...

PLAY RECAP *********************************************************************
computer1                  : ok=1    changed=0    unreachable=0    failed=0
...
localhost                  : ok=1    changed=1    unreachable=0    failed=0

Tuesday 17 January 2017  15:30:39 +0800 (0:00:01.988)       0:00:02.655 *******
===============================================================================
copy-etc-hosts ---------------------------------------------------------- 1.99s
ssh-copy ---------------------------------------------------------------- 0.60s
```
总结：从输出可以看到开启后性能显著提高

## 开启 ControlPersist
修改_ ansible.cfg_，具体配置如下：
```
$ vim /etc/ansible/ansible.cfg
ssh_args = -o ControlMaster=auto -o ControlPersist=30m

# 30 分钟通常比较合适
```

开启前：
```
$ time ansible node -m shell -a "echo aaa"
10.158.113.155 | SUCCESS | rc=0 >>
aaa

10.158.113.157 | SUCCESS | rc=0 >>
aaa

10.158.113.156 | SUCCESS | rc=0 >>
aaa


real    0m1.465s
user    0m0.884s
sys     0m0.539s
```

开启后：
```
$ time ansible node -m shell -a "echo aaa"
10.158.113.157 | SUCCESS | rc=0 >>
aaa

10.158.113.156 | SUCCESS | rc=0 >>
aaa

10.158.113.155 | SUCCESS | rc=0 >>
aaa


real    0m1.009s
user    0m0.780s
sys     0m0.310s
```

# 关闭 gathering
gathering 选项用于收集facts\(远程主机的系统变量\)。默认配置如下：
```
$ cat ansible.cfg
# plays will gather facts by default, which contain information about
# the remote system.
#
# smart - gather by default, but don't regather if already gathered
# implicit - gather by default, turn off with gather_facts: False
# explicit - do not gather by default, must say gather_facts: True
#gathering = implicit
```

默认每次都去收集系统变量，导致速度降低，因此可以关闭它来提高性能。
```
$ vim ansible.cfg
gathering = explicit
```
配置后，若 _playbook _中需要去收集，则指定 _gather\_facts: True_。