# 内存泄漏
## 一、简介
Java中内存泄漏就是存在一些被分配的对象，这些对象有下面两个特点：
* 对象**可达**：在有向图中，存在通路可以与其相连
* 对象**无用**：程序以后不会再使用这些对象

如果对象满足这两个条件，那么这些对象就可以判定为Java中的内存泄漏。简而言之，**若存在可达但无用的对象，这些对象不会被GC所回收却占用内存，就认为是内存泄漏。内存
泄漏，就是对内存利用不当，导致的内存浪费。**
> **内存泄漏 != 内存溢出**。内存溢出是异常 _OutOfMemoryError_，内存泄漏是对内存管理的失误，没有充分利用内存，不是异常。

## 二、案例
### 2.1 案例1
```
List<Object> li = new ArrayList<Object>();
for (int i = 0; i < 10; i ++) {
    Object obj = new Object();
    li.add(obj);
    obj = null;            // 释放强引用
}
```
对于上述代码，代码栈中存在 List 对象的引用 li 和 Object 对象的引用 obj。若在循环的过程中，当 obj 被置为 null 后发生了 GC，那么虽然 obj 对象的引用被释放(无用)，
但该对象依然被 li 所引用(可达)，此时 GC 是无法回收 obj 的内存空间的，从而发生内存泄漏。循环结束后，所有循环中生成的 Object 对象因为依旧被 li 所引用，无法回收，就
是内存泄漏。

### 2.2 案例2
```
 public class FileSearch{

    // 变量声明
    private byte[] content;
    private File file;

    // 构造函数
    public FileSearch(File file){
        this.file= file;
    }

    // 判断文件中是否包含某字符串
    public boolean hasString(String str){
        // 获取文件大小
        int size = getFileSize(file);
        // 存储文件内容到 content
        content = new byte[size];
        loadFile(file, content);

        // 判断是否包含
        String s = new String(content);
        return s.contains(str);
    }
}
```
对于上述代码，第一印象是写的很好啊，完全没问题，是这个理。错！这段代码也存在内存泄漏的问题！**其问题在于将 content 声明为了一个实例变量，而不是局部变量**。对于
整个业务流程(对文件内容进行比较，判断是否包含)，存储文本数据的**变量 content 仅仅在 hasString() 函数中有用，出了 hasString() 后，就没有价值了，是我们不需要
的数据。将其声明为实例变量，content 的生命周期就和 FileSearch 对象的实例绑定在一起了，造成了内存的浪费，这也是一种内存泄漏**。

解决这种内存泄漏的方法：将该变量 content 变成局部变量，在函数 hasString() 中声明，让其随 hasString() 共同生死。
