# Linux 编程笔记

### 进程相关概念

**程序和进程**

程序，是指编译好的二进制文件，在磁盘上，不占用系统资源(CPU、内存、打开的文件、设备、锁...)

进程，是一个抽象的概念，与操作系统原理联系紧密。进程是活跃的程序，占用系统资源。在内存中执行(程序运行起来，产生一个进程)

**并发**

并发，在操作系统中，一个时间段有多个进程都处于已启动运行到运行完毕之间的状态，但在任一时刻点上仍只有一个进程在运行

**单道程序设计**

所有进程一个一个排队执行。若 A 阻塞，B 只能等待，即使 CPU 处于空闲状态。而在人机交互时阻塞的出现时必然的。所有这种模型在系统资源利用上及其不合理，在计算机发展历史上存在不久，大部分便被淘汰了

**多道程序设计**

在计算机内存中同时存放几道相互独立的程序。它们在管理程序控制之下，相互穿插的运行，多道程序设计必须要硬件基础作为保证

时钟中断即为多道程序设计模型的理论基础。并发时，任意进程在执行期间都不希望放弃 CPU。因此系统需要一种强制让进程让出 CPU 资源的手段。时钟中断有硬件基础作为保障，对进程而言不可抗拒。操作系统中的中断处理函数，来负责调度程序执行

在多道程序设计模型中，多个进程轮流使用 CPU(分时复用 CPU 资源)。而当下常见 CPU 为纳秒级， 1秒可以执行大约 10 亿条指令。由于人眼的反应速度是毫秒级，所以看似同时在进行

**CPU 和 MMU**

**进程控制块 PCB**

每个进程在内核中都有一个进程控制块(PCB)来维护进程相关的信息，Linux 内核的进程控制块是 task_struct 结构体

/usr/src/linux-headers-3.16.0-30/include/linux/sched.h 文件可以查看 struct task_struct 结构体定义

* 进程 id
  * 系统中每个进程有唯一的 id，在 C 语言中 pid_t 类型表示，其实就是一个非负整数
* 进程的状态
  * 有就绪、运行、挂起、停止等状态
* 进程切换时需要保存和恢复的一些 CPU 寄存器
* 描述虚拟地址空间的信息
* 描述控制终端的信息
* 当前工作目录
* umask 掩码
* 文件描述符表
* 和信号相关的信息
* 用户 id 和组 id

**进程状态**

进程基本的状态有 5 种，分别为初始态、就绪态、运行态、挂起态与终止态

**进程控制**

**fork 函数**

创建一个子进程

* 函数原型
  * `pid_t fork(void);`
* 返回值
  * 成功
    * 父进程返回子进程的 ID(非负)
    * 子进程返回 0
  * 失败返回 -1

* 参数
  * pid_t 类型表示进程 ID，但为了表示 -1，它是有符号整数，0 不是有效进程 ID，init 最小，为 1

**getpid 函数**

* 函数原型
  * `pid_t getpid(void);`

**getppid 函数**

获取当前进程的父进程 ID

* 函数原型
  * `pid_t getppid(void);`

区分一个函数是系统函数还是库函数

* 是否访问内核数据结构
* 是否访问外部硬件资源
* 二者任一是库函数，二者均无是库函数

**getuid 函数**

获取当前进程实际用户 ID，getuid 函数

获取当前进程有效用户 ID，geteuid 函数

* 函数原型
  * `uid_t getuid(void);`
  * `uid_t geteuid(void);`

**getgid 函数**

获取当前进程使用用户组 ID，getgid 函数

获取当前进程使用用户组 ID，getegid 函数

函数原型

* `gid_t getgid(void);`
* `gid_t getegid(void);`

**进程共享**

父子进程在 fork 之后

父子进程相同：全局变量、data、.text、栈、堆、环境变量、用户 ID、宿主目录、进程工作目录、信号处理方式...

父子进程不同：进程 ID、fork 返回值、父进程 ID、进程运行时间、闹钟(定时器)、未决信号集

读时共享写时复制

父子进程共享：文件描述符(打开文件的结构体)、mmap 建立的映射区

fork 之后父进程先执行还是子进程执行不确定，取决于内核所使用的调度算法

**gdb 调试**

使用 gdb 调试的时候只能跟踪一个进程，可以在 fork 函数调用之前，通过命令设置 gdb 调试工具跟踪父进程或者子进程，默认跟踪父进程

set follow-fork-mode child

set follow-fork-mode parent

分别跟踪子进程和父进程

**exec 函数族**

fork 创建子进程后执行的是和父进程相同的程序(但有可能是执行不同的代码分支)，子进程往往要调用一种 exec 函数以执行另一个程序。当进程调用一种 exec 函数时，该进程的用户空间代码和数据完全被新程序替代，从新程序的启动例程开始执行，调用 exec 并不创建新进程，所以调用 exec 前后该进程的 id 并未改变

将当前进程的 .text、.data 替换为所要加载的程序的 .text、.data，然后让进程从新的 .text 的第一条指令开始执行，但进程 ID 不变，换核不换壳

有六种以 exec 开头的函数，统称 exec 函数

* 函数原型
  * `int execl(const char *path,const char *arg,...);`
  * `int execlp(const char *file,const char *arg,...);`
  * `int execle(const char *path,const char *arg,...,char *const envp[]);`
  * `int execv(const char *path,char *const argv[]);`
  * `int execvp(const char *file,char *const argv[]);`
  * `int execve(const char *path,char *const argv[],char *const envp[]);`

* 函数说明
  * execlp 函数加载一个程序，借助 PATH 环境变量
  * execl 函数加载一个进程，通过 路径+程序名来加载
  * execvp 函数加载一个进程，使用自定义环境变量 env
  * exec 函数一旦调用成功即执行新的程序，不返回。只有失败才返回，错误值为 -1
  * 可变参数列表需要在最后一个参数用 NULL 表示结束

* 具体参数
  * l(list) 命令行参数列表
  * p(path) 搜索 file 时使用 path 变量
  * v(vector) 使用命令行参数数组，参数是一个以 NULL 结尾的指针数组，将可变参数的指针存放到数组里
  * e(enviroment) 使用环境变量数组，不使用进程原有的环境变量，设置新加载程序运行的环境变量

事实上，只有 execve 时真正的系统调用，其他五个函数最终都调用 execve，所以 execve 在 man 手册第 2 节，其他函数在第 3 节

**回收子进程**

**孤儿进程**

孤儿进程，父进程先于子进程结束，则子进程成为孤儿进程，子进程的父进程成为 init 进程，成为 init 进程领养孤儿进程

**僵尸进程**

僵尸进程，进程终止，父进程尚未回收，子进程残留资源(PCB)存放在内核中，变成僵尸进程

僵尸进程是不能使用 kill 命令清除的。因为 kill 命令只是用来终结进程的，而僵尸进程已经终止

**wait 函数**

一个进程在终止时会关闭所有文件描述符，释放在用户空间分配的内存，但它的 PCB 还保留着，内核在其中保存了一些信息，如果是正常终止则保存着退出状态，如果是异常终止则保持着导致该进程终止的信号是哪个。这个进程的父进程可以调用 wait 或 waitpid 获取这些信息，然后彻底清除这个进程。我们知道一个进程的退出状态可以在 Shell 中用特殊变量 $? 查看，因为 Shell 是它的父进程，当我们终止 Shell 调用 wait 或 waitpid 得到它的退出状态同时彻底清除这个进程，父进程调用 wait 函数可以回收子进程终止信息

* 函数功能
  * 阻塞等待子进程退出
  * 回收子进程残留资源
  * 获取子进程结束状态(退出原因)

* 函数原型
  * `pid_t wait(int *status);`
* 返回值
  * 成功，清除掉的子进程 ID
  * 失败，-1(没有子进程)
* 宏函数
  * WIFEXITED(status)
    * 非 0 便是进程正常退出，使用以下宏获取进程退出状态(exit 的参数)
    * WEXITSTATUS(status)
  * WIFSIGNALED(status)
    * 非 0 便是进程异常终止，使用以下宏取得使进程终止的那个信号的编号
    * WTERMSIG(status)
  * WIFSTOPPED(status)
    * 非 0 便是进程处于暂停状态，使用以下宏取得使进程暂停的哪个信号的编号
    * WSTOPSIG(status)
    * WIFCONTINUED(status)
      * 为真，进程暂停后已继续运行

当进程终止时，操作系统的隐式回收机制会关闭所有文件描述符、释放用户空间分配的内存，内核的 PCB 仍存在，其中保持该进程的退出状态(正常终止，退出值。异常终止，终止信号)

可使用 wait 函数传出参数 status 来保存进程的退出状态，并借助宏函数进一步判断进程终止的具体原因

* 函数原型
  * pid_t waitpid(pid_t pid,int *status,int options);

* 参数
  * pid 指定回收的子进程 pid
    * 大于 0 回收指定 ID 的子进程
    * -1 回收任意子进程(相当于 wait)
    * 0 回收和当前调用 waitpid 一个组的所有子进程
    * 小于 -1 回收指定进程组内的任意子进程
      * 例如 -1003 回收进程组 1003 的任意子进程
  * status (传出)回收进程的状态
  * option WNOHANG 指定回收方式为非阻塞
* 返回值
  * 大于 0 成功回收子进程 pid
  * 0 函数调用时，参 3 指定了 WNOHANG，并且，没有子进程结束
  * -1 失败，设置 errno

一次调用 wait 或 waitpid 只能回收一个子进程