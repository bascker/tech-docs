# 集合
## ArrayList VS. LinkedList VS. Vector
| **特性** | **ArrayList** | **LinkedList** | **Vector** |
| :--- | :--- | :--- | :--- |
| 底层数据结构 | 数组 | 双向链表 | 数组 |
| 查询/索引速度 | 快 | 较慢 | 快(由于线程安全，性能比ArrayList低) |
| 插入速度 | 慢 | 快 | 慢 |
| 空间消耗 | 超过初始大小时，扩容50% |  | 超过初始大小时，扩容1倍 |
| 线程安全 | 不安全 | 不安全 | 安全 |
| 性能 | 最快 | 次快 | 慢 |

LinkedList 底层数据结构双向链表的验证
```
public static void main(String[] args) {
    final LinkedList<Integer> nums = new LinkedList<>();
    nums.add(1);
    nums.add(2);
    System.out.println(nums);                # [1, 2]

    # 链首插入数据
    nums.add(0, 3);
    nums.add(10);
    System.out.println(nums);                # [3, 1, 2, 10]
}
```


## ArrayBlockingQueue VS. LinkedBlockingQueue
| **特征** | **ArrayBlockingQueue** | **LinkedBlockingQueue** |
| :--- | :--- | :--- |
| **锁的实现** | 不分离锁，生产和消费使用同一个锁 | 分离锁，生产使用`putLock`，消费使用`takeLock` |
| **操作** | 生产和消费时，**直接**将枚举对象插入或**移除** | 生产和消费时，需把枚举对象转换为`Node<E>`进行插入或移除，会影响性能 |
| **队列初始化大小** | 必须指定队列的大小 | 可不指定队列的大小，默认是`Integer.MAX_VALUE` |