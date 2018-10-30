# Aodh 的 k8s 化
## 一、步骤
### 1.1 获取 aodh 组件分布
1.利用 kolla-ansible 部署一套 aodh 和 ceilometer 共存的环境

2.利用 ceilometer 命令查看 ceilometer 和 aodh 是否正常运行

```
$ ceilometer meter-list
+------+------+------+-------------+---------+------------+
| Name | Type | Unit | Resource ID | User ID | Project ID |
+------+------+------+-------------+---------+------------+
+------+------+------+-------------+---------+------------+

$ ceilometer alarm-list
+----------+------+-------+----------+---------+------------+-----------------+------------------+
| Alarm ID | Name | State | Severity | Enabled | Continuous | Alarm condition | Time constraints |
+----------+------+-------+----------+---------+------------+-----------------+------------------+
+----------+------+-------+----------+---------+------------+-----------------+------------------+

2个命令都成功，说明正常
```

3.获取 aodh 正常运行需要几个 docker 且分别运行在哪个节点：通过环境，可知只需要 aodh\_listener、aodh\_notifier、aodh\_evaluator、aodh\_api 就可以让 aodh 运行起来
> 注：也可以在 kolla-ansible 中 aodh 容器的启动 yml 获取该信息。目前版本为：role/aodh/handlers/main.yml

### 1.2 修改aodh模板文件，使其符合 k8s 环境
1.修改_**aodh.conf.j2**_模板文件

```
$ vim aodh.conf.j2
[DEFAULT]
auth_strategy = keystone
log_dir = /var/log/kolla/aodh
debug = {{ aodh_logging_debug }}
notification_topics = notifications

transport_url = rabbit://{% for host in groups['rabbitmq'] %}{{ rabbitmq_user }}:{{ rabbitmq_password }}@{% if orchestration_engine == 'KUBERNETES' %}rabbitmq{% else %}{{ hostvars[host]['ansible_' + hostvars[host]['api_interface']]['ipv4']['address'] }}{% endif %}:{{ rabbitmq_port }}{% if not loop.last %},{% endif %}{% endfor %}

[api]
port = {{ aodh_api_port }}
host = {% if orchestration_engine == 'KUBERNETES' %}aodh-api{% else %}{{ hostvars[inventory_hostname]['ansible_' + api_interface]['ipv4']['address'] }}{% endif %}

[database]
connection = mysql+pymysql://{{ aodh_database_user }}:{{ aodh_database_password }}@{{ aodh_database_address }}/{{ aodh_database_name }}


[keystone_authtoken]
memcache_security_strategy = ENCRYPT
memcache_secret_key = {{ memcache_secret_key }}
{% if orchestration_engine == 'ANSIBLE' %}
memcache_servers = {% for host in groups['memcached'] %}{{ hostvars[host]['ansible_' + hostvars[host]['api_interface']]['ipv4']['address'] }}:{{ memcached_port }}{% if not loop.last %},{% endif %}{% endfor %}
{% endif %}
{% if orchestration_engine == 'KUBERNETES' %}
memcache_servers = memcached:{{ memcached_port }}
{% endif %}
auth_uri = {{ internal_protocol }}://{% if orchestration_engine == 'KUBERNETES' %}keystone-public{% else %}{% endif %}:{{ keystone_public_port }}
project_domain_name = default
project_name = service
user_domain_name = default
username = {{ aodh_keystone_user }}
password = {{ aodh_keystone_password }}
auth_url = {{ admin_protocol }}://{% if orchestration_engine == 'KUBERNETES' %}keystone-admin{% else %}{{ kolla_internal_fqdn }}{% endif %}:{{ keystone_admin_port }}
auth_type = password


[service_credentials]
auth_url = {{ internal_protocol }}://{% if orchestration_engine == 'KUBERNETES' %}keystone-public{% else %}{{ kolla_internal_fqdn }}{% endif %}:{{ keystone_public_port }}/v3
region_name = {{ openstack_region_name }}
password = {{ aodh_keystone_password }}
username = {{ aodh_keystone_user }}
project_name = service
project_domain_id = default
user_domain_id = default
auth_type = password
```

2.修改_**wsgi-aodh.conf.j2**_

```
$ vim wsgi-aodh.conf.j2
{% set python_path = '/usr/lib/python2.7/site-packages' if kolla_install_type == 'binary' else '/var/lib/kolla/venv/lib/python2.7/site-packages' %}
Listen {{ api_interface_address }}:{{ aodh_api_port }}

<VirtualHost *:{{ aodh_api_port }}>

  ## Vhost docroot
  DocumentRoot "/var/www/cgi-bin/aodh"

  ## Directories, there should at least be a declaration for /var/www/cgi-bin/aodh

  <Directory "/var/www/cgi-bin/aodh">
    Options Indexes FollowSymLinks MultiViews
    AllowOverride None
    Require all granted
  </Directory>

  ## Logging
  ErrorLog "/var/log/kolla/aodh/aodh_wsgi_error.log"
  ServerSignature Off
  CustomLog "/var/log/kolla/aodh/aodh_wsgi_access.log" combined
  WSGIApplicationGroup %{GLOBAL}
  WSGIDaemonProcess aodh group=aodh processes={{ openstack_service_workers }} threads=1 user=aodh python-path={{ python_path }}
  WSGIProcessGroup aodh
  WSGIScriptAlias / "/var/www/cgi-bin/aodh/app.wsgi"
</VirtualHost>
```

### 1.3 修改 kolla-kubernetes，增加 aodh 资源生成文件
1.创建 aodh 资源文件：先创建 _**kolla-kuberntes/serivces/aodh**_ 目录

```
# aodh-bootstrap-job-create-db.yml.j2
$ vim aodh-bootstrap-job-create-db.yml.j2
{%- set podTypeBootstrap = "yes" %}
{%- set resourceName = kolla_kubernetes.cli.args.resource_name %}
{%- import "services/common/common-lib.yml.j2" as lib with context %}
apiVersion: batch/v1
kind: Job
metadata:
  name: aodh-create-db
  namespace: {{ kolla_kubernetes_namespace }}
spec:
  parallelism: 1
  completions: 1
  template:
    spec:
      restartPolicy: OnFailure
      nodeSelector:
        {%- set selector = kolla_kubernetes_hostlabel_controller %}
        {{ selector.key }}: {{ selector.value }}
      containers:
      - image: "{{ kolla_toolbox_image_full }}"
        name: creating-aodh-database
        command: ["sh", "-c"]
        args:
        - ansible localhost -m mysql_db -a
          "login_host='{{ kolla_internal_vip_address }}'
           login_port='{{ mariadb_port }}'
           login_user='{{ database_user }}'
           login_password='$DATABASE_PASSWORD'
           name='{{ aodh_database_name }}'"
        volumeMounts:
          {{ lib.common_volume_mounts(indent=12) }}
        env:
        - name: ANSIBLE_NOCOLOR
          value: "1"
        - name: ANSIBLE_LIBRARY
          value: "/usr/share/ansible"
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-password
              key: password
      - image: "{{ kolla_toolbox_image_full }}"
        name: creating-aodh-user-and-permissions
        command: ["sh", "-c"]
        args:
        - ansible localhost -m mysql_user -a
          "login_host='{{ kolla_internal_vip_address }}'
           login_port='{{ mariadb_port }}'
           login_user='{{ database_user }}'
           login_password='$DATABASE_PASSWORD'
           name='{{ aodh_database_name }}'
           password='$AODH_DATABASE_PASSWORD'
           host='%'
           priv='{{ aodh_database_name }}.*:ALL'
           append_privs='yes'"
        volumeMounts:
          {{ lib.common_volume_mounts(indent=12) }}
        env:
        - name: ANSIBLE_NOCOLOR
          value: "1"
        - name: ANSIBLE_LIBRARY
          value: "/usr/share/ansible"
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database-password
              key: password
        - name: AODH_DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: aodh-database-password
              key: password
      volumes:
        {{ lib.common_volumes(indent=8) }}

# aodh-bootstrap-job-manage-db.yml.j2
$ vim aodh-bootstrap-job-manage-db.yml.j2
{%- set podTypeBootstrap = "yes" %}
{%- set resourceName = kolla_kubernetes.cli.args.resource_name %}
{%- import "services/common/common-lib.yml.j2" as lib with context %}
apiVersion: batch/v1
kind: Job
metadata:
  name: aodh-manage-db
  namespace: {{ kolla_kubernetes_namespace }}
spec:
  parallelism: 1
  completions: 1
  template:
    spec:
      restartPolicy: OnFailure
      nodeSelector:
        {%- set selector = kolla_kubernetes_hostlabel_controller %}
        {{ selector.key }}: {{ selector.value }}
      containers:
      - image: "{{ aodh_api_image_full }}"
        name: main
        env:
        - name: KOLLA_BOOTSTRAP
          value: ""
        - name: KOLLA_CONFIG_STRATEGY
          value: "{{ config_strategy }}"
        volumeMounts:
{{ lib.common_volume_mounts(indent=12) }}
            - mountPath: {{ container_config_directory }}
              name: aodh-api-config
              readOnly: true
            - mountPath: /var/lib/glance/
              name: aodh-persistent-storage
      volumes:
{{ lib.common_volumes(indent=8) }}
        - name: aodh-api-config
          configMap:
            name: aodh-api
        - name: aodh-persistent-storage
          hostPath:
            path: /var/lib/kolla/volumes/aodh

# aodh-common-pod.yml.j2
$ vim aodh-common-pod.yml.j2
{%- set resourceName = kolla_kubernetes.cli.args.resource_name %}
{%- set replicas = global[kolla_kubernetes.template.vars.replicas] %}
{%- set serviceType = kolla_kubernetes.template.vars.service_type %}
{%- set selector = global[kolla_kubernetes.template.vars.selector_name] |
                       default(kolla_kubernetes_hostlabel_master_vip) |
                       default(kolla_kubernetes_hostlabel_controller)
%}
{%- set image = global[kolla_kubernetes.template.vars.image] %}
{%- import "services/common/common-lib.yml.j2" as lib with context %}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
   name: {{ resourceName }}
   namespace: {{ kolla_kubernetes_namespace }}
spec:
  replicas: {{ replicas }}
  template:
    metadata:
      labels:
        service: aodh
        type: {{ serviceType }}
    spec:
      nodeSelector:
          {{ selector.key }}: {{ selector.value }}
      restartPolicy: Always
      containers:
      - name: main
        image: "{{ image }}"
        volumeMounts:
{{ lib.common_volume_mounts(indent=12) }}
            - mountPath: /var/lib/kolla-kubernetes/event
              name: kolla-kubernetes-events
            - mountPath: {{ container_config_directory }}
              name: service-configmap
            {%- if resourceName == 'aodh-api' %}
            - mountPath: /var/lib/aodh/
              name: aodh-persistent-storage
            {%- endif %}
        env:
        - name: KOLLA_CONFIG_STRATEGY
          value: {{ config_strategy }}
{{ lib.common_containers(indent=8) }}
      volumes:
{{ lib.common_volumes(indent=8) }}
        - name: kolla-kubernetes-events
          emptyDir: {}
        - name: service-configmap
          configMap:
            name: {{ resourceName }}
        - name: aodh-persistent-storage
          hostPath:
            path: /var/lib/kolla/volumes/aodh
```

2.修改 _**kolla-kubernetes.yml**_

```
$ vim kolla-kubernetes.yml
########################
# Aodh variables
########################
aodh_notifier_replicas: "1"
aodh_listener_replicas: "1"
aodh_evaluator_replicas: "1"
aodh_api_replicas: "1"

aodh_admin_endpoint: http://aodh-api:{{ aodh_api_port }}
aodh_internal_endpoint: http://aodh-api:{{ aodh_api_port }}
aodh_public_endpoint: http://{{ kolla_kubernetes_external_vip }}:{{ aodh_api_port }}
openstack_aodh_auth: '{''auth_url'':''{{ keystone_auth_url }}'',''username'':''{{
  openstack_auth.username }}'',''password'':''$KEYSTONE_ADMIN_PASSWORD'',''project_name'':''{{
  openstack_auth.project_name }}'',''domain_name'':''default''}'
```

3.修改 _**service\_resources.yml**_

```
$ vim service_resources.yml
  - name: aodh
    pods:
    - name: aodh
      containers:
      - name: aodh-api
      - name: aodh-evaluator
      - name: aodh-listener
      - name: aodh-notifier
    resources:
      configmap:
      - name: aodh-api
      - name: aodh-api-logging
        template: services/common/logging-configmap.yml.j2
        vars:
          configmap_name: aodh-api-logging
          log_format: 'openstack'
      - name: aodh-evaluator
      - name: aodh-evaluator-logging
        template: services/common/logging-configmap.yml.j2
        vars:
          configmap_name: aodh-evaluator-logging
          log_format: 'openstack'
      - name: aodh-listener
      - name: aodh-listener-logging
        template: services/common/logging-configmap.yml.j2
        vars:
          configmap_name: aodh-listener-logging
          log_format: 'openstack'
      - name: aodh-notifier
      - name: aodh-notifier-logging
        template: services/common/logging-configmap.yml.j2
        vars:
          configmap_name: aodh-notifier-logging
          log_format: 'openstack'
      secret:
      disk:
      pv:
      pvc:
      svc:
      - name: aodh-api
        template: services/common/generic-service.yml.j2
        vars:
          port_name: aodh_api_port
          service: aodh
          type: api
          name: aodh-api
      bootstrap:
      - name: aodh-create-db
        template: services/aodh/aodh-bootstrap-job-create-db.yml.j2
      - name: aodh-manage-db
        template: services/aodh/aodh-bootstrap-job-manage-db.yml.j2
      - name: aodh-create-keystone-endpoint-public
        template: services/common/common-create-keystone-endpoint.yml.j2
        vars:
          service_name: aodh
          service_type: alarming
          interface: public
          service_auth: openstack_aodh_auth
          description: OpenStack Alarming Service
          endpoint: aodh_public_endpoint
      - name: aodh-create-keystone-endpoint-internal
        template: services/common/common-create-keystone-endpoint.yml.j2
        vars:
          service_name: aodh
          service_type: alarming
          interface: internal
          service_auth: openstack_aodh_auth
          description: OpenStack Alarming Service
          endpoint: aodh_internal_endpoint
      - name: aodh-create-keystone-endpoint-admin
        template: services/common/common-create-keystone-endpoint.yml.j2
        vars:
          service_name: aodh
          service_type: alarming
          interface: admin
          service_auth: openstack_aodh_auth
          description: OpenStack Alarming Service
          endpoint: aodh_admin_endpoint
      - name: aodh-create-keystone-user
        template: services/common/common-create-keystone-user.yml.j2
        vars:
          user: aodh
          role: admin
          service_auth: openstack_aodh_auth
          secret: aodh-keystone-password
      pod:
      - name: aodh-api
        template: services/aodh/aodh-common-pod.yml.j2
        vars:
          replicas: aodh_api_replicas
          service_type: api
          selector_name: kolla_kubernetes_hostlabel_aodh_api
          image: aodh_api_image_full
      - name: aodh-evaluator
        template: services/aodh/aodh-common-pod.yml.j2
        vars:
          replicas: aodh_evaluator_replicas
          service_type: evaluator
          selector_name: kolla_kubernetes_hostlabel_aodh_evaluator
          image: aodh_evaluator_image_full
      - name: aodh-listener
        template: services/aodh/aodh-common-pod.yml.j2
        vars:
          replicas: aodh_listener_replicas
          service_type: listener
          selector_name: kolla_kubernetes_hostlabel_aodh_listener
          image: aodh_listener_image_full
      - name: aodh-notifier
        template: services/aodh/aodh-common-pod.yml.j2
        vars:
          replicas: aodh_notifier_replicas
          service_type: notifier
          selector_name: kolla_kubernetes_hostlabel_aodh_notifier
          image: aodh_notifier_image_full
```

## 二、部署
按照如下命令依次创建 aodh 资源：

```
$ kolla-kubernetes resource create configmap aodh-api
$ kolla-kubernetes resource create configmap aodh-api-logging
$ kolla-kubernetes resource create configmap aodh-evaluator
$ kolla-kubernetes resource create configmap aodh-evaluator-logging
$ kolla-kubernetes resource create configmap aodh-listener
$ kolla-kubernetes resource create configmap aodh-listener-logging
$ kolla-kubernetes resource create configmap aodh-notifier
$ kolla-kubernetes resource create configmap aodh-notifier-logging

$ kolla-kubernetes resource create svc aodh-api

$ kolla-kubernetes resource create bootstrap aodh-create-db
$ kolla-kubernetes resource create bootstrap aodh-manage-db

$ kolla-kubernetes resource create bootstrap aodh-create-keystone-endpoint-public
$ kolla-kubernetes resource create bootstrap aodh-create-keystone-endpoint-internal
$ kolla-kubernetes resource create bootstrap aodh-create-keystone-endpoint-admin

$ kolla-kubernetes resource create pod aodh-api
$ kolla-kubernetes resource create pod aodh-evaluator
$ kolla-kubernetes resource create pod aodh-listener
$ kolla-kubernetes resource create pod aodh-notifier
```

查看 aodh pod 运行情况：

```
$ k8s get po | grep aodh
aodh-api-859322990-qgq5u                   1/1       Running   0          1h
aodh-evaluator-1751194127-1x6fm            1/1       Running   0          1h
aodh-listener-357046472-shot2              1/1       Running   0          1h
aodh-notifier-4147386550-toyfz             1/1       Running   0          1h
```

> 注：此处 k8s 命令是对 kubectl 命令的一个别名

验证是否正常运行：方法如上 1.1

> 注：查看 ceilometer 日志也可以看到输出 WARNING ceilometer.api.controllers.v2.root \[-\] ceilometer-api started with aodh enabled. Alarms URLs will be redirected to aodh endpoint. 表明 ceilometer 告警 api 已经重定向到 aodh 了

## 三、FAQ
### 1.创建 aodh 的 endpoint 失败
场景：创建 public  endpoint 时失败，该资源对应的 pod 日志显示无法找到合适的 auth\_url
原因：未修改 **kolla-kubernetes.yml**，添加 _aodh\_xxx\_endpoint _和 _openstack\_aodh\_auth _值，导致读取不到数据

注：job 如下的日志输出是正确的，并不是错误

```
"module_args": {
    "api_timeout": null,
    # 此处的 auth 部分输出是对的，不是错误！
    "auth": {
        "auth_url": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER",
        "domain_name": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER",
        "password": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER",
        "project_name": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER",
        "username": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER"
    },
    "auth_type": null,
    "availability_zone": null,
    "cacert": null,
    "cert": null,
    "cloud": null,
    "endpoint_type": "public",
    "key": null,
    "region_name": "RegionOne",
    "timeout": 180,
    "verify": true,
    "wait": true
},
```

解决：加入需要的值

### 2.部署完毕后，ceilometer 命令\(如 _ceilometer meter-list_\) 不可以，报 503 错误
场景：部署完毕后，ceilometer 命令不可用，报错 503 服务不可用

原因：查看 aodh 日志文件 _**app.wsgi.log**_** **发现报错_CRITICAL keystonemiddleware.auth\_token \[-\] Unable to validate token: Identity server rejected authorization necessary to fetch token data_ .可知虽然 pod 运行正常，但无法通过 keystone 验证。**查看 openstack user list --long 发现，aodh 用户未加入到 service 这个 project 中，从而导致验证失败**。

解决：重新创建 aodh 用户，并加入到 service project 中。

```
# 创建 aodh 用户
$ openstack user create --project service --project-domain Default --password AODH_KEYSTONE_PASS aodh
$ openstack user list --long

# 将用户 aodh 加入到 service 项目的 admin 角色中
openstack role add  --project service --user aodh admin
```

### 3.创建资源 aodh-create-db 失败

场景：修复 bug2 的过程中，删除 aodh 的所有资源，已经 mariadb 中 aodh 数据库，aodh 角色后，执行 aodh-create-db job 失败

解决：进入 mariadb 中手动添加用户和赋权

```
$ insert into user(Host, User, Password) values("%", "aodh", "AODH_DB_PASSWD");
$ grant all privileges on aodh.* to 'aodh'@'%' identified by 'AODH_DB_PASSWD';
```

注：上述 2 行命令对应该 job 在 kolla\_toolbox 中执行的命令如下所示

```
$ ansible localhost -m mysql_user
     -a "login_host='172.100.0.101'
         login_port='3306'
         login_user='root'
         login_password='DB_PASSWD'
         name='aodh'
         password='AODH_DB_PASSWD' host='%' priv='aodh.*:ALL' append_privs='yes'"
```

### 4.创建 aodh-api pod 失败

场景：创建 aodh-api pod 时失败，查看日志报错：_Cannot assign requested address: AH00072: make\_sock: could not bind to address20.0.24.58:8042_

原因：wsgi-aodh.conf.j2 修改错误

\[错误\]

```
$ vim wsgi-aodh.conf.j2
Listen aodh-api:{{ aodh_api_port }}
```

这样修改后，监听的 ip 为 20.0.24.58:8042。通过 dns 解析域名 aodh-api 后的 ip 为20.0.24.58，而该 ip 是内网ip\(集群ip\)，在协议栈中\(即利用 ip a 的显示\)是看不到的，因此失败。

```
$ k8s get svc
NAME       CLUSTER-IP   EXTERNAL-IP     PORT(S)    AGE
aodh-api   20.0.24.58   10.158.113.40   8042/TCP   3h
```

解决：修改监听地址

```
$ vim wsgi-aodh.conf.j2
Listen {% api_interface_address %}:{{ aodh_api_port }}
```

这样在 k8s 环境下，解析为 0.0.0.0:8042

```
$ k8s get configmap aodh-api -o yaml
apiVersion: v1
data:
...
  wsgi-aodh.conf: |
    Listen 0.0.0.0:8042
```