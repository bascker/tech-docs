# HashMap
## 一、简介
为什么会推出HashMap？**为了提高性能**。从数据结构的顺序结构的观点来看，常规的线性存储，若想找到其中的某元素，就需要遍历这个链表或者数组，
而遍历的同时需要让链表中的每一个元素都和目标元素做比较，相等才返回，Java 里面用 `equals` 或者 `==` 来比较，这情况对性能是毁灭性的伤害。

## HashMap 和 HashTable 的区别
| **特征** | **HashMap** | **HashTable** | **TreeMap** |
| :--- | :--- | :--- | :--- |
| 实现原理 | 哈希表：数组 + 链表 | 哈希表 | 红黑树 |
| 线程安全 | 不安全 | 安全 | 不安全 |
| 键值排序 | 无序 | 无序 | 根据键值排序，默认升序 |
| 效率 | 高 | 低 | 比HashMap慢 |
| 允许 null | 允许 null 值作为 key 或 value | 不允许 |  |
| 父类 | 继承**AbstractMap**, 实现 Map<K,V>接口 | 继承 **Dictionary**，实现Map<K,V> |  |
| 使用场景 | 非线程安全场景下，在Map中插入、删除、定位元素 | 一般不用 | 需要键值根据自然顺序或自定义顺序**排序场景** |

HashMap存储 null 键值对
```
public static void main(String[] args) {
    HashMap<String, String> map = new HashMap<String, String>();
    map.put(null, null);
    System.out.println(map.get(null));
}

# 程序输出
null
```