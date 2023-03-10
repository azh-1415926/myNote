# **Linux 系统编程笔记**
## **Linux 进程间通信**
**IPC方法**
Linux环境下，进程地址空间相互独立，每个进程各自有不同的用户地址空间。任何一个进程的全局变量在另一个进程中都看不到，所以进程和进程之间不能相互访问，要交换数据必须通过内核，在内核中开辟一块缓冲区，进程 1 把数据从用户空间拷到内核缓冲区，进程 2 再从内核缓冲区把数据读走，内核提供的这种机制称为进程间通信(IPC， InterProcess Communication)

在进程间完成数据传递需要借助操作系统提供特殊的方法，如:文件、管道、信号、共享内存、消息队列、套接字、命名管道等。随着计算机的蓬勃发展，一些方法由于自身设计缺陷被淘汰或者弃用。现今常用的进程间通信
方式有

* 管道(使用最简单)
* 信号(开销最小)
* 共享映射区(无血缘关系)

**管道**

管道的概念
管道是一种最基本的IPC机制，作用于有血缘关系的进程之间，完成数据传递。调用 pipe 系统函数即可创建一个管道

管道的特质

* 本质是一个伪文件(实为内核缓冲区)
* 由两个文件描述符引用， 一个表示读端，一个表示写端
* 规定数据从管道的写端流入管道，从读端流出

管道的原理:管道实为内核使用环形队列机制，借助内核缓冲区(4k)实现
管道的局限性:

* 数据不能进程自己写，自己读
* 管道中数据不可反复读取。一旦读走，管道中不再存在
* 采用半双工通信方式，数据只能在单方向上流动
* 只能在公共祖先的进程间使用管道

常见的通信方式有：单工通信、半双工通信、全双工通信

**pipe 函数**
用于创建管道

* 函数原型
  * `int pipe(int pipefd[2]);`

* 返回值
  * 成功 0
  * 失败 -1，设置errno

函数调用成功返回 r/w 两个文件描述符，无需 open，但需手动 close。规定: fd[0] →r，fd[1] →w，就像 0 对应标准输入，1 对应标准输出一样，向管道文件读写数据其实是在读写内核缓冲区

* 应用
  * 父进程调用 pipe 函数创建管道，得到两个文件描述符 fd[0]、fd[1] 指向管道的读端和写端
  * 父进程调用 fork 创建子进程，那么子进程也有两个文件描述符指向同一管道
  * 父进程关闭管道读端，子进程关闭管道写端。父进程可以向管道中写入数据，子进程将管道中的数据读出，由于管道是利用环形队列实现的，数据从写端流入管道，从读端流出，这样就实现了进程间通信

管道的读写行为
使用管道需要注意以下 4 种特殊情况(假设都是阻塞1/0操作，没有设置 O_NONBLOCK 标志) 

* 如果所有指向管道写端的文件描述符都关闭了( 管道写端引用计数为 0)，而仍然有进程从管道的读端遠数据，那么管道中剩余的数据都被读取后，再次 read 会返回 0，就像读到文件末尾一样
* 如果有指向管道写端的文件描述符没关闭(管道写端引用计数大于 0)，而持有管道写端的进程也没有向管道中写数据，这时有进程从管道读端读数据，那么管道中剩余的数据都被读取后，再次read会阻塞，直到管道中有数据可读了才读取数据并返回
* 如果所有指向管道读端的文件描述符都关闭了(管道读端引用计数为 0)，这时有进程向管道的写端 write，那么该进程会收到信号SIGPIPE，通常会导致进程异常终止。当然也可以对 SIGPIPE 信号实施捕捉，不终止进程
* 如果有指向管道读端的文件描述符没关闭(管道读端引用计数大于0)，而持有管道读端的进程也没有从管道中读数据，这时有进程向管道写端写数据，那么在管道被写满时再次write会阻塞，直到管道中有空位置了才写入数据并返回



1. 读管道
   * 管道中有数据，read 返回实际读到的字节数
   * 管道中无数据
     * 管道写端被全部关闭，read 返回0 (好像读到文件结尾)
     * 写端没有全部被关闭，read 阻塞等待(不久的将来可能有数据递达，此时会让出 cpu)
2. 写管道
   * 管道读端全部被关闭，进程异常终止(也可使用捕捉 SIGPIPE 信号，使进程不终止)
   * 管道读端没有全部关闭
     * 管道已满，write 阻塞
     * 管道未满，write 将数据写入，并返回实际写入的字节数

**管道缓冲区大小**

可以使用 `ulimit -a` 命令来查看当前系统中创建管道文件所对应的内核缓冲区大小

通常为:pipe size		(512 bytes, ~p) 8
也可以使用 fpathconf 函数，借助参数选项来查看，使用该宏应引入头文件<unistd.h>

* 函数原型
  * `long fpathconfit fd, int name);`
* 返回值
  * 成功，返回管道的大小
  * 失败，-1，设置errno

**管道的优劣**

* 优点
  * 简单，相比信号，套接字实现进程间通信，简单很多
* 缺点
  * 只能单向通信，双向通信需建立两个管道
  * 只能用于父子、兄弟进程(有共同祖先)间通信。该问题后来使用 fifo 有名管道解决

**FIFO**

FIFO 常被称为命名管道，以区分管道(pipe)。管道(pipe)只能用于“有血缘关系”的进程间，但通过FIFO，不相关的进程也能交换数据
FIFO是Linux基础文件类型中的一种。但，FIFO 文件在磁盘上没有数据块，仅仅用来标识内核中一条通道。各
进程可以打开这个文件进行read/write，实际上是在读写内核通道，这样就实现了进程间通信
创建方式

1. 命令创建
   * `mkfifo 管道名`
2. 调用库函数
   * 函数原型
     * `int mkfifo(const char *pathname，mode. t mode);`
   * 返回值
     * 成功 0
   * 失败 -1

一且使用 mkfifo创建了一个FIFO，就可以使用 open 打开它，常见的文件 I/O 函数，都可用于 fifo，如: close、read、write、unlink 等
