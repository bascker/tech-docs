# curl
## 简介

* 用于获取网络文件或信息
* 选项
  * -o：指定文件保存位置
  * -O：使用URL中默认的文件名保存文件到本地
  * -C：断点续传
  * -X：指定哪种命令(PUT,GET,DELETE,HEAD等)
  * -s：静音模式，不输出标准错误内容
  * -v：verbose 信息
  * -i：输出响应头
  * -k：用于https认证
  * --connect-timeout: 连接超时时间
* 配置文件：**.curlrc**

## 案例
1.获取响应头
```
$ curl -i http://10.158.113.158:9200/_cat/indices?v
HTTP/1.1 200 OK
Content-Type: text/plain; charset=UTF-8
Content-Length: 1395

health status index               pri rep docs.count docs.deleted store.size pri.store.size
yellow open   log-2017.01.10        5   1      24552            0      7.8mb          7.8mb
...
```

2.消除 curl 的标准错误信息：2种方法


```
# 带标准错误情况
$ curl -i http://10.158.113.158:9200/_cat/indices?v > aa
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1395  100  1395    0     0  18415      0 --:--:-- --:--:-- --:--:-- 18600


# 法1：使用 -s
$ curl -is http://10.158.113.158:9200/_cat/indices?v > aa

# 法2：重定向
$ curl -i http://10.158.113.158:9200/_cat/indices?v > aa 2>/dev/null
```

3.配置文件** .curlrc** 的使用：
```
$ cat .curlrc
# curl default options
--silent                  # -s 选项
--show-error              # 执行失败时显示错误信息
# 执行成功后显示信息
--write-out "curl (%{url_effective}): response: %{http_code}, time: %{time_total}, size: %{size_download}\n"

$ curl http://10.158.113.158:9200
{
  "name" : "10.158.113.155",
  "cluster_name" : "kolla_logging",
  "cluster_uuid" : "XHqtcQBkR361OOT7pjXBGA",
  "version" : {
    "number" : "2.4.1",
    "build_hash" : "c67dc32e24162035d18d6fe1e952c4cbcbe79d16",
    "build_timestamp" : "2016-09-27T18:57:55Z",
    "build_snapshot" : false,
    "lucene_version" : "5.5.2"
  },
  "tagline" : "You Know, for Search"
}
curl (http://10.158.113.158:9200/): response: 200, time: 0.002, size: 368
```