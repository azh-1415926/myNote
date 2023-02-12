# **Linux 系统编程笔记**

## **Linux Shell 编程**

**什么是 Shell**

* Linux中的Shell作为用户与操作系统的接口，是用户使用操作系统的窗口。Shell 既是命令解释器，又是一种编程语言。作为命令解释器，Shell 是一个终端窗口，接收用户输入的命令，识别、解释、执行该命令，并向用户返回结果，Shell 的功能类似于Windows系统中的cmd.exe程序
  
* 作为编程语言，Shell 提供了变量、流程控制结构、引用、函数、数组等功能，可将公共程序、系统工具、用户程序“粘合”在一起，创建Shell脚本(又称 Shell 程序)，实现更加复杂的应用功能

**Shell 可以做什么**

* Linux系统的很多管理任务是通过Shell 脚本实现的，例如，Linux 系统启动过程就是通过运行/etc/rc.d目录中
  的脚本来执行系统配置和建立服务的

* Shell 脚本还用于用户工作环境的定制，如Java开发环境、Android开发环境、大数据应用开发环境等，都是通过Shell 脚本来设置的。掌握一些基本的Shell脚本编程知识对操作、使用Linux有帮助。每个Linux系统发行版本中都包含多种Shell, - -般有Bash、Boume Shell、TC Shell、C Shell和Kom Shell 等。其中，Bash 是Boume-Again Shell 的英文缩写，它吸收和继承了其他Shell的优点，成为当前应用最广泛的Shell,是Linux Shell的事实标准

### **一、Shell 编程基本概念**

Shell 脚本就是由很多 Linux 命令通过 Shell 控制结构粘合起来构成的文本文件, 一个 Shell 脚本可当作一条 Linux 命令来执行，以高效方式完成较为复杂的管理控制功能，Shell 脚本又称 Shell 程序

**Shell 脚本程序的结构**

组成 Shell 脚本的语句可包括 Linux 命令、赋值语句、输入输出语句和流程控制结构

Shell脚本程序本身并不含CPU直接执行的机器指令，其中的指令或语句由第1行指定的 Shell 命令解释器解释执行。运行Shell脚本程序实际上是执行/bin/bash, bash 从脚本文件中逐条读入Shell指令，解释执行，Shell 脚本实际上只是bash的一个数据文件。因此，Shell脚本的运行方法是 `bash 脚本文件.sh`

**Shell 变量与赋值表达式**

Shell程序中一些命令产生的数据常常会被传给其他命令以做进一步处理，这可以通过变量来完成。变量允许临时性存储信息，供脚本中的其他命令使用，用户变量可以是任何不超过20个字母、数字或下划线的文本字符串，用户变量区分大小写，所以变量Varl和变量varl是不同的。Shell 变量的使用非常灵活，不必事先定义变量，在给变量赋值时会自动获得定义。Shell 变量值的类型都是字符串，可以将任何字符串赋值给变量。值通过等号直接赋给用户变量，在变量、等号和值之间不能出现空格。如果字符串值的中间有空格，应用引号括
起

Shell变量的赋值表达式可以由字符串常量、Shell 变量引用、Linux命令输出直接拼接而成，但要注意以下几点:

* 为区分字符串常量和变量引用，Shell 要求通过美元符号($)来引用变量

* 若被引用的Shell 变量名后紧接着字母、数字、下划线等字符，则应将变量名用花括号({})
  括起，否则bash无法从中正确提取变量名

* 为区分赋值表达式中的Linux命令和字符串常量，Linux 命令需要用反引号( ")括起。

* 未经定义的Shell变量也可引用，只是变量值为空值，当然赋值表达式的值也可用命令echo直接显示输出，在echo命令中，串表达式的中间允许存在空格而两边不用加引号

**Shell 输入输出语句**

echo

read

终止脚本执行和终止状态

Linux 将进程(命令、脚本的执行)的终止状态保持在一个特殊的 Shell 变量`?`中，可在进程结束时，立即读取该变量的值以获取前一个命令或脚本的终止状态

脚本执行 `exit 状态码`可以让变量`？`读取指定的终止状态码，若没有指定状态码，则读取最后一条指令的终止状态码

### **二、Shell 数学运算与字符串处理**

**Shell 数学运算**

一般编程语言都应提供数学运算功能，bash 虽然将所有变量看作是字符串，不便进行数学运算，但也提供了两种实施数学运算的机制

* `expr expression` 命令
* `$[expression]`

**Shell 字符串处理**

Bash Shell 本身没有库函数，对字符串处理的支持主要通过 `expr`、`awk` 等命令实现

* 抽取字符串
  * `expr substr` 字符串 开始索引 长度
    * 如 expr substr "abcd" 2 2
  * `${str:起始位置}`
  * `${str:起始位置:长度}`
* 计算字符串的长度
  * `${#string}`
  * `expr length $string`
* 计算字串出现的位置
  * `expr index $substring` (找不到返回0或1)
* 返回匹配到的子串的长度
  * `expr match $string substring` (找不到返回0)
* 删除字符串
  * `${string#substring}` (删除string开头处与substring匹配的最短字符子串)
  * `${string##substring}` (删除string开头处与substring匹配的最长字符子串)

### **三、Shell 条件与if 控制结构**

bash 可以对 Shell 脚本进行流程控制，提供 if、case 和for 等控制结构，使 Shell 具有 C、Java 等高级语言的流程控制能力，这些控制结构具有较好的结构化特征，称为结构化命令

**if 语句**

if 语句是包括汇编在内几乎所有编程语言必须提供的流程控制结构

```shell
# 不带else
if command
then
	commands
fi

# 带else
if command
then
	commands
else
	commands
fi

# elif
if command
then
	commands
elif command
then
	commands
elif command
then
	commands
fi
```

**test 命令**

if 语句行都以普通的 Shell 命令作为评判条件，但 bash 还需要具有通常意义上的条件检测能力，比如数值比较、文件属性检查、字符串比较等，Linux 提供了 test 命令来实现这些功能，根据test 计算出条件值为 true，则 test 命令将其终止状态码设为 0，test 命令格式很简单 `test condition`，test 可以进行数值比较、字符串比较、文件比较，因此 test 命令还能够测试Linux 文件系统中文件状态和路径

在 if 语句中使用 test 命令

```shell
if test condition
then
	commands
fi

# 还可以用一对方括号内定义 test 条件
# 注意：方括号内的左右两边需要用空格隔开，否则会得到错误信息
if [ condition ]
then
	commands
fi
```

* 数值比较

  * `n1 -eq n2` 检查 n1 是否等于 n2

  * `n1 -ge n2` 检查 n1 是否大于等于 n2

  * `n1 -gt n2` 检查 n1 是否大于 n2

* 字符串比较

  * `str1 = str2` 检查 str1 与 str2 是否相同

  * `str != str2` 检查 str1 与 str2 是否不同

  * `str < str2` 检查 str1是否小于 str2

  * `str > str2` 检查 str1是否大于 str2

  * `-n str1` 检查 str1 的长度是否大于 0

  * `-z str1` 检查 str1 的长度是否等于 0

* 文件比较(文件属性测试是经常需要用到的功能)

  * `-d file` 检查 file 是否存在并且是一个目录

  * `-e file` 检查 file 是否存在

  * `-f file` 检查 file 是否存在并且是一个文件

  * `-r file` 检查 file 是否存在并且可读

  * `-s file` 检查 file 是否存在并且不为空

  * `-w file` 检查 file 是否存在并且可写

  * `-x file` 检查 file 是否存在并且可执行

  * `-O file` 检查 file 是否存在并且被当前用户拥有

  * `-G file` 检查 file 是否存在并且默认值为当前用户组

  * `file1 -nt file2` 检查 file1 是否比 file2 新

  * `file1 -oz file2` 检查 file1 是否比 file2 旧

**case 语句**

case 语句也是一种常用的控制结构，bash 的 case 结构比 C 语言的 case 结构更为灵活，使用更加方便，case 命令以列表导向格式检查单个变量的多个值

```shell
case variable in
	pattern1 | pattern2) commands;;
	pattern2) commands;;
	*) default commands;;
esac
# case 命令对指定的变量与不同的模式进行比较，相匹配便执行对应的命令
# 可在一行中列出多个模式，使用 | 将每个模式分开‘
# * 代表与任何列出来的模式都不匹配的所有值
```

示例

```shell
#!/bin/bash
user=rich
case $user in
rich|barbara)
echo user is rich or barbara.
cat)
echo user is cat.
*)
echo sorry,no match.
esac
```



### **四、循环结构**

循环控制也是 Shell 脚本流的一些结构化命令，能将过程和命令通过一组命令循环，知道满足某个特定条件，Bash Shell 循环命令有 for、while、until

**for 循环结构**

bash 提供的 for 命令用于创建基于列表的循环，循环变量依次取列表中的每个值，然后执行循环体

```shell
for var in list
do
	commands
done
# 参数 list 用于提供一系列用于迭代的值，在循环体中可以用迭代的变量名 $var 引用当前迭代变量 var，即当前迭代的列表项值

```

示例

```shell
# 还可以通过运行命令产生列表 list，命令应用反引号括起来
#!/bin/bash
file="states"
for state in `cat $file`
do
	echo The $state is in file.
done
# 列表中也可用通配符对目录进行读取
```

**while 循环结构**

while 命令有点像 if-then 和 for 循环的结合

```shell
while test command
do
	commands
done
# 使用 while 命令时，对应指定的 test 命令的终止状态为 0 便继续执行循环体
```

**until 循环结构**

until 命令刚好与 while 命令相反，当 test 命令的终止状态产生非 0 的终止状态时执行循环体

```shell
until test command
do
	commands
done
```

### **五、Linux 全局变量和环境变量**

**Linux Shell 层次结构**

**Shell 全局变量与局部变量**

Bash Shell 中有两种类型的变量，分别是全局变量与局部变量

全局变量是指在所有 Shell 中都可见的 Shell 变量，而局部变量是仅在创建它的 Shell 中可见的变量

局部变量是通过直接赋值而创建的 Shell 变量，而全局变量则是用 export 命令处理过的局部变量

**Linux 环境变量**

在Linux系统中，包括Shell脚本在内的应用程序、系统程序经常需要获取系统配置信息、用户身份信息、运行环境信息。Linux 系统将这些信息保存在- -组环境变量中，供应用程序、系统程序读取。Linux 环境变量是用来保存系统配置信息、用户身份信息、运行环境信息的全局Shell变量。虽然Linux环境变量-般都是全局Shell变量，但由系统定义的环境变量通常用大写英文单词命名，而用户自定义的全局变量则用小写英文单词命名。在应用中，我们经常也将用户自定义的全局变量称为环境变量

系统环境变量实际上是在Linux系统启动、用户登录、创建Shell会话(打开命令窗口)的过程中，执行特定初始化脚本创建的全局变量。在Linux和Windows'下，Java、 Android、 大数据等开发平台都普遍使用环境变量来设置开发环境和运行环境。使用C/C++、Java、 Perl、Python等语言编写的程序都提供了相应的设施来访问系统环境变量

Linux 查看所有环境变量的命令 env、printenv 等

1. ***命令搜索路径环境变量 PATH***

PATH 环境变量定义了Linux系统的命令搜索目录列表

当我们在终端窗口中输入一个命令时，bash 就会依次搜索PATH 环境变量中的每个目录。如果找到-一个以命令串为文件名的可执行文件，bash 就加载执行该文件，如果所有目录都不包含命令文件，bash 就显示“command not found" (命令未找到)错误，并设置终止状态码为 127

2. ***开发工具安装位置变量***

Linux系统下的很多开发工具，如Java、Spark、Tomcat、Hadoop等，当把它们安装到系统中时,安装程序通常会为每种工具创建一个环境变量，保存它们的安装位置，一般取名为“大写的工具名称_ HOME"，如JAVA_ HOME、SPARK_ HOME、TOMCAT_ HOME、HADOOP_ HOME等

这些软件本身会携带一系列操作命令，一般放在其子 目录bin中。因此，为了方便运行这些命令，一般应该手工或自动将相应的bin目录添加到环境变量PATH的目录列表中。比如，安装Hadoop后，就应该将$HADOOP_ HOME/bin 添加到PATH中

采用命令行方法添加开发工具命令目录后，只有该窗口能直接运行开发工具命令，而且每次打开新的窗口时，都必须重新设置PATH环境变量。如果希望每次开机后系统自动设置好PATH路径列表，则应将设置PATH路径的命令放到初始化脚本文件中。系统初始化脚本有多个，在Ubuntu中，/etc/profile 是系统初始化脚本，放在该文件中的设置对所有用户生效;，$HOME/profile 是用户登录初始化脚本，放在该文件中的设置对所有新打开的终端窗口和应用程序生效，而$HOME/.bash re 是终端窗口初始化脚本，放在该文件中的设置仅对当前窗口初始化有效

3. ***C/C++ 应用开发与运行相关环境变量***

C/C++应用开发与运行相关环境变量有三个: LD LIBRARY_ PATH、C_ INCLUDE PATH、
CPP_ INCLUDE_ PATH。其中，LD_ LIBRARY_ PATH变量保存应用程序运行时搜索到的自定义或
第三方共享库(动态库)路径列表; C_ INCLUDE PATH变量保存第三方C语言库函数API的头文件
目录列表，作为gcc 默认查找的头文件目录; CPP INCLUDE PATH变量保存第三方C++库函数
API的头文件目录列表，作为g+默认查找的头文件目录

**Shell 变量的删除和只读设置方法**

赋值后的 Linux 变量需要占用内存，如果确定以后不再使用，则可用命令 unset 删除它，局部变量和全局变量都可以该命令删除

Shell变量一般都是可读性的，但可用内置命令 readonly 或 declare -r 给变量设置只读属性，定义只读变量，变量定义为只读之后不允许再被赋值

Shell 数组的定义和使用方法

bash 可用定义一堆数组，但不支持多维数组

```shell
array_name=(value1 value2 ... values)
# 或者
array_name[i]=value1
# 引用 Shell 数组元素时，必须用花括号括起数组元素名
echo ${array_name[0]}
```

### **六、Linux 文件I/O、I/O 重定向和管道**

**标准文件描述符**

Linux 系统以文件处理功能见长，它把普通文件、I/O设备、网络连接都看成文件，从而便于将输入输出设备、网络通信连接同统一看成文件I/O，简化 I/O 概念和 I/O 编程

Linux 使用文件描述符(file descriptor)标识每个文件对象，文件描述符是一个非负整数，每个进程中有多达 1024 个文件描述符(实际限额可用命令 ulimit 查看和设置)

前三个文件描述符 0、1、2 用于特殊用途，分别称为标准输入 STDIN、标准输出 STDOUT、标准错误输出 STDERR

* 标准输入是指脚本程序执行 read 命令或 C 程序执行 scanf 操作时，输入数据来自的地方，一般是指键盘，文件描述符是 0 

* 标准输出是 Shell 中 echo 语句或 Linux 命令程序执行 printf 等语句时产生的输出流向的地方，一般是终端或监视器，文件描述符是 1

* 标准错误输出是命令执行过程中产生的出错送往的位置，一般是终端或显示器，文件描述符是 2

出错信息是命令执行过程中因找不到命令、命令拼写错误、文件无执行权限、待访问文件不存在等导致命令无法正常执行输出的错误，显示格式一般为"命令名:错误描述"，如 "ls:cannot access bad file:No such file or directory"

**I/O 重定向**

有时想将命令输出存入文件，而不是在命令窗口或终端显示;有时希望从文件获得输入，而不
是从键盘。由于Linux将I/O设备统- -看成文件，因此通过将文件描述符0、1. 2改为指向相应的
文件就可做到。Linux 通过输入/输出(I/O)重定向机制来提供这种功能
输出重定向

1.输出重定回
输出重定向是将本来送往命令窗口的输出信息，改为送往指定文件。要将输出重定向到文件，
只需要在命令名后加大于符号(>)和文件名 `command > outfile`
如果要将命令输出附加到现有文件内容之后，而不是重写文件内容，可以用两个大于号(>>)进
行重定向

2.输入重定向
输入重定向与输出重定向类似，它使原先需要从终端命令窗口读取的输入信息改从指定文件读
取。输入重定向符号是小于符号(<) `command < infile`

3.标准错误输出重定向

如果需要重定向，可使用重定向符号2 >，将原本送往 STDERR 的错误信息送到指定文件

**管道**
Linux系统中经常需要将一条命令(或脚本)的输出送往另- -个命令(或脚本)，这样可以给操作管
理带来极大方便，Linux提供的管道机制用来满足这种需求，管道符为 |  `command1 | command2`

### **七、命令行参数**

向Shell脚本传递数据的另一种常用方 式是使用命令行参数(command line parameter)。使用命令
行参数可以在执行脚本时向命令行中添加数据

Bash Shell 将在命令行中输入的所有参数赋值给一些称为位 置参数(positional parameter)的特殊
变量。bash 位置参数的取名就是- - -个十进制数字，赋值操作在脚本启动时由bash完成，脚本代码可
以引用它们的值。bash 位置参数的含义固定，引用它们的值时，$o为脚本程序的完整路径，$1 为
第一个命令行参数，$2为第二个命令行参数，依此类推，直到S9 为第九个命令行参数

需要注意的是:当某个命令行参数是一个中间包含空格的字符串时，该参数必须用引号括起，
否则会被bash拆分成多个命令行参数

### **八、Shell 函数**

编写比较复杂的Shell脚本时，一些公共代码可能需要重复使用，以提高编程效率，函数是被赋予名称的脚本代码块，可以在代码的任意位置重用

**函数的基本用法**

不使用 function 关键字，需在函数名后加一对圆括号，然后接着一对花括号及代码块

使用关键字 function，指定函数名，后接花括号及代码块,调用函数直接用函数名即可，函数名与花括号直接需要用空格隔开

函数的引用不需要使用括号，直接用函数名即可，可以在函数名后面写上需要传入的参数，并用空格隔开，和命令行传参一样

```shell
name1(){
	commands
}

function name2(){
	commands
}

function name3 {
	commands
}

name1 cat dog
name2 cat dog
name3 cat dog
```

**向函数传递参数**
可以使用标准环境变量给函数传递参数，例如，函数名在变量$0中定义，函数命令行的其他参
数使用变量$1和$2等定义，专用变量 $# 可以用来确定传递给函数的参数数目，专用变量 $@ 代表了传入的所有参数，可以直接当成迭代的列表

```shell
#!/bin/bash
function myecho{
	for i in $@
	do
		echo $i
	done
}
myecho hi hello nihao
```

