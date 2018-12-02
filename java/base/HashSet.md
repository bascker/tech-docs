# HashSet
## 一、简介
HashSet 实现了 Set 接口，不允许集合中有重复值。在使用 HashSet **存储对象时，一定要确保对象重写了 equals() 和 hashCode()**, 以此确保没有存储相等的对象。

## 二、为什么HashSet是基于HashMap的？
HashSet 底层使用了 HashMap 来实现，如存储数据、判断集合是否为空、添加对象等，都是使用 map 来提供支持的，因此HashSet 是基于 HashMap 的。
```
public class HashSet<E> extends AbstractSet<E> implements Set<E>, Cloneable, java.io.Serializable {

    private static final Object PRESENT = new Object();
    private transient HashMap<E,Object> map;

    /**
     * Constructs a new, empty set; the backing <tt>HashMap</tt> instance has
     * default initial capacity (16) and load factor (0.75).
     */
    public HashSet() {
        map = new HashMap<>();
    }

    // ...

    public Iterator<E> iterator() {
        return map.keySet().iterator();
    }

    public int size() {
        return map.size();
    }

    public boolean isEmpty() {
        return map.isEmpty();
    }

    public boolean add(E e) {
        return map.put(e, PRESENT)==null;
    }

    // ...

}
```
从 add() 方法源码可以看到，**HashSet** 存储时，**使用添加的对象 e 作为 map 的 key**，而 map 的 key 要求唯一性，因此 HashSet 添加的对象必须要确保唯一性，
即重写 `equals() + hashCode()`

### HashSet和 HashMap 的区别
| **特征** | **HashSet** | **HashMap** |
| :--- | :--- | :--- |
| **抽象接口** | Set 接口 | Map 接口 |
| **存储对象** | 只存储对象 | 存储<k, v>键值对 |
| **添加元素** | add() | put() |
| **hashCode计算** | 利用存储对象的hashCode() + equals() | 利用键对象来计算hashCode |
| **速度** | 较慢 | 快，利用key来快速定位定位对象 |
| **底层实现** | HashMap | 哈希表：数组 + 链表 |