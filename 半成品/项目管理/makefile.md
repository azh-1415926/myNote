# **一起来写`Makefile`**
## **一、概述**
### *什么是`makefile`？*
1. 会不会写`makefile`，从侧面说明了一个人是否具备完成大型工程的能力，makefile关系到了整个工程的编译规则

2. 在一个工程中，源文件不计其数，其按照功能、模块分别放在若干个目录中，而`makefile`定义了一系列的规则来指定，包括源文件的编译顺序，它带来的好处就是自动化编译，一旦写好，只需要执行`make`命令，整个工程便会自动编译
## **二、程序的编译和链接**
### *什么是编译？什么是链接？*
1. 一般来说，无论是C、C++，首先要把源文件编译成中间代码文件，在Windows下也就是.obj文件，Unix下是.o文件，即Object File，这个过程叫编译(compile)，然后再把大量的Object File合成执行文件，这个过程叫链接(link)

2. 编译时，编译器需要正确的语法、正确的函数与变量声明，对于后者，要告诉编译器头文件的所在位置（分文件编写），只要所有的语法正确，编译器就可以编译出中间目标文件。一般来说，每个源文件都应该对应一个目标文件

3. 链接时，主要是链接函数和全局变量，我们用这些中间目标文件来链接我们的应用程序。链接器并不管函数所在的源文件，只管函数的中间目标文件
4. 在大多数时候，由于源文件太多，编译器生成的中间目标文件太多，而在链接时需要明显地指出中间目标文件名，这对编译很不方便，所以，我们要给中间目标文件打个包，在Windows下这种包叫做"库文件"(Library File)，也就是.lib文件，在Unix下，是Archive File，也就是.a文件
## **三、`Makefile`介绍**
### *`Makefile` 能做什么？*
* `make`命令执行时，需要一个`Makefile`文件，以告诉`make`命令需要怎么样的去编译和链接程序
* 我们用一个示例来说明 `Makefile` 的书写规则。
我们要写一个 `Makefile` 来告诉 `make` 命令如何编译和链接这几个文件
   1. 如果这个工程没有编译过，那么我们的所有 C 文件都要编译并被链接

   2. 如果这个工程的某几个 C 文件被修改，那么我们只编译被修改的 C 文件，并链接目
标程序

   3. 如果这个工程的头文件被改变了，那么我们需要编译引用了这几个头文件的 C 文件，
并链接目标程序
---
### *`Makefile`的规则*
在讲述这个 `Makefile` 之前，还是让我们先来粗略地看一看 `Makefile` 的规则
```makefile
target ... : prerequisites ... 
    command 
... 
...
```
* target:目标文件
* prerequisites:生成目标文件所需文件或目标
* command:make需要执行的命令，任意shell命令
---
### *示例*
 ```makefile
edit : main.o kbd.o command.o display.o \ 
insert.o search.o files.o utils.o 
   cc -o edit main.o kbd.o command.o display.o \ 
 insert.o search.o files.o utils.o 
main.o : main.c defs.h 
   cc -c main.c 
kbd.o : kbd.c defs.h command.h 
   cc -c kbd.c 
command.o : command.c defs.h command.h 
   cc -c command.c 
display.o : display.c defs.h buffer.h 
   cc -c display.c 
insert.o : insert.c defs.h buffer.h 
   cc -c insert.c 
search.o : search.c defs.h buffer.h 
   cc -c search.c 
files.o : files.c defs.h buffer.h command.h 
   cc -c files.c 
utils.o : utils.c defs.h 
    cc -c utils.c 
clean : 
    rm edit main.o kbd.o command.o display.o \ 
 insert.o search.o files.o utils.o
```
---
### *`make`如何工作*
1. 当我们输入`make`命令时，`make`会在当前目录下寻找名字叫`Makefile`或`makefile`的文件

2. 找到第一个目标文件，并作为最终的目标文件，若目标文件此时不存在或者目标文件依赖的所需文件修改时间更新，则执行定义的命令

3. 如果存在目标文件依赖的目标文件，会一层一层地去找文件的依赖关系，直到编译出第一个目标文件
---
### *`makefile` 中使用变量*
使用变量，再加入新的文件时，只需要修改变量部分
```makefile
objects = main.o kbd.o command.o display.o \ 
 insert.o search.o files.o utils.o
 ```
 ---
### *让 `make` 自动推导*
* GNU 的 `make` 很强大，它可以自动推导文件以及文件依赖关系后面的命令，于是就没必
要在每一个.o文件后都写上类似的命令，因为，我们的 `make` 会自动识别，并自己推导
命令
* 只要 `make` 看到一个.o文件，它就会自动的把.c文件加在依赖关系中，如果 `make` 找
到一个 whatever.o，那么 whatever.c，就会是 whatever.o 的依赖文件。并且 cc -c 
whatever.c 也会被推导出来，于是，我们的 `makefile` 再也不用写得这么复杂
```makefile
objects = main.o kbd.o command.o display.o \ 
insert.o search.o files.o utils.o 
edit : $(objects) 
    cc -o edit $(objects) 
main.o : defs.h 
kbd.o : defs.h command.h 
command.o : defs.h command.h 
display.o : defs.h buffer.h 
insert.o : defs.h buffer.h 
search.o : defs.h buffer.h 
files.o : defs.h buffer.h command.h 
utils.o : defs.h 
.PHONY : clean 
clean : 
    rm edit $(objects)
```
* 上面文件内容中，“.PHONY”表示，clean 是个
伪目标文件
---
### *另类风格的 `makefile`*
即然我们的 `make` 可以自动推导命令，那么我看到那堆.o和.h的依赖就有点不爽，那
么多的重复的.h，能不能把其收拢起来，这个对于 `make` 来说很容易，
来看看最新风格的 `makefile` 吧
```makefile
objects = main.o kbd.o command.o display.o \ 
 insert.o search.o files.o utils.o 
edit : $(objects) 
   cc -o edit $(objects) 
$(objects) : defs.h 
kbd.o command.o files.o : command.h 
display.o insert.o search.o files.o : buffer.h 
.PHONY : clean 
clean : 
   rm edit $(objects)
```
* 文件依赖关系显得有点凌乱
---
### *清空目标文件的规则*
* 每个 Makefile 中都应该写一个清空目标文件（.o 和执行文件）的规则，这不仅便于重编
译，也很利于保持文件的清洁
* clean 的规则不
要放在文件的开头，不然，这就会变成 make 的默认目标，相信谁也不愿意这样
* 不成文的
规矩是——“clean 从来都是放在文件的最后”
## **四、Makefile 总述**
### *Makefile 里有什么？*
Makefile 里主要包含了五个东西：显示规则、隐晦规则、变量定义、文件指示和注释

1. 显示规则。显示规则说明了，如何生成一个或多的的目标文件。所以需要明显指出，要生成的文件，文件的依赖文件，生成的命令

2. 隐晦规则。make 有自动推导，可以用隐晦的规则简略地书写 Makefile

3. 变量的定义。在 Makefile 中我们要定义一系列的变量，变量一般都是字符串，这个有
点像 C 语言中的宏，当 Makefile 被执行时，其中的变量都会被扩展到相应的引用位置上

4. 文件指示。其包括了三个部分，
   * 一个是在一个 Makefile 中引用另一个 Makefile，就
像 C 语言中的 include 一样
   * 另一个是指根据某些情况指定 Makefile 中的有效部分，就
像 C 语言中的预编译#if 一样
   * 还有就是定义一个多行的命令

5. 注释。Makefile 中只有行注释，和 UNIX 的 Shell 脚本一样，其注释是用“#”字符

最后，还值得一提的是，在 Makefile 中的命令，必须要以Tab键开始
### *`Makefile` 的文件名*
默认的情况下，`make` 命令会在当前目录下按顺序找寻文件名为“GNUmakefile”、
“makefile”、“Makefile”的文件，最好使
用“Makefile”这个文件名
当然，你可以使用别的文件名来书写 Makefile，比如：“Make.Linux”，“Make.Solaris”，
“Make.AIX”等，如果要指定特定的 Makefile，你可以使用 make 的“-f”和“--file”
参数，如：make -f Make.Linux 或 make --file Make.AIX
### *引用其它的 `Makefile`*
在 Makefile 使用 include 关键字可以把别的 Makefile 包含进来，这很像 C 语言的
#include，被包含的文件会原模原样的放在当前文件的包含位置
* filename 可以是当前操作系统 Shell 的文件模式（可以保含路径和通配符）
* 在 include 前面可以有一些空字符，但是绝不能是Tab键开始。include 和<filename>
可以用一个或多个空格隔开
make 命令开始时，会把找寻 include 所指出的其它 Makefile，并把其内容安置在当前的
位置。就好像 C/C++的#include 指令一样。如果文件都没有指定绝对路径或是相对路径的
话，make 会在当前目录下首先寻找，如果当前目录下没有找到，那么，make 还会在下面的
几个目录下找
1、如果 make 执行时，有“-I”或“--include-dir”参数，那么 make 就会在这个
参数所指定的目录下去寻找

 2、如果目录<prefix>/include（一般是：/usr/local/bin 或/usr/include）
存在的话，make 也会去找。
* 如果有文件没有找到的话，make 会生成一条警告信息，但不会马上出现致命错误
* 它会继续载入其它的文件，一旦完成 makefile 的读取，make 会再重试这些没有找到，或是不能
读取的文件，如果还是不行，make 才会出现一条致命信息
* 如果你想让 make 不理那些无
法读取的文件，而继续执行，你可以在 include 前加一个减号“-”。如：
`-include <filename>`
其表示，无论 include 过程中出现什么错误，都不要报错继续执行
* 和其它版本 make
兼容的相关命令是 sinclude，其作用和这一个是一样的
---
### *环境变量 `MAKEFILES`*
如果你的当前环境中定义了环境变量 MAKEFILES，那么，make 会把这个变量中的值做一个
类似于 include 的动作。这个变量中的值是其它的 Makefile，用空格分隔。只是，它和
include 不同的是，从这个环境变中引入的 Makefile 的“目标”不会起作用，如果环境
变量中定义的文件发现错误，make 也会不理。
但是在这里我还是建议不要使用这个环境变量，因为只要这个变量一被定义，那么当你使用
make 时，所有的 Makefile 都会受到它的影响，这绝不是你想看到的。在这里提这个事，
只是为了告诉大家，也许有时候你的 Makefile 出现了怪事，那么你可以看看当前环境中有
没有定义这个变量
***
### *`make` 的工作方式*
GNU 的 make 工作时的执行步骤入下：
1. 读入所有的 Makefile
2. 读入被 include 的其它 Makefile
3. 初始化文件中的变量
4. 推导隐晦规则，并分析所有规则
5. 为所有的目标文件创建依赖关系链
6. 根据依赖关系，决定哪些目标要重新生成
7. 执行生成命令
## 五、**书写规则**
规则包含两个部分，一个是依赖关系，一个是生成目标的方法
### *示例*
```makefile
foo.o : foo.c defs.h # foo 模块
   cc -c -g foo.c
```
### *规则的语法*
```makefile
targets : prerequisites 
   command 
 ... 
#或是这样： 
targets : prerequisites ; command 
   command 
 ...
```
* targets 是文件名，以空格分开，可以使用通配符。一般来说，我们的目标基本上是一个文
件，但也有可能是多个文件
* command 是命令行，如果其不与“target:prerequisites”在一行，那么，必须以Tab
键开头，如果和 prerequisites 在一行，那么可以用分号做为分隔
* prerequisites 也就是目标所依赖的文件（或依赖目标）。如果其中的某个文件要比目标
文件要新，那么，目标就被认为是“过时的”，被认为是需要重生成的
* 如果命令太长，你可以使用反斜框（‘\’）作为换行符。make 对一行上有多少个字符没有限
制。规则告诉 make 两件事，文件的依赖关系和如何成成目标文件
### *在规则中使用通配符*
* make 支持三各
通配符：“*”，“?”和“[...]”
* 通符同样可以用在变量中
```makefile
objects = *.o
```
* 并不是说*.o会展开，objects
的值就是“*.o”
   * Makefile 中的变量其实就是 C/C++中的宏
* 如果你要让通配符在变量
中展开，也就是让 objects 的值是所有[.o]的文件名的集合，那么，你可以这样：
```makefile
objects := $(wildcard *.o)
```
### *文件搜寻*
* 在一些大的工程中，有大量的源文件，我们通常的做法是把这许多的源文件分类，并存放在
不同的目录中
* 当 make 需要去找寻文件的依赖关系时，你可以在文件前加上路径，
但最好的方法是把一个路径告诉 make，让 make 在自动去找
* 特殊变量“VPATH”就是完成这个功能的，如果没有指明这个变量，make
只会在当前的目录中去找寻依赖文件和目标文件
* 如果定义了这个变量，那么，make 就会
在当当前目录找不到的情况下，到所指定的目录中去找寻文件
```makefile
VPATH = src:../headers
```
上面的的定义指定两个目录，“src”和“../headers”，make 会按照这个顺序进行搜索
* 目录由“冒号”分隔（当然，当前目录永远是最高优先搜索的地方）

另一个方法是使用 make 的“vpath”关键字，比较灵活，它可以指定不同的文件在不同的搜索目录中
1. `vpath <pattern> <directories>`
   * 为符合模式`<pattern>`的文件指定搜索目录`<directories>`
   * vapth 使用方法中的`<pattern>`需要包含“%”字符
      * “%”的意思是匹配零或若干字符
      * `<pattern>`指定了要搜索的文件集
      * `<directories>`则指定了`<pattern`>的文件集的搜索的目录
      * 例如：`vpath %.h ../headers` 
该语句表示，要求 make 在“../headers”目录下搜索所有以“.h”结尾的文件
         * 例如，“%.h”表示所有以“.h”结尾的文件
2. `vpath <pattern>`
   * 清除符合模式`<pattern>`的文件的搜索目录。
3. vpath 
   * 清除所有已被设置好了的文件搜索目录
* 如果某文件在当前目录没有找到的话，我们可以连续地使用vpath 语句，以指定不同搜索策略
如果连续的 vpath 语句中出现了相同的<pattern>，或是被重复了的<pattern>，那么，make 会按照 vpath 语句的先后
顺序来执行搜索
```makefile
vpath %.c foo 
vpath % blish 
vpath %.c bar
```
其表示“.c”结尾的文件，先在“foo”目录，然后是“blish”，最后是“bar”目录
```makefile
vpath %.c foo:bar 
vpath % blish
```
而上面的语句则表示“.c”结尾的文件，先在“foo”目录，然后是“bar”目录，最后才
是“blish”目录
## 六、**书写命令**
## 七、**使用变量**
## 八、**使用条件判断**
## 九、**使用函数**
## 十、**make的运行**
## 十一、**隐含规则**
## 十二、**使用make更新函数库文件**