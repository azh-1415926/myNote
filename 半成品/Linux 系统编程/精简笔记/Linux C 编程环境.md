## 静态库和动态库(共享库)

* 制作静态库
  * Linux下使用ar工具、Windows下vs使用lib.exe，将目标文件压缩到一起，并且对其进行编号和索引，以便于查找和检索
  * Linux静态库命名规范，必须是"lib[your_library_name].a"：lib为前缀，中间是静态库名，扩展名为.a
  * 静态库的制作步骤
    * 1.编译目标文件 `gcc -c file1.c`
    * 2.生成静态库文件 `ar rcs lib库名.a file1.o file2.o`
    * 3.编译时将静态库和源文件一起编译 `gcc test.c lib库名.a -o test`
  * 注意源文件应包含库文件对应的头文件，避免函数的隐式声明
  * 大一点的项目会编写makefile文件（CMake等等工程管理工具）来生成静态库
  * Linux下使用静态库，只需要在编译的时候，指定静态库的搜索路径(-L选项)、指定静态库名(使用-l选项指定静态库文件，不需要lib前缀和.a后缀)
* 制作动态库(生成与位置无关代码)
  * 动态链接库的名字形式为 libxxx.so，前缀是lib，后缀名为".so"
  * 动态库的制作步骤
    * 1.将.c文件编译成.o文件(生成与位置无关的代码 -fPIC)
      * `gcc -c file.c -o file.o -fPIC`
    * 2.使用 gcc -shared 制作动态库
      * `gcc -shared lib库名.so file1.o file2.o`
    * 3.编译可执行程序时，指定使用的动态库，-l 指定库名，-L 指定库路径
      * `gcc test.c -o a.out -l mylib -L ./lib`
  * 运行时出错，原因
    * 链接器: 工作于链接阶段，工作需要-l 和 -L
    * 动态链接器: 工作于程序运行阶段，工作时需要提供动态库所在目录位置
    * 解决方案
      * 1.通过环境变量(临时生效): export LD_LIBRARY_PATH=动态库路径
      * 2.写入终端配置文件(永久生效): 
        * vi ~/.bashrc
        * 修改export LD_LIBRARY_PATH=动态库路径
        * . .bashrc或source .bashrc使修改的配置文件生效
        * ldd a.out可以查看程序运行时需要加载的动态库文件
      * 3.拷贝自定义动态库到/lib(标准C库所在目录位置)目录下
      * 4.配置文件法
        * vi /etc/ld.so.conf
        * 将动态库路径写入
        * ldconfig -v
        * ldd a.out查看加载的动态库文件

---

### **GDB 调试工具**

使用 gdb 调试可执行程序应在编译时使用 -g 参数添加调试选项 `gcc -g main.c -o main` 即可用 `gdb main` 进行调试，添加了调试选项后会比普通编译后的文件大一些

* 执行 `gdb 可执行程序` 后，可用下列命令进行调试
  * list(l)列出10行的源码，可以指定行号
  * break(b)指定行号设置断点
  * run(r)运行
  * next(n)下一条指令，会越过函数
  * step(s)下一条指令，会进入函数
  * print(p)指定变量名查看变量的值
  * continue继续执行断点后续指令
  * until
  * quit退出gdb调试
  * finish结束当前函数调用
  * 命令行参数设置的两种方式
    * set args arg1 arg2 设置命令行参数，然后start执行
    * run arg1 arg2 设置并运行命令行参数
  * info b查看断点信息表
  * b 20 if i=5设置条件断点
  * ptype指定变量查看变量类型

栈帧 : 随着函数调用在stack上开辟的一片内存空间，用于存放函数调用时产生的局部变量和临时值

* bt 列出当前程序正在存活的栈帧
* frame 根据栈帧编号，切换栈帧
* display 设置跟踪变量，用undisplay取消，可以使用编号取消

---

### **Makefile 项目管理**

* 项目代码编译管理，节省编译项目时间，命名为Makefile或makefile
* 一个规则

```makefile
#目标:依赖条件
#    命令(一个tab缩进)
#如:
main : main.o
    gcc main.o -o main
main.o : main.c
    gcc -c main.c -o main.o

#ALL:指定最终目标
#如:
ALL:main
main : main.o
    gcc main.o -o main
main.o : main.c
    gcc -c main.c -o main.o
```

* 两个函数
  * src=$(wildcard ./*.c)匹配当前目录下的所有.c文件，将文件名组成列表，赋给src
  * $(patsubst %.c,%.o,$(src))将参数3中，包含参数1的部分替换成参数2
* 三个自动变量
  * $@在规则的命令中，表示规则的目标
  * $<在规则的命令中，表示第一个依赖，如果将该变量应用在模式规则中，它可将依赖条件列表中的依赖依次取出，套用规则模式
  * $^在规则的命令中，表示所有依赖，组成一个列表，以空格隔开并消除重复项
* 模式规则

```makefile
%.o:%.c
    gcc -c $< -o $@
```

* 静态模式规则

```makefile
a.out:$(obj)
    gcc $^ -o $@
$(obj):%.o:%.c
    gcc -c $< -o $@
```

* 伪目标

```
.PHONY : clean ALL
```

* 参数
  * -n 参数，模拟执行make、make clean命令
  * -f 参数，指定文件执行make命令