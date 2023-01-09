# **Linux 系统编程笔记**
## **Linux 系统调用函数**
系统调用(内核提供的函数)
由操作系统实现并提供给外部应用程序的编程接口

**Open 函数**

* 头文件

	* include <unistd.h>

	* include <fcntl.h>
* 函数原型
	* `int open(const char* pathname,int flags);`
	* `int open(const char* pathname,int flags,mode_t mode);`
	* `int close(int fd);`
* 常用参数
  * pathname 文件路径名
  * flags 文件打开方式
    * O_RDONLY、O_WRONLY、O_RDWR
    * O_APPEND、O_CREAT、O_TRUNC、O_NONBLOCK

  * fd 文件描述符
  * 参数 mode 使用的前提，flags 指定了 O_CREAT，mode取值为8进制数，描述文件的访问权限

* 返回值
  * 成功 打开文件所得到对应的文件描述符(整数)
  * 失败 -1，设置 errno

**close 函数**

* 函数原型
  * in close(int fd);

**错误处理函数**

* 头文件
  * include <errno.h>
  * include <string.h>
  * include <stdio.h>
  * include <errno.h>
* 函数原型
  * `char* strerror(int errnum);`
  * `void perror(const char* s);`

* 参数
  * errnum 参数对应 errno ，errno 对应头文件 errno.h
  * error 对应错误的字符串可以用 strerror 函数返回，strerror 函数对应头文件 string.h
  * 将需要的错误信息传入 perror 函数中，对应头文件 stdio.h
  * exit(1); 退出程序，对应头文件 stdlib.h


**read/write 函数**

* 函数原型
  * `ssize_t read(int fd,void *buf,size_t count);`
  * `ssize_t write(int fd,const void *buf,size_t count);`
* 参数
    * fd 文件描述符
    * buf 存数据的缓冲区
    * count 缓冲区大小
* 返回值
    * 成功 读到的字节数
    * 返回值为0便是读到文件末尾
    * 失败 -1，设置 errno

**文件描述符**

* PCB 进程控制块
* 文件描述符表
* 最大打开文件数
* FILE 结构体

**阻塞、非阻塞**

产生阻塞的场景 读设备文件、读网络文件(读常规文件无阻塞概念)

/dev/tty 终端文件

**fcntl 函数**

* 函数原型
  * `int fcntl(int fd,int cmd,.../*args*/);`
  * 参数
    * F_GETFL 获取文件状态
    * F_SETFL 设置文件状态

**位图**

**lseek 函数**

* 函数原型
  * `off_t lseek(int fd,off_t offset,int whence);`
* 



