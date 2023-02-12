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
* 返回值
  * 成功，较起始位置偏移量
  * 失败，-1 errno

* 用途
  * 调整文件的读写使用同一偏移位置
  * 获取文件大小
  * 扩展文件大小，要使文件大小真正扩展，必须引起 IO 操作，或使用 truncate 函数截断

**传入参数和传出参数**

传入参数

* 指针作为函数参数

* 通常由 const 关键字修饰

* 指针指向有效区域，在函数内部进行读操作

传出参数

* 指针作为函数参数

* 在函数调用之前，指针指向的空间可以无意义，但必须有的

* 在函数内部，做写操作

* 函数调用结束后，充当函数返回值

传入传出参数

* 指针作为函数参数

* 在函数调用之前，指针指向的空间有实际意义

* 在函数内部，先做读操作，后做写操作

* 函数调用结束后，充当函数返回值

**文件存储**

inode、dentry、数据存储、文件系统

**stat 函数**

* 函数原型
  * `int stat(const char *path,struct *buf);`
* 参数
  * path 文件路径
  * buf (传出参数) 存放文件属性
* 返回值
  * 成功 返回 0
  * 失败 返回 -1 errno
* 会穿透符号链接，用 lstat 函数不会穿透(如 ls 不穿透，cat 穿透)
* 获取文件类型(st_size)
* 文件类型判断(st_mode) 取高 4 位，但应使用宏函数
  * S_ISREG(m) regular file
  * S_ISDIR(m) directory
  * S_ISCHR(m) character device
  * S_ISBLK(m) block device
  * S_ISFIFO(m) FIFO(named pipe)
  * S_ISLINK(m) symbolic link
  * S_ISSOCK(m) socket

**link 和 unlink函数**

Linux 运行多个目录项共享一个 inode，即共享盘块(data)

link函数，可以为已经存在的文件创建目录项(硬链接)

* link 函数原型
  * `int link(const char *oldpath,const char *newpath);`
* link 返回值
  * 成功返回 0
  * 失败返回 -1，设置 errno

删除一个文件的目录项可以用 unlink 函数

* unlink 函数原型
  * `int unlink(const char *pathname);`
* unlink 返回值
  * 成功返回 0
  * 失败返回 -1，设置 errno

Linux 下删除文件的机制：不断将 st_nlink -1，直至减到 0 为止，无目录项对应的文件，将会被操作系统择机释放(具体时间由系统内部调度算法决定)

因此，我们删除文件，从某种意义上说，只是让文件具备了被释放的条件

unlink 函数的特征，清除文件时，如果文件的硬链接数到了 0，没有 dentry 对应，但该文件仍不会马上被释放，要等到所有打开该文件的进程关闭该文件，系统才会挑时间将该文件释放掉

**隐式回收**

当进程结束运行时，所有该进程打开的文件会被关闭，申请的内存空间会被释放，系统的这一特性称之为隐式回收系统资源

**symlink 函数**

* 函数原型
  * `int symlink(const char *oldpath,const char *newpath);`

* 返回值

  * 成功返回 0

  * 失败返回 -1，设置 errno

**readlink 函数**

读取符号链接文件本身内容，得到链接所指向的文件名

* 函数原型
  * `ssize_t readlink(const char *path,char *buf,size_t bufsize);`
* 返回值
  * 成功，实际读取到的字节数
  * 失败，-1，设置 errno

**rename 函数**

重命名一个文件

* `int rename(const char *oldpath,const char *newpath);`

* 返回值

  * 成功返回 0

  * 失败返回 -1，设置 errno

**getcwd 函数**

获取进程当前工作目录(卷3，标库函数)

* 函数原型
  * `char *getcwd(char *buf,size_t size);`

* 返回值
  * 成功，buf 中保存当前进程工作目录位置
  * 失败返回 NULL

**chdir 函数**

改变当前进程的工作目录

* 函数原型
  * `int chdir(const char *path);`
* 返回值
  * 成功，0
  * 失败，-1，设置 errno

**文件、目录权限**

目录文件也是文件，其文件内容是该目录下所有子文件的目录项 dentry，可以尝试用 vim 打开

**opendir 函数**

根据传入的目录名打开一个目录(库函数)，DIR * 类似于 FILE *，参数支持相对路径、绝对路径

* 函数原型
  * `DIR *opendir(const char *name);`
* 返回值
  * 成功，返回指向该目录结构体指针
  * 失败，返回 NULL

**closedir 函数**

关闭打开的目录

* 函数原型
  * `int closedir(DIR *dirp);`
* 返回值
  * 成功，0
  * 失败，-1，设置 errno

**readdir 函数**

读取目录(库函数)

* 函数原型

  * `struct dirent *readdir(DIR *drip);`

* 返回值

  * 成功，返回目录项结构体指针
  * 失败，返回 NULL，设置errno

* 参数

  * 结构体

    ```c
    struct dirent {
        ino_t 		d_ino;			//inode编号
        off_t 		d_off;			//
        unsigned 	short;			//文件名有效长度
        unsigned 	char;			//类型(vim 打开看到的类似@*/等)
        char 		d_name[256];	//文件名
    }
    //重点记忆 d_ino、d_name，实际应用中只使用 d_name
    ```

**rewinddir 函数**

回卷目录读写位置至起始

* 函数原型
  * `void rewinddir(DIR *drip);`

**telldir/seekdir 函数**

获取目录读写位置

* 函数原型
  * `long telldir(DIR *drip);`
  * `void seekdir(DIR *drip,long loc);`

* telldir 返回值
  * 成功，返回与 drip 相关的目录当前读写位置
  * 失败，-1，设置 errno

* 参数
  * 参数 loc 一般由 telldir 函数的返回值来决定

**重定向**

dup 函数和 dup2 函数

* 函数原型
  * `int dup(int oldfd);`
  * `int dup2(int oldfd,int newfd);`

* 返回值
  * 成功，返回一个新文件描述符
  * 失败，返回 -1，设置error

fcntl 函数实现 dup 函数

* int fcntl(int fd,int cmd,...);
* cmd:F_DUPFD
* 参数 3 传入文件描述符，若传入文件描述符被占用，返回最小可用文件描述符
