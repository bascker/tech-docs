# FAQ
## 1、Mysql 中分页的实现，以及 limit 10000,10 中，会不会从前面读入然后再返回后10条记录？
以 `select * from user order by id desc limit 10000,10`为例进行分析：
1. 扫描满足条件的 10010 条记录
2. 扔掉前面的 10000 条记录
3. 返回最后的 10 条记录
因此，使用 mysql 的分页时，需要优化效率。**分页优化原理**：记录住当前页 id 的最大值和最小值，计算跳转页面和当前页相对偏移。传统的 limit m,n，相对的偏移一直
是第1页，我们需要尽量的减小 m 也就是偏移量 offset 的值。因为 **offset 越高，效率越低**

根据原理，我们若是要获取 10000 后面的 10 条记录，优化后的语句应该如下
```
$ select * from user where id > 10000 order by id asc limit 0, 10

# 或者
$ SELECT * FROM user where id > 10000 ORDER BY id ASC LIMIT 10 OFFSET 0;
```
这样，就会过滤掉前面的 10000 行记录，获取后 10 条记录