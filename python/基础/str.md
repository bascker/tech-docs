# 字符串
python 中表示字符串的类是 **str**。
```
>>> s = str('123');
>>> s
'123'
>>> s = str(123)                # 强转，整型转字符串
>>> s
'123'
```

字符串类型是**不可变**的，即被复制后不可改变。因其不可改变的特性，因此会**重新构造**一个新的字符串，然后将引用指向该新字符串对象。
```
>>> s = 'Hello'
>>> s = 'Hello' + 'world'
# 这里实际是使用 2 个字符串 'Hello' 和 'world' 重新构建了一个新的字符串 'Helloworld'
# 然后将 s 指向存储 'Helloworld' 的内存地址
```
![string重新赋值](asset/str.png)

允许使用`[]`来访问 `String`中的某个字符，和 Java 一样下标从 0 开始
```
>>> s = 'hi'
>>> print s[1]
i
```

字符串拼接：与Java不一样，Python 中`+`不会自动将数字类型数据转换为 str
```
>>> pi = 3.14
>>> s = "pi is " + pi
Traceback (most recent call last):
  File "<input>", line 1, in <module>
TypeError: cannot concatenate 'str' and 'float' objects
>>> s = "pi is " + str(pi)
>>> s
'pi is 3.14'
```