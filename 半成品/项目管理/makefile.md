# **一起来写 `Makefile`**
## **一、概述**
#### 什么是 `makefile` ？

会不会写 `makefile`，从侧面说明了一个人是否具备完成大型工程的能力， `makefile` 关系到了整个工程的编译规则

在一个工程中，源文件不计其数，其按照功能、模块分别放在若干个目录中，而`makefile`定义了一系列的规则来指定，包括源文件的编译顺序，它带来的好处就是自动化编译，一旦写好，只需要执行 `make` 命令，整个工程便会自动编译

## **二、程序的编译和链接**
#### 什么是编译？什么是链接？

一般来说，无论是 C、C++，首先要把源文件编译成中间代码文件，在 Windows 下也就是 .obj 文件，Unix 下是 .o 文件，即 Object File，这个过程叫**编译**(compile)，然后再把大量的 Object File 合成执行文件，这个过程叫**链接**(link)

编译时，编译器需要正确的语法、正确的函数与变量声明，对于后者，要告诉编译器头文件的所在位置（分文件编写），只要所有的语法正确，编译器就可以编译出中间目标文件。一般来说，每个源文件都应该对应一个目标文件

链接时，主要是链接函数和全局变量，我们用这些中间目标文件来链接我们的应用程序。链接器并不管函数所在的源文件，只管函数的中间目标文件

在大多数时候，由于源文件太多，编译器生成的中间目标文件太多，而在链接时需要明显地指出中间目标文件名，这对编译很不方便，所以，我们要给中间目标文件打个包，在 Windows 下这种包叫做**库文件**(Library File)，也就是 .lib 文件，在 Unix 下，是 Archive File，也就是 .a 文件

## **三、`Makefile`介绍**
#### `Makefile` 能做什么？

`make` 命令执行时，需要一个 `Makefile` 文件，以告诉 `make` 命令需要怎么样的去编译和链接程序，我们要写一个 `Makefile` 来告诉 `make` 命令如何编译和链接这几个文件

 1. 如果这个工程没有编译过，那么我们的所有 C 文件都要编译并被链接

 2. 如果这个工程的某几个 C 文件被修改，那么我们只编译被修改的 C 文件，并链接目
标程序

 3. 如果这个工程的头文件被改变了，那么我们需要编译引用了这几个头文件的 C 文件，
并链接目标程序

---
#### `Makefile` 的规则
在讲述这个 `Makefile` 之前，还是让我们先来粗略地看一看 `Makefile` 的规则
```makefile
target ... : prerequisites ... 
    command 
... 
...
```
* target (目标文件)
* prerequisites (生成目标文件所需文件或目标)
* command (make需要执行的命令，任意shell命令)

**示例**

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
#### `make` 如何工作
当我们输入 `make` 命令时，`make` 会在当前目录下寻找名字叫 `Makefile` 或 `makefile` 的文件

找到第一个目标文件，并作为最终的目标文件，若目标文件此时不存在或者目标文件依赖的所需文件修改时间更新，则执行定义的命令

如果存在目标文件依赖的目标文件，会一层一层地去找文件的依赖关系，直到编译出第一个目标文件

---
#### `makefile` 中使用变量
使用变量，再加入新的文件时，只需要修改变量部分
```makefile
objects = main.o kbd.o command.o display.o \ 
 insert.o search.o files.o utils.o
```
---
#### 让 `make` 自动推导
GNU 的 `make` 很强大，它可以自动推导文件以及文件依赖关系后面的命令，于是就没必
要在每一个 .o 文件后都写上类似的命令，因为，我们的 `make` 会自动识别，并自己推导
命令

只要 `make` 看到一个 .o 文件，它就会自动的把 .c 文件加在依赖关系中，如果 `make` 找
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
#### 另类风格的 `makefile`
即然我们的 `make` 可以自动推导命令，那么我看到那堆 .o  和 .h 的依赖就有点不爽，那
么多的重复的 .h，能不能把其收拢起来，这个对于 `make` 来说很容易，
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

#### 清空目标文件的规则

每个 Makefile 中都应该写一个清空目标文件（.o 和执行文件）的规则，这不仅便于重编
译，也很利于保持文件的清洁

clean 的规则不要放在文件的开头，不然，这就会变成 make 的默认目标，相信谁也不愿意这样

不成文的规矩是——“clean 从来都是放在文件的最后”

## **四、`Makefile` 总述**
#### `Makefile` 里有什么？

`Makefile` 里主要包含了五个东西：**显示规则**、**隐晦规则**、**变量定义**、**文件指示**、**注释**

1. **显示规则**

   显示规则说明了，如何生成一个或多的的目标文件。所以需要明显指出，要生成的文件，文件的依赖文件，生成的命令

2. **隐晦规则**

   `make` 有自动推导，可以用隐晦的规则简略地书写 `Makefile`

3. **变量的定义**

  在 `Makefile` 中我们要定义一系列的变量，变量一般都是字符串，这个有
  点像 C 语言中的宏，当 `Makefile` 被执行时，其中的变量都会被扩展到相应的引用位置上

4. **文件指示**

   其包括了三个部分，

   * 一个是在一个 `Makefile` 中引用另一个 `Makefile`，就像 C 语言中的 `include` 一样
   * 另一个是指根据某些情况指定 `Makefile` 中的有效部分，就像 C 语言中的预编译 #if 一样
   * 还有就是定义一个多行的命令

5. **注释**

   Makefile 中只有行注释，和 UNIX 的 Shell 脚本一样，其注释是用“#”字符


最后，还值得一提的是，在 Makefile 中的命令，必须要以Tab键开始

#### `Makefile` 的文件名

默认的情况下，`make` 命令会在当前目录下按顺序找寻文件名为 `GNUmakefile`、`makefile`、`Makefile` 的文件，最好使用 `Makefile` 这个文件名
当然，你可以使用别的文件名来书写 Makefile，比如：`Make.Linux`，`Make.Solaris`，
`Make.AIX` 等，如果要指定特定的 `Makefile`，你可以使用 `make` 的 -f 和 --file 
参数，如：`make -f Make.Linux` 或 `make --file Make.AIX`

#### 引用其它的 `Makefile`

在 `Makefile` 使用 include 关键字可以把别的 `Makefile` 包含进来，这很像 C 语言的 `#include`，被包含的文件会原模原样的放在当前文件的包含位置

`include <filename>`

* filename 可以是当前操作系统 Shell 的文件模式（可以保含路径和通配符）

* 在 include 前面可以有一些空字符，但是绝不能是Tab键开始

* `include` 和 `<filename>` 可以用一个或多个空格隔开

make 命令开始时，会把找寻 include 所指出的其它 Makefile，并把其内容安置在当前的位置。就好像 C/C++的 `#include` 指令一样。如果文件都没有指定绝对路径或是相对路径的话，`make` 会在当前目录下首先寻找，如果当前目录下没有找到，那么，`make` 还会在下面的几个目录下找

* 如果 make 执行时，有 `-I` 或 `--include-dir` 参数，那么 `make` 就会在这个
  参数所指定的目录下去寻找
* 如果目录`<prefix>/include`（一般是：`/usr/local/bin` 或 `/usr/include`）
  存在的话，`make` 也会去找

如果有文件没有找到的话，`make` 会生成一条警告信息，但不会马上出现致命错误

它会继续载入其它的文件，一旦完成 `makefile` 的读取，`make` 会再重试这些没有找到，或是不能
读取的文件，如果还是不行，`make` 才会出现一条致命信息

如果你想让 `make` 不理那些无法读取的文件，而继续执行，你可以在 include 前加一个减号 `-`

`-include <filename>` 

* 其表示，无论 include 过程中出现什么错误，都不要报错继续执行和其它版本 make 兼容的相关命令是  `sinclude`，其作用和这一个是一样的

#### 环境变量 `MAKEFILES`

如果你的当前环境中定义了环境变量 `MAKEFILES`，那么，`make` 会把这个变量中的值做一个
类似于 include 的动作

这个变量中的值是其它的 Makefile，用空格分隔

只是，它和 include 不同的是，从这个环境变中引入的 Makefile 的“目标”不会起作用，如果环境变量中定义的文件发现错误，`make` 也会不理，但是在这里我还是建议不要使用这个环境变量，因为只要这个变量一被定义，那么当你使用 `make` 时，所有的 `Makefile` 都会受到它的影响，这绝不是你想看到的

在这里提这个事，只是为了告诉大家，也许有时候你的 `Makefile` 出现了怪事，那么你可以看看当前环境中有没有定义这个变量

***
#### `make` 的工作方式
GNU 的 `make` 工作时的执行步骤入下：
1. 读入所有的 `Makefile`
2. 读入被 include 的其它 `Makefile`
3. 初始化文件中的变量
4. 推导隐晦规则，并分析所有规则
5. 为所有的目标文件创建依赖关系链
6. 根据依赖关系，决定哪些目标要重新生成
7. 执行生成命令
## 五、**书写规则**
规则包含两个部分，一个是**依赖关系**，一个是**生成目标的方法**
**示例**

```makefile
foo.o : foo.c defs.h # foo 模块
   cc -c -g foo.c
```
#### 规则的语法
```makefile
targets : prerequisites 
   command 
 ... 
#或是这样： 
targets : prerequisites ; command 
   command 
 ...
```
* targets 是文件名，以空格分开，可以使用通配符。一般来说，我们的目标基本上是一个文件，但也有可能是多个文件
* command 是命令行，如果其不与 `target:prerequisites` 在一行，那么，必须以 Tab 键开头，如果和 prerequisites 在一行，那么可以用分号做为分隔
* prerequisites 也就是目标所依赖的文件（或依赖目标）。如果其中的某个文件要比目标文件要新，那么，目标就被认为是“过时的”，被认为是需要重生成的
* 如果命令太长，你可以使用 `\` 作为换行符。`make` 对一行上有多少个字符没有限制。规则告诉 `make` 两件事，文件的依赖关系和如何成成目标文件

#### 在规则中使用通配符

`make` 支持三种通配符：`*`，`?` 和` [...]`

通符同样可以用在变量中

```makefile
objects = *.o
```
并不是说 `*.o` 会展开，objects的值就是 `*.o`
 * `Makefile` 中的变量其实就是 C/C++中的宏

* 如果你要让通配符在变量中展开，也就是让 objects 的值是所有 .o 的文件名的集合，那么，你可以这样

```makefile
objects := $(wildcard *.o)
```
#### 文件搜寻
在一些大的工程中，有大量的源文件，我们通常的做法是把这许多的源文件分类，并存放在不同的目录中

当 `make` 需要去找寻文件的依赖关系时，你可以在文件前加上路径，但最好的方法是把一个路径告诉 它，让它在自动去找

特殊变量 `VPATH` 就是完成这个功能的，如果没有指明这个变量，只会在当前的目录中去找寻依赖文件和目标文件

如果定义了这个变量，那么，就会在当前目录找不到的情况下，到所指定的目录中去找寻文件

```makefile
VPATH = src:../headers
```
上面的的定义指定两个目录，src 和 ../headers，`make` 会按照这个顺序进行搜索
* 目录由冒号 `:` 分隔（当然，当前目录永远是最高优先搜索的地方）

另一个方法是使用 `vpath` 关键字，它比较灵活，可以指定不同的文件在不同的搜索目录中
1. `vpath <pattern> <directories>`
   * 为符合模式 `<pattern>` 的文件指定搜索目录 `<directories>`
   * vapth 使用方法中的 `<pattern>` 需要包含“%”字符
      * % 的意思是匹配零或若干字符
      * `<pattern>` 指定了要搜索的文件集
      * `<directories>` 则指定了 `<pattern>` 的文件集的搜索的目录
      * 例如：`vpath %.h ../headers` 该语句表示，在 ../headers 目录下搜索所有以“.h”结尾的文件
         * 例如，%.h 表示所有以 .h 结尾的文件
2. `vpath <pattern>`
   * 清除符合模式`<pattern>`的文件的搜索目录
3. vpath 
   * 清除所有已被设置好了的文件搜索目录

如果某文件在当前目录没有找到的话，我们可以连续地使用 `vpath` 语句，以指定不同搜索策略
如果连续的 `vpath` 语句中出现了相同的 `<pattern>`，或是被重复了的 `<pattern>`，那么，将按照 `vpath` 语句的先后顺序来执行搜索

```makefile
vpath %.c foo 
vpath % blish 
vpath %.c bar
```
其表示 .c 结尾的文件，先在 foo 目录，然后是 blish，最后是 bar 目录
```makefile
vpath %.c foo:bar 
vpath % blish
```
而上面的语句则表示“.c”结尾的文件，先在 foo 目录，然后是 bar 目录，最后才
是 blish 目录

#### 伪目标

最早先的一个例子中，我们提到过一个 clean 的目标，这是一个伪目标

```makefile
clean:  rm *.o temp
```

正像我们前面例子中的 clean 一样，即然我们生成了许多文件编译文件，我们也应该提供一个清除它们的目标以备完整地重编译而用（以 `make clean` 来使用该目标）

因为，我们并不生成 clean 这个文件。伪目标并不是一个文件，只是一个标签，由于伪目标不是文件，所以 `make` 无法生成它的依赖关系和决定它是否要执行，我们只有通过显示地指明这个目标才能让其生效。当然，伪目标的取名不能和文件名重名，不然其就失去了伪目标的意义了

当然，为了避免和文件重名的这种情况，我们可以使用一个特殊的标记 `.PHONY` 来显示地指明一个目标是伪目标，说明不管是否有这个文件，这个目标就是伪目标

 `.PHONY : clean`

只要有这个声明，不管是否有 clean 文件，要运行 clean 这个目标，只有 make clean  这样，于是整个过程可以这样写

`.PHONY: clean  clean:  rm *.o temp`

伪目标一般没有依赖的文件。但是，我们也可以为伪目标指定所依赖的文件。伪目标同样可 以作为默认目标，只要将其放在第一个。一个示例就是，如果你的 `Makefile` 需要一口 气生成若干个可执行文件，但你只想简单地敲一个 make 完事，并且，所有的目标文件都写 在一个 `Makefile` 中，那么你可以使用伪目标这个特性： 

```makefile
all : prog1 prog2 prog3
.PHONY : all

prog1 : prog1.o utils.o
	cc -o prog1 prog1.o utils.o
prog2 : prog2.o
	cc -o prog2 prog2.o
prog3 : prog3.o sort.o utils.o
	cc -o prog3 prog3.o sort.o utils.o
```

我们知道，`Makefile` 中的第一个目标会被作为其默认目标。我们声明了一个 all 的伪目标，其依赖于其它三个目标。由于伪目标的特性是，总是被执行的，所以其依赖的那三个目标就总是不如 all 这个目标新。所以，其它三个目标的规则总是会被决议。也就达到了我们一口气生成多个目标的目的

`.PHONY : all`

声明了“all”这个目标为“伪目 标”。 随便提一句，从上面的例子我们可以看出，目标也可以成为依赖。所以，伪目标同样也可成 为依赖。看下面的例子：

```makefile
.PHONY: cleanall cleanobj cleandiff
cleanall : cleanobj cleandiff
	rm program
cleanobj :
	rm *.o
cleandiff :
	rm *.diff
```



  “make clean”将清除所有要被清除的文件。cleanobj 和 cleandiff 这两个伪 目标有点像“子程序”的意思。我们可以输入 `make cleanall` 和 `make cleanobj` 和 `make cleandiff` 命令来达到清除不同种类文件的目的

#### 多目标

Makefile 的规则中的目标可以不止一个，其支持多目标，有可能我们的多个目标同时依赖 于一个文件，并且其生成的命令大体类似，于是我们就能把其合并起来

当然，多个目标的生成规则的执行命令是同一个，这可能会可我们带来麻烦，不过好在我们的可以使用一个自 动化变量 $@（关于自动化变量，将在后面讲述），这个变量表示着目前规则中所有的目标的集合，这样说可能很抽象，还是看一个例子吧

```makefile
bigoutput littleoutput : text.g
	generate text.g -$(subst output,,$@) > $@ 
#上述规则等价于：
bigoutput : text.g
	generate text.g -big > bigoutput 
littleoutput : text.g 
	generate text.g -little > littleoutput
```

其中，`-$(subst output,,$@)` 中的 $ 表示执行一个 `Makefile` 的函数，函数名 为 subst，后面的为参数，关于函数，将在后面讲述

这里的这个函数是截取字符串的意思， $@ 表示目标的集合，就像一个数组，$@ 依次取出目标，并执于命令

#### 静态模式

静态模式可以更加容易地定义多目标的规则，可以让我们的规则变得更加的有弹性和灵活。 我们还是先来看一下语法

```makefile
<targets ...>: <target-pattern>: <prereq-patterns ...> 
	<commands> 
 ...
```

* targets 定义了一系列的目标文件，可以有通配符，是目标的一个集合
* target-pattern 是指明了 targets 的模式，也就是的目标集模式
* prereq-patterns 是目标的依赖模式，它对 target-pattern 形成的模式再进行 一次依赖目标的定义

如果我们的 定义成 %.o，意思是我们的集合中都是以 .o 结尾 的，而如果我们的定义成 %.c，意思是对所形成的目标集进行二次定义，其计算方法是，取模式中的 %（也 就是去掉了 .o 这个结尾），并为其加上 .c 这个结尾，形成的新集合。 所以，我们的目标模式或是依赖模式中都应该有 % 这个字符，如果你的文件名 中有 % 那么你可以使用反斜杠 \ 进行转义，来标明真实的 % 字符

```makefile
objects = foo.o bar.o 
all: $(objects) 
$(objects): %.o: %.c 
	$(CC) -c $(CFLAGS) $< -o $@
```

上面的例子中，指明了我们的目标从 $object 中获取，%.o 表明要所有以 .o 结尾的目标，也就是 foo.o bar.o，也就是变量 $object 集合的模式，而依赖模式 %.c 则取模式 %.o 的 %，也就是 foo bar，并为其加下 .c 的后缀，于是，我们的依赖目标就是 foo.c bar.c。而命令中的 $< 和 $@ 则是自动化变量， $< 表示所有的依赖目标集（也就是 foo.c bar.c），$@ 表示目标集（也就是 foo.o bar.o）。 于是，上面的规则展开后等价于下面的规则

```makefile
foo.o : foo.c
	$(CC) -c $(CFLAGS) foo.c -o foo.o
bar.o : bar.c
	$(CC) -c $(CFLAGS) bar.c -o bar.o 
```

试想，如果我们的 %.o 有几百个，那种我们只要用这种很简单的静态模式规则就可以写完一堆规则，实在是太有效率了。静态模式规则的用法很灵活，如果用得好，那会一 个很强大的功能。再看一个例子

```makefile
 files = foo.elc bar.o lose.o 
 $(filter %.o,$(files)): %.o: %.c 
 	$(CC) -c $(CFLAGS) $< -o $@ 
 $(filter %.elc,$(files)): %.elc: %.el 
 	emacs -f batch-byte-compile $< 
```

#### 自动生成依赖性

在 Makefile 中，我们的依赖关系可能会需要包含一系列的头文件，比如，如果我们的 main.c 中有一句 `#include "defs.h"`，那么我们的依赖关系应该是

`main.o : main.c defs.h`

但是，如果是一个比较大型的工程，你必需清楚哪些 C 文件包含了哪些头文件，并且，你在加入或删除头文件时，也需要小心地修改 Makefile，这是一个很没有维护性的工作。为了避免这种繁重而又容易出错的事情，我们可以使用 C/C++编译的一个功能。大多数的 C/C++ 编译器都支持一个 -M 的选项，即自动找寻源文件中包含的头文件，并生成一个依赖关系

例如，如果我们执行下面的命令： cc -M main.c

其输出是： main.o : main.c defs.h

于是由编译器自动生成的依赖关系，这样一来，你就不必再手动书写若干文件的依赖关系， 而由编译器自动生成了。需要提醒一句的是，如果你使用 GNU 的 C/C++编译器，你得用“-MM” 参数，不然，“-M”参数会把一些标准库的头文件也包含进来

gcc -M main.c

输出是：

main.o: main.c defs.h /usr/include/stdio.h  /usr/include/features.h \  /usr/include/sys/cdefs.h /usr/include/gnu/stubs.h \  /usr/lib/gcc-lib/i486-suse-linux/2.95.3/include/stddef.h \  /usr/include/bits/types.h /usr/include/bits/pthreadtypes.h \  /usr/include/bits/sched.h /usr/include/libio.h \  /usr/include/_G_config.h /usr/include/wchar.h \  /usr/include/bits/wchar.h /usr/include/gconv.h \  /usr/lib/gcc-lib/i486-suse-linux/2.95.3/include/stdarg.h \  /usr/include/bits/stdio_lim.h  gcc -MM main.c 的输出则是： main.o: main.c defs.h  那么，编译器的这个功能如何与我们的 Makefile 联系在一起呢。因为这样一来，我们的 Makefile 也要根据这些源文件重新生成，让 Makefile 自已依赖于源文件？这个功能并不 现实，不过我们可以有其它手段来迂回地实现这一功能。GNU 组织建议把编译器为每一个源 文件的自动生成的依赖关系放到一个文件中，为每一个“name.c”的文件都生成一个 “name.d”的 Makefile 文件，[.d]文件中就存放对应[.c]文件的依赖关系。 于是，我们可以写出[.c]文件和[.d]文件的依赖关系，并让 make 自动更新或自成[.d]文 件，并把其包含在我们的主 Makefile 中，这样，我们就可以自动化地生成每个文件的依赖 关系了。 这里，我们给出了一个模式规则来产生[.d]文件： %.d: %.c  @set -e; rm -f $@; \  $(CC) -M $(CPPFLAGS) $< > $@.$$$$; \  sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \  rm -f $@.$$$$   这个规则的意思是，所有的[.d]文件依赖于[.c]文件，“rm -f $@”的意思是删除所有的 目标，也就是[.d]文件，第二行的意思是，为每个依赖文件“$<”，也就是[.c]文件生成 依赖文件，“$@”表示模式“%.d”文件，如果有一个 C 文件是 name.c，那么“%”就是“name”， “$$$$”意为一个随机编号，第二行生成的文件有可能是“name.d.12345”，第三行使用 sed 命令做了一个替换，关于 sed 命令的用法请参看相关的使用文档。第四行就是删除临时 文件。 总而言之，这个模式要做的事就是在编译器生成的依赖关系中加入[.d]文件的依赖，即把依 赖关系： main.o : main.c defs.h  转成： main.o main.d : main.c defs.h  于是，我们的[.d]文件也会自动更新了，并会自动生成了，当然，你还可以在这个[.d]文 件中加入的不只是依赖关系，包括生成的命令也可一并加入，让每个[.d]文件都包含一个完 赖的规则。一旦我们完成这个工作，接下来，我们就要把这些自动生成的规则放进我们的主 Makefile 中。我们可以使用 Makefile 的“include”命令，来引入别的 Makefile 文 件（前面讲过），例如： sources = foo.c bar.c  include $(sources:.c=.d)  上述语句中的“$(sources:.c=.d)”中的“.c=.d”的意思是做一个替换，把变量 $(sources)所有[.c]的字串都替换成[.d]，关于这个“替换”的内容，在后面我会有更 为详细的讲述。当然，你得注意次序，因为 include 是按次来载入文件，最先载入的[.d] 文件中的目标会成为默认目标。

## 六、**书写命令**

每条规则中的命令和操作系统 Shell 的命令行是一致的。make 会一按顺序一条一条的执行命令，每条命令的开头必须以[Tab]键开头，除非，命令是紧跟在依赖规则后面的分号后的。 在命令行之间中的空格或是空行会被忽略，但是如果该空格或空行是以 Tab 键开头的，那么 make 会认为其是一个空命令。 我们在 UNIX 下可能会使用不同的 Shell，但是 make 的命令默认是被“/bin/sh”——UNIX 的标准 Shell 解释执行的。除非你特别指定一个其它的 Shell。Makefile 中，# 是注释符，很像 C/C++中的 //，其后的本行字符都被注释

## 七、**使用变量**
## 八、**使用条件判断**
## 九、**使用函数**
## 十、**make的运行**
## 十一、**隐含规则**
## 十二、**使用make更新函数库文件**