# ThreadLocal
## 一、简介
又名本地线程变量和线程本地存储，多线程环境下，对于共享资源 x，若使用 ThreadLocal，它会为每个 Thread 创建一个 x 的副本，因此
每个线程都可以利用 ThreadLocal 提供的 get()、set()等方法来独立操作该副本变量，而不影响其他线程所对应的副本。从线程的角度来看，
它就像是线程的本地变量。

有关 ThreadLocal 的注意点：
* ThreadLocal不是用来解决对象共享访问问题的，而主要是提供了保持对象的方法和避免参数传递的一种方便的对象访问方式
* ThreadLocal不是线程，是线程的一个变量
* 每个线程有自己的一个ThreadLocal，它是变量的一个‘拷贝’，修改它不影响其他线程
* 在进行get之前，必须先set，否则会报空指针异常.如果想在get之前不需要调用set就能正常访问的话，必须重写initialValue()方法
* 在当前线程中，如果要使用副本变量 T value，就可以通过get方法在threadLocals里面查找
* 每个线程中可有多个threadLocal变量

## 二、类方法
ThreadLocal 只有 4 个方法
1. `get()`: 获得当前线程所对应的线程局部变量的值。
2. `set(T value)`: 设置当前线程的线程局部变量的值
3. `remove()`: 删除当前线程中线程局部变量的值
4. `initialValue()`：返回此线程局部变量的当前线程的“初始值”。

## 三、ThreadLocal是如何为每个线程创建变量的副本的？
在 Thread 中有一个 `ThreadLocal.ThreadLocalMap`类型的变量 `threadLocals`，用来存储实际的变量副本。其 key 为当前 ThreadLocal 变量，value 为变量副本。
初始时 threadLocals 为空，当通过 ThreadLocal 实例调用 get() 方法或 set() 方法，就会对 Thread 类中的 threadLocals 进行初始化，并且以当前 ThreadLocal
变量为键值，以 ThreadLocal 要保存的副本变量为 value，存到 threadLocals.
> 实际通过 ThreadLocal 创建的副本是存储在每个线程自己的 threadLocals 中的