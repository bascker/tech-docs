# Kolla-Ansible 下 Ceilometer 部署
## register.yml
\(a\) Creating the Ceilometer service and endpoint：创建服务和访问点
```
$ openstack service list
+----------------------------------+-------------+----------------+
| ID                               | Name        | Type           |
+----------------------------------+-------------+----------------+
| 58973b64840b4449b7a666330f64fbda | ceilometer  | metering       |
+----------------------------------+-------------+----------------+


$ openstack endpoint list
+----------------------------------+-----------+--------------+----------------+---------+-----------+-----------------------------------------------+
| ID                               | Region    | Service Name | Service Type   | Enabled | Interface | URL                                           |
+----------------------------------+-----------+--------------+----------------+---------+-----------+-----------------------------------------------+
| 055a109911b84dbe956b4994031e58a4 | RegionOne | ceilometer   | metering       | True    | internal  | http://10.158.113.158:8777                    |
| 275b95c3cbfb40f6abbeaea0ff273160 | RegionOne | ceilometer   | metering       | True    | public    | http://10.158.113.158:8777                    |
| e84485cc723443f9aa271180cd313e4e | RegionOne | ceilometer   | metering       | True    | admin     | http://10.158.113.158:8777                    |
+----------------------------------+-----------+--------------+----------------+---------+-----------+-----------------------------------------------+
```

\(b\) Creating the Ceilometer project, user, and role：创建 ceilometer 用户和角色添加
```
$ openstack user create --project service \
                        --project-domain Default \
                        --password hj6XR0ejZSgjj7SWNiYlZf3OKk1ZKEeRMzyE0wB6 \
                        ceilometer

$ openstack user list
+----------------------------------+------------+
| ID                               | Name       |
+----------------------------------+------------+
| 0d04f348df5244e7bd58f0abac465d83 | ceilometer |
+----------------------------------+------------+

# 将用户 ceilometer 加入到 admin 角色和 service 项目中
$ openstack role add  --project service --user ceilometer admin
$ openstack role list
$ openstack user list --project service
+----------------------------------+-------------+
| ID                               | Name        |
+----------------------------------+-------------+
| e0037b609d704bf98b22e35c374ec55c | ceilometer  |
+----------------------------------+-------------+
```

## config.yml
\(a\) Ensuring config directories exist
```
$ mkdir -p /etc/kolla/ceilometer-notification \
           /etc/kolla/ceilometer-collector \
           /etc/kolla/ceilometer-api \
           /etc/kolla/ceilometer-central \
           /etc/kolla/ceilometer-compute
```

\(b\) Copying over config.json files for services：解析 j2 文件，拷贝到各目录

\(c\) Copying over ceilometer-api.conf
```
$ template/wsgi-ceilometer-api.conf.j2 --> /etc/kolla/ceilometer/wsgi-ceilometer-api.conf
```

\(d\) Copying over ceilometer.conf

\(e\) Copying over event and pipeline yaml for notification service

\(f\) Check if policies shall be overwritten

\(g\) Copying over existing policy.json

### 3.bootstrap.yml
\(a\) Checking Ceilometer mysql database：此处本人设置为 mysql
```
$ vim /etc/kolla/globals.yml
ceilometer_database_type == "mysql"
```

\(b\) Creating Ceilometer mysql database
```
$ show databases;
+--------------------+
| Database           |
+--------------------+
| ceilometer         |
+--------------------+

$ show tables;
+----------------------+
| Tables_in_ceilometer |
+----------------------+
| event                |
| event_type           |
| metadata_bool        |
| metadata_float       |
| metadata_int         |
| metadata_text        |
| meter                |
| migrate_version      |
| resource             |
| sample               |
| trait_datetime       |
| trait_float          |
| trait_int            |
| trait_text           |
+----------------------+
14 rows in set (0.00 sec)
```

\(c\) Creating Ceilometer database user and setting permissions：创建数据库用户和设置权限
```
> use mysql;
> select * from user;
| %          | ceilometer | *C1675B3C1A9C7E9974B9A2F7FCD0EB49A8AF00CA | N  .....
```

\(d\) Running Ceilometer bootstrap container  --&gt; bootstrap\_service.yml

挑选第一个 controller 做初始化： delegate\_to: "{{ groups\['ceilometer-api'\]\[0\] }}"
```
$ docker run \
		 -d \
		 --name bootstrap_ceilometer \
		 -e "KOLLA_CONFIG_STRATEGY=COPY_ALWAYS" \
		 -e "CEILOMETER_DATABASE_TYPE=mysql" \
		 -v /etc/kolla/ceilometer-api/:/var/lib/kolla/config_files/:ro \
		 -v /etc/localtime:/etc/localtime:ro \
		 -v ceilometer:/var/lib/ceilometer/ \
		 -v kolla_logs:/var/log/kolla/ \
		 registry:5000/kolla/centos-binary-ceilometer-api:3.0.0

```

### 4.start.yml
(a) Starting ceilometer-notification container
(b) Starting ceilometer-api container
(c) Starting ceilometer-central container
(d) Starting ceilometer-collector container
(e) Starting ceilometer-compute container