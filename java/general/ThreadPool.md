# 线程池
## 一、简介
事先创建若干个可执行的线程放入一个池中，需要的时候从池中获取线程不用自行创建，使用完毕不需要销毁线程而是放回池中，从而减少创建和销毁线程对象的开销。
用于系统中执行线程的数量，提高系统性能。线程池的使用可以带来以下好处：
* 减少线程创建和销毁的次数：每个工作线程可以被重复利用
* 可根据系统承受能力，调整线程池的大小：避免内存不足，致使服务器宕机

## 二、种类
Java里面线程池的顶级接口是Executor，但是严格意义上讲Executor并不是一个线程池，而只是一个执行线程的工具。真正的线程池接口是ExecutorService。

| **类/接口** | **描述** |
| --- | --- |
| ExecutorService | 真正的线程池接口 |
| ScheduledExecutorService | 和Timer/TimerTask类似，解决需要重复执行某任务的问题 |
| ThreadPoolExecutor | ExecutorService的默认实现 |
| ScheduledThreadPoolExecutor | 继承ThreadPoolExecutor的ScheduledExecutorService接口实现，周期性任务调度的类实现 |

## 三、组成
一个线程池有 4个基本组成部分
* **ThreadPoolManager**：线程池管理器，用于创建并管理线程池(创建/销毁线程，添加任务等)
* **PollWorker**：工作线程，线程池中的线程
* **Task**：任务接口，每个任务必须实现的接口，以供工作线程调度任务的执行，它主要规定了任务的入口，任务执行完后的收尾工作，任务的执行状态等
* **TaskQueue**：任务队列，用于存放没有处理的任务，提供一种缓冲机制

## 四、案例
Java通过 Executors 提供4种线程池。

| **特征** | **cachedThreadPool** | **fixedThreadPool** | **scheduledXXX** | **singleThreadPool** |
| --- | --- | --- | --- | --- |
| **描述** |  |  |  |  |
| **线程池对象** | ThreadPoolExecutor | ThreadPoolExecutor | ScheduledThreadPool |  |
| **定长** | 否 | 是 | 是 |  |
| **队列** | SynchronousQueue | LinkedBlockingQueue |  |  |

### 4.1 Executors.newCachedThreadPool
创建一个可缓存的线程池，若线程池长度超过处理需要，则可以灵活回收空闲线程。若无可回收线程，且不够处理所需，则新建线程
```
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class Main {

    public static void main(String[] args) {
        // 创建一个 cachedThreadPool：线程池大小为无限大
        ExecutorService cachedThreadPool = Executors.newCachedThreadPool();

        for (int i = 0; i < 10; i ++) {
            final int index = i;
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            // 线程池执行任务
            cachedThreadPool.execute(new Runnable() {

                @Override
                public void run() {
                    System.out.println(Thread.currentThread() + "：" + index);
                }

            });
        }
    }

}

### 输出
Thread[pool-1-thread-1,5,main]：0
Thread[pool-1-thread-1,5,main]：1
Thread[pool-1-thread-1,5,main]：2
Thread[pool-1-thread-1,5,main]：3
Thread[pool-1-thread-1,5,main]：4
```
当前执行任务的线程名都为 `Thread[pool-1-thread-1,5,main]`，原因是当执行第二个任务时第一个任务已经完成，因此会复用执行第一个任务的线程，而不用每次新建线程。

利用 Executors 创建线程池，实际上是新建了一个 ThreadPoolExecutor() 对象。
```
public static ExecutorService newCachedThreadPool() {
    return new ThreadPoolExecutor(0, Integer.MAXVALUE,
                                  60L, TimeUnit.SECONDS,
                                  new SynchronousQueue<Runnable>());
}
```

### 4.2 Executors.newFixedThreadPool
创建一个定长的线程池，可以用来控制最大并发数，超出的线程会在同步队列中等待，以此来减轻服务器压力。
```
public static void main(String[] args) {
    // 创建一个长度为 3 的线程池
    ExecutorService fixedThreadPoll = Executors.newFixedThreadPool(3);

    for (int i = 0; i < 5; i ++) {
        final int index = i;
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        // 执行任务
        fixedThreadPoll.execute(new Runnable() {

            @Override
            public void run() {
                System.out.println(Thread.currentThread() + "：" + index);
            }

        });
    }

    fixedThreadPoll.shutdown();
}

### 输出
Thread[pool-1-thread-1,5,main]：0
Thread[pool-1-thread-2,5,main]：1
Thread[pool-1-thread-3,5,main]：2
Thread[pool-1-thread-1,5,main]：3
Thread[pool-1-thread-2,5,main]：4
```
可以看到与 cachedThreadPool 不同，fixedThreadPool 没有复用之前的线程，而且保持最大线程数为 3

### 4.3 Executors.newScheduledThreadPool
创建定长线程池，可以设置定时执行任务以及周期性执行任务。

#### 4.3.1 定时执行
```
public static void main(String[] args) {
    // 创建一个长度为 3 的线程池
    ScheduledExecutorService scheduledThreadPool = Executors.newScheduledThreadPool(3);

    // 执行任务
    scheduledThreadPool.schedule(new Runnable() {

        @Override
        public void run() {
            System.out.println("延迟 1 秒后执行");
            System.out.println(Thread.currentThread());
        }
    }, 1, TimeUnit.SECONDS);

    // 执行完毕
    scheduledThreadPool.shutdown();
}

### 输出
延迟 1 秒后执行
Thread[pool-1-thread-1,5,main]
```

#### 4.3.2 周期性执行
```
public static void main(String[] args) {
    // 创建一个长度为 3 的线程池
    ScheduledExecutorService scheduledThreadPool = Executors.newScheduledThreadPool(3);

    // 执行任务
    scheduledThreadPool.scheduleAtFixedRate(new Runnable() {

        @Override
        public void run() {
            System.out.println("延迟 1 秒后执行，每 3 秒执行一次");
            System.out.println(Thread.currentThread() + "：" + new Date().getSeconds());
        }
    }, 1, 3, TimeUnit.SECONDS);
}

### 输出
延迟 1 秒后执行，每 3 秒执行一次
Thread[pool-1-thread-1,5,main]：39
延迟 1 秒后执行，每 3 秒执行一次
Thread[pool-1-thread-1,5,main]：42
延迟 1 秒后执行，每 3 秒执行一次
Thread[pool-1-thread-2,5,main]：45
...
```

其实际上是创建了一个 ScheduledThreadPoolExecutor 对象
```
public static ScheduledExecutorService newScheduledThreadPool(int corePoolSize) {
    return new ScheduledThreadPoolExecutor(corePoolSize);
}
```

### 4.4 Executors.newSingleThreadPool
创建一个单线程化的线程池，只会用唯一的工作线程执行任务，保证所有任务按照指定顺序执行。
```
public static void main(String[] args) {
    // 创建一个长度为 3 的线程池
    ExecutorService singleThreadExecutor = Executors.newSingleThreadExecutor();
    singleThreadExecutor.execute(new Runnable() {

        @Override
        public void run() {
            System.out.println(Thread.currentThread());
        }
    });
    singleThreadExecutor.shutdown();
}

### 输出
Thread[pool-1-thread-1,5,main]
```