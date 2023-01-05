# C/C++socket网络编程
## **前言**
### *分文件编写基础:*
* *以下宏定义代码是为了防止头文件重复包含*
```c
#ifndef _TCPSOCKET_H_
#define _TCPSOCKET_H_

#endif
```
### *所需头文件*
```c
//Windows平台的网络库头文件
#include<winSock2.h>
#pragma comment(lib,"wsa2_32.lib")

//包含布尔类型头文件
#include<stdbool.h>
```
### *名词解释*  
* wsa(windows socket async)即windows异步套接字  
### *函数说明*  
`WSAStartup(param1,param2);`
* param1:请求的socket版本 2.2 2.1 1.0
使用宏MAKEWORD(2,2)传入两个字节
* param2:传出参数

`WSAGetLastError()`
* 获取异步套接字的最后一个错误
```c
//初始化
bool init_Socket(){
    WSADATA wsadata;
    if(0 != WSAStartup(MAKEWORD(2,2),&wsadata)){
        printf("WSAStartup failed code %d",WSAGetLastError());
        return false;
    }
    return true;
}
```
`WSACleanup()`
* 清理网络库
```c
//关闭
bool close_Socket(){
    if(0 != WSACleanup()){
        printf("WSACleanup failed code %d",WSAGetLastError());
        return false;
    }
    return true;
}
```
`socket(param1,param2,param3)`
* param1:int af
    * 地址协议簇 ipv4 ipv6
* param2:int type
    * 传输协议类型 流式套接字 数据报套接字
* param3:int protocol
    * 使用具体的某个传输协议
```c
SOCKET createServerSocket(){
    //1.创建空的Socket
    SOCKET fd = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
    return 0;
}
```

### *带参宏编写*
```c
#define err(errMsg) printf("[line:%d]%s failed code %d"__LINE__,,errMsg,WSAGetLastError())
```
