# JVM 参数
## 配置
```
java -Xmx1g -Xms512m -Xmn100m -Xss128k -XX:SurvivorRatio=3
```
参数解释：
* -Xmx：最大可用堆内存
* -Xms：最小可用堆内存
* -Xmn：年轻代大小
* -Xss：每个线程堆栈大小
* -XX:SurvivorRatio：年轻代中Eden区与2个Survivor区大小比例
  ```
  SurvivorRatio=3 => Eden:Survivor = 3:2
  即一个 survivor 占整个年轻代的 1/5
  ```
* -XX:NewSize：设置年轻代大小
* -XX:NewRatio：设置年轻代与年老代的比值。