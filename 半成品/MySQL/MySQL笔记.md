# **MySQL笔记**
## **一、介绍与准备**
* ### **SQL的介绍**
    * A DATABASE is a collection of data stored in a format that can easily be accessed
数据库是一个以易访问格式存储的数据集合
    * 为了管理我们的数据库 我们使用一种叫做数据库管理系统（DBMS, Database Management System）的软件。我们连接到一个DBMS然后下达查询或者修改数据的指令，DBMS就会执行我们的指令并返回结果
    * DBMS被归为两大类，关系型(Relational)和非关系型(NoSQL)两类数据库，在更流行的关系型数据库中，我们把数据存储在通过某些关系相互关联的数据表中，每张表储存特定的一类数据，这正是关系型数据库名称的由来。（如：顾客表通过顾客id与订单表相联系，订单表又通过商品id与商品表相联系）
    * SQL（Structured Query Language，结构化查询语言）是专门用来处理（包括查询和修改）关系型数据库的标准语言
    * 不同关系型数据库管理系统语法略有不同，但都是基于标准SQL，本课使用最流行的开源关系型数据库管理系统，MySQL

* ### **数据库的创建**
```mysql
CREATE database;
```
---
## **二、简单查询 | Simple Queries**
### 1. **选择语句 | The SELECT**
#### **示例**
```sql
USE sql_store;  --选择数据库

SELECT *    -- 纵向筛选列
--SELECT 1, 2  --甚至可以是常数
FROM customers  -- 选择表
WHERE customer_id < 4  -- 横向筛选行
ORDER BY first_name  -- 排序

-- 单行注释

/*
多行注释
*/
```
### 2. **选择子句 | The SELECT Clause**
* *SELECT 是列/字段选择语句，可选择列，列间数学表达式，特定值或文本，可用AS关键字设置列别名（AS可省略），注意 DISTINCT 关键字的使用*
* *SQL会完全无视大小写（绝大数情况下的大小写）、多余的空格（超过一个的空格）、缩进和换行，SQL语句间完全由分号 ; 分割，用缩进、换行等只是为了代码看着更美观结构更清晰，这些与Python很不同，要注意*

#### **实例**
```sql
USE sql_store;

SELECT
    DISTINCT last_name, 
    -- 这种选择的字段中部分取 DISTINCT 的是如何筛选的？
    first_name,
    points,
    (points + 70) % 100 AS discount_factor/'discount factor'
    -- % 取余（取模）
FROM customers
```
#### **练习**
*将单价 unit_price 涨价10%作为新单价*
```sql
SELECT 
    name, 
    unit_price, 
    unit_price * 1.1 'new price'  
FROM products
```
* *如上面这个例子所示，取别名时，AS 可省，空格后跟别名就行，可看作是SQL会将将列变量及其数学运算之后的第一个空格识别为AS*
---
### 3. **WHERE子句 | The WHERE Clause**
* *WHERE 是行筛选条件，实际是一行一行/一条条记录依次验证是否符合条件，进行筛选*  
* *比较运算符 > < = >= <= !=/<> ，注意等于是一个等号而不是两个等号*  

#### **实例**
```sql
USE sql_store;

SELECT *
FROM customers
WHERE points > 3000  

```
* *也可对日期或文本进行比较运算，注意SQL里日期的标准写法及其需要用引号包裹这一点*
```sql
--WHERE state != 'va'  -- 'VA'/'va'一样
--WHERE birth_date > '1990-01-01'
```
#### **练习**
*查询 2019 年 1 月 1 日起发出的所有订单*
```sql
USE sql_store;

select *
from orders
where order_date > '2019-01-01'
```
### 4. **AND,OR,NOT运算符 | The AND,OR,NOT Operators**
* *用逻辑运算符AND、OR、NOT对（数学和）比较运算进行组合实现多重条件筛选
执行优先级：数学→比较→逻辑*
#### **实例**
```sql
USE sql_store;

SELECT *
FROM customers
WHERE birth_date > '1990-01-01' AND points > 1000
/WHERE birth_date > '1990-01-01' OR 
      points > 1000 AND state = 'VA'
```
* *AND优先级高于OR，但最好加括号，更清晰*
```sql
WHERE birth_date > '1990-01-01' OR 
      (points > 1000 AND state = 'VA')
```
* *NOT的用法*
```sql
WHERE NOT (birth_date > '1990-01-01' OR points > 1000)
```
#### **练习**
*查询订单6中总价大于30的商品*
* *SELECT 子句，WHERE 子句以及后面的 ORDER BY 子句等都能用列间数学表达式*
```sql
USE sql_store;

SELECT * FROM order_items
WHERE order_id = 6 AND quantity * unit_price > 30
```
### 5. **IN运算符 | The IN Operator**
* *用IN运算符将某一属性与多个值（一系列值）进行比较
实质是多重相等比较运算条件的简化*

#### **实例**
*选出'va'、'fl'、'ga'三个州的顾客*
```sql
USE sql_store;

SELECT * FROM customers
WHERE state = 'va' OR state = 'fl' OR state = 'ga'
```
* *不能 state = 'va' OR 'fl' OR 'ga' 因为数学和比较运算优先于逻辑运算，加括号 state = ('va' OR 'fl' OR 'ga') 也不行，逻辑运算符只能链接布林值*
* *用 IN 操作符简化该条件,可用NOT*
```sql
WHERE state IN ('va', 'fl', 'ga')
--WHERE state NOT IN ('va', 'fl', 'ga')
```
#### **练习**
*库存量刚好为49、38或72的产品*
```sql
USE sql_store;

select * from products
where quantity_in_stock in (49, 38, 72)
```
### 6. **BETWEEN运算符 | The BETWEEN Operator**
* *用于表达范围型条件*
    * *用AND而非括号*
    * *闭区间，包含两端点*
    * *也可用于日期，毕竟日期本质也是数值，日期也有大小（早晚），可比较运算*
    * *同 IN 一样，BETWEEN 本质也是一种特定的 多重比较运算条件 的简化*
#### **实例**
*选出积分在1k到3k的顾客*
```sql
USE sql_store;

select * from customers
where points >= 1000 and points <= 3000
--等价为
--WHERE points BETWEEN 1000 AND 3000
```
#### **练习**
*选出90后的顾客*
```sql
SELECT * FROM customers
WHERE birth_date BETWEEN '1990-01-01' AND '2000-01-01'
```
### 7. **LIKE运算符 | The LIKE Operator**
* *模糊查找，查找具有某种模式的字符串的记录/行*
    * *过时用法（但有时还是比较好用，之后发现好像用的还是比较多的），下节课的正则表达式更灵活更强大*
    * *注意和正则表达式一样都是用引号包裹表示字符串*

#### **实例**
```sql
USE sql_store;
SELECT * FROM customers
WHERE last_name like 'brush%' / 'b____y'
```
  
* *引号内描述想要的字符串模式，注意SQL（几乎）任何情况都是不区分大小写的*
    * *% 任何个数（包括0个）的字符（用的更多）*
    * *_ 单个字符*

#### **练习**
*分别选择满足如下条件的顾客：*<br>
*1. 地址包含 'TRAIL' 或 'AVENUE'*<br>
*2. 电话号码以 9 结束*
```sql
USE sql_store;

select * 
from customers
where address like '%Trail%' or 
      address like '%avenue%'
```
* *LIKE 执行优先级在逻辑运算符之后，毕竟 IN BETWEEN LIKE 本质可看作是比较运算符的简化，应该和比较运算同级，数学→比较→逻辑，始终记住这个顺序，上面这个如果用正则表达式会简单得多*
```sql
where phone like '%9'
--where phone not like '%9'
```
### 8. **REGEXP运算符 | The REGEXP Operator**  
* *正则表达式，在搜索字符串方面更为强大，可搜索更复杂的模板*
#### **实例**
```sql
USE sql_store;

select * from customers
where last_name like '%field%'
--等价于
--where last_name regexp 'field'
```
* *regexp 是 regular expression（正则表达式） 的缩写*
* *正则表达式可以组合来表达更复杂的字符串模式*
```sql
where last_name regexp '^mac|field$|rose' 
where last_name regexp '[gi]e|e[fmq]' -- 查找含ge/ie或ef/em/eq的
where last_name regexp '[a-h]e|e[c-j]'
```
符号 | 意义
--- | ---
^ | 开头
--- | ---
$ | 结尾
[abc] | 含abc
[a-c] | 含a到c
| |logical or
#### **练习**
*分别选择满足如下条件的顾客：*<br>
*1. first names 是 ELKA 或 AMBUR*<br>
*2. last names 以 EY 或 ON 结束*<br>
*3. last names 以 MY 开头 或包含 SE*<br>
*4. last names 包含 BR 或 BU*
```sql
select * 
from customers
where first_name regexp 'elka|ambur' --1
--where last_name regexp 'ey$|on$'  --2
--where last_name regexp '^my|se'   --3
--where last_name regexp 'b[ru]'/'br|bu'    --4
```
### 9. **IS NULL运算符 | The IS NULL Operator**
* *找出空值，找出有某些属性缺失的记录*
#### **实例**
*找出电话号码缺失的顾客*
```sql
USE sql_store;

select * from customers
where phone is null
--where phone is not null
```
#### **练习**
*找出还没发货的订单*
```sql
USE sql_store;

select * from orders
where shipper_id is null
```
### 10. **ORDER BY子句 | The ORDER BY Clause**
* *排序语句*
    * *可多列*
    * *可以是列间的数学表达式*
    * *可包括任何列，包括没选择的列（MySQL特性，其它DBMS可能报错）*
    * *可以是之前定义好的别名列（MySQL特性，甚至可以是用一个常数设置的列别名）*
    * *可以在排序依据列后加 DESC降序排序*
    * *省略排序语句的话会默认按主键排序*
#### **实例**
```sql
USE sql_store;

select name, unit_price * 1.1 + 10 as new_price 
from products
order by new_price desc, product_id
-- 这两个分别是 别名列 和 未选择列，都用到了 MySQL 特性
```
#### **练习**
*订单2的商品按总价降序排列:*<br>
```sql
--法1. 可以以总价的数学表达式为排序依据
select * from order_items 
where order_id = 2
order by quantity * unit_price desc
-- 列间数学表达式

--法2. 或先定义总价别名，在以别名为排序依据
select *, quantity * unit_price as total_price 
from order_items 
where order_id = 2
order by total_price desc
-- 列别名
```
### 11. **LIMIT子句 | The LIMIT Clause**
* *限制返回结果的记录数量，“前N个” 或 “跳过M个后的前N个”*
#### **实例**
```sql
USE sql_store;

select * from customers
limit 3 
--limit 300
--limit 6, 3
--6, 3 表示跳过前6个，取第7~9个，6是偏移量，
--如：网页分页 每3条记录显示一页 第3页应该显示的记录就是 limit 6, 3
```
#### **练习**
*找出积分排名前三的死忠粉*
```sql
USE sql_store;

select *
from customers
order by points desc 
limit 3
```
### 12. **注意事项 | 写在最后**
* *子句应严格按照以下顺序书写*
    * **select**
    * **from**
    * **where**
    * **order by**
    * **limit**
## **三、连接 | Joins**
### 1. **内连接 | Inner Joins**
* *各表分开存放是为了减少重复信息和方便修改，需要时可以根据相互之间的关系连接成相应的合并详情表以满足相应的查询*
* *在SELECT中给选定的列加别名主要是为了得到更有意义的列名*
* *选择多张表里都有的同名列时，必须加上表名前缀来明确列的来源*
#### **实例**
```sql
USE sql_store;

select 
    order_id, 
    o.customer_id, 
    first_name, 
    last_name
from orders as o
(inner) join customers c 
    on o.customer_id = c.customer_id
```
#### **练习**
*通过 product_id 链接 orders_items 和 products:*
```sql
USE sql_store;

select *
--select oi.*, p.name
--select 
    order_id, 
    oi.product_id,
    name, 
    quantity, 
    oi.unit_price
from order_items oi
join products p
    on oi.product_id = p.product_id
```
### 2. **跨数据库连接 | Joining Across Databases**
* *有时需要选取不同库的表的列，其他都一样，就只是WHERE JOIN里对于非现在正在用的库的表要加上库名前缀而已，依然可用别名来简化*
#### **示例**
```sql
use sql_store;

select * from order_items oi
join sql_inventory.products p
    on oi.product_id = p.product_id
--或者
use sql_inventory;

select * from sql_store.order_items oi
join products p
    on oi.product_id = p.product_id
```
### 3. **自连接 | Self Joins**
* *一个表和它自己合并。如下面的例子，员工的上级也是员工，所以也在员工表里，所以想得到的有员工和他的上级信息的合并表，就要员工表自己和自己合并，用两个不同的表别名即可实现。这个例子中只有两级，但也可用类似的方法构建多层级的组织结构*
* *自合并必然每列都要加表前缀，因为每列都同时在两张表中出现*
#### **示例**
```sql
USE sql_hr;

select 
    e.employee_id,
    e.first_name,
    m.first_name as manager
from employees e
join employees m
    on e.reports_to = m.employee_id
```
### 4. **多表连接 | Joining Multiple Tables**
* *FROM A 选取一个核心表A，用多个 JOIN 表 ON 关系 分别通过不同的链接关系链接不同的表B、C、D……，通常是让表B、C、D……为表A提供更详细的信息从而合并为一张详情合并版A表*
* *尽量选取数据较少的表作为核心表*
#### **实例**
*订单表同时链接顾客表和订单状态表，合并为有顾客和状态信息的详细订单表*
```sql
USE sql_store;

SELECT 
    o.order_id, 
    o.order_date,
    c.first_name,
    c.last_name,
    os.name AS status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_statuses os
    ON o.status = os.order_status_id
```
#### **练习**
*同理，支付记录表链接顾客表和支付方式表形成支付记录详情表*
```sql
USE sql_invoicing;

SELECT 
    p.invoice_id,
    p.date,
    p.amount,
    c.name,
    pm.name AS payment_method
FROM payments p
JOIN clients c
    ON p.client_id = c.client_id
JOIN payment_methods pm
    ON p.payment_method = pm.payment_method_id
```
### 5. **复合连接条件 | Compound Join Conditons**
* *像订单项目（order_items）这种表，订单id和产品id合在一起才能唯一表示一条记录，这叫复合主键，设计模式下也可以看到两个字段都有PK标识，订单项目备注表（order_item_notes）也是这两个复合主键，因此他们两合并时要用复合条件：FROM 表1 JOIN 表2 ON 条件1 【AND】 条件2*
#### **示例**
*将订单项目表和订单项目备注表合并*
```sql
USE sql_store;

SELECT * 
FROM order_items oi
JOIN order_item_notes oin
    ON oi.order_Id = oin.order_Id
    AND oi.product_id = oin.product_id
```
### 6. **隐式连接条件 | Implicit Join Syntax**
* *用FROM WHERE取代FROM JOIN ON*
* *尽量少用隐式连接，因为若忘记WHERE条件筛选语句，不会报错但会得到交叉合并（cross join）结果：即10条order会分别与10个customer结合，得到100条记录。最好使用显性合并语法，因为会强制要求你写合并条件ON语句，不至于漏掉*
#### **示例**
*合并顾客表和订单表，显性合并：*
```sql
USE sql_store;

SELECT * 
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
```
*隐式合并语法：*
```sql
SELECT * 
FROM orders o, customers c  
WHERE o.customer_id = c.customer_id
```
* *注意 FROM 子句里的逗号，就像 SELECT 多条列用逗号隔开一样，FROM 多个表也用逗号隔开，此时若忘记WHERE条件筛选语句则得到这几张表的交叉合并结果*
### 7. **外连接 | Outer Joins**
* *(INNER) JOIN 结果只包含两表的交集，另外注意“广播（broadcast）”效应
LEFT/RIGHT (OUTER) JOIN 结果里除了交集，还包含只出现在左/右表中的记录*
#### **实例**
*合并顾客表和订单表，用 INNER JOIN：*
* *INNER JOIN，只展示有订单的顾客（及其订单），也就是两张表的交集，但注意这里因为一个顾客可能有多个订单，所以INNER JOIN以后顾客信息其实是是广播了的，即一条顾客信息被多条订单记录共用，当然 这叫广播（broadcast）效应，是另一个问题，这里关注的重点是 INNER JOIN 的结果确实是两表的交集，是那些同时有顾客信息和订单信息的记录*
```sql
USE sql_store;

SELECT 
    c.customer_id,
    c.first_name,
    o.order_id
FROM customers c
JOIN orders o
    ON o.customer_id = c.customer_id
ORDER BY customer_id
```
* *若要展示全部顾客（及其订单，如果有的话），要改用LEFT (OUTER) JOIN，结果相较于 INNER JOIN 多了没有订单的那些顾客，即只有顾客信息没有订单信息的记录*
```sql
USE sql_store;
SELECT
    c.customer_id,
    c.first_name,
    o.order_id
FROM customers c
    LEFT OUTER JOIN orders o
    -- OUTER是可选项、可省略
    ON o.customer_id = c.customer_id
```
* *若要展示全部订单（及其顾客），就应该是 customers RIGHT JOIN orders，结果相较于 INNER JOIN 多了没有顾客的那些订单，即只有订单信息没有顾客信息的记录*
```sql
USE sql_store;
SELECT 
    c.customer_id,
    c.first_name,
    o.order_id
FROM customers c
    RIGHT OUTER JOIN orders o
    -- OUTER是可选项、可省略 
    ON o.customer_id = c.customer_id
```
#### **练习**
*展示各产品在订单项目中出现的记录和销量，也要包括没有订单的产品*
```sql
SELECT 
    p.product_id,
    p.name, -- 或者直接name
    oi.quantity -- 或者直接quantity
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
```
### 8. **多表外连接 | Outer Join Between Multiple Tables**
* *与内连接类似，我们可以对多个表（3个及以上）进行外连接，最好只用 JOIN 和 LEFT JOIN*
#### **实例**
*查询顾客、订单和发货商记录，要包括所有顾客（包括无订单的顾客），也要包括所有订单（包括未发出的）*
* *虽然可以调换顺序并用 RIGHT JOIN，但作为最佳实践，最好调整顺序并统一只用 [INNER] JOIN 和 LEFT [OUTER] JOIN（总是左表全包含），这样，当要合并的表比较多时才方便书写和理解而不易混乱*
```sql
USE sql_store;

SELECT 
    c.customer_id,
    c.first_name,
    o.order_id,
    sh.name AS shipper
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
LEFT JOIN shippers sh
    ON o.shipper_id = sh.shipper_id
ORDER BY customer_id
```
#### **练习**
*查询 订单 + 顾客 + 发货商 + 订单状态，包括所有的订单（包括未发货的），其实就只是前两个优先级变了一下，是要看全部订单而非全部顾客了*
```sql
USE sql_store;

SELECT 
    o.order_id,
    o.order_date,
    c.first_name AS customer,
    sh.name AS shipper,
    os.name AS status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN shippers sh
    ON o.shipper_id = sh.shipper_id
JOIN order_statuses os
    ON o.status = os.order_status_id
```
### 9. **自外连接 | Self Outer Joins**
* *就用前面那个员工表的例子来说，就是用LEFT JOIN让得到的 员工-上级 合并表也包括老板本人（老板没有上级，即 reports_to 字段为空，如果用 JOIN 会被筛掉，用 LEFT JOIN 才能保留）*
#### **示例**
```sql
USE sql_hr;

SELECT 
    e.employee_id,
    e.first_name,
    m.first_name AS manager
FROM employees e
LEFT JOIN employees m  -- 包含所有雇员（包括没有report_to的老板本人）
    ON e.reports_to = m.employee_id
```
### 10. **USING子句 | The Using Clause**
* *当作为合并条件（join condition）的列在两个表中有相同的列名时，可用 USING (……, ……) 取代 ON …… AND …… 予以简化，内/外链接均可如此简化*
* *一定注意 USING 后接的是括号，特容易搞忘*
#### **实例**
```sql
SELECT
    o.order_id,
    c.first_name,
    sh.name AS shipper
FROM orders o
JOIN customers c
    USING (customer_id)
LEFT JOIN shippers sh
    USING (shipper_id)
ORDER BY order_id
--复合主键表间复合连接条件的合并也可用 USING，中间逗号隔开就行

SELECT *
FROM order_items oi
JOIN order_item_notes oin

ON oi.order_id = oin.order_Id AND
    oi.product_id = oin.product_id
--等同于USING (order_id, product_id)
```
#### **练习**
*sql_invoicing库里，将payments、clients、payment_methods三张表合并起来，以知道什么日期哪个顾客用什么方式付了多少钱*
```sql
USE sql_invoicing;

SELECT 
    p.date,
    c.name AS client,
    pm.name AS payment_method,
    p.amount
FROM payments p
JOIN clients c USING (client_id)
JOIN payment_methods pm
    ON p.payment_method = pm.payment_method_id
```
### 11. **自然连接 | Natural Joins**
* *NATURAL JOIN 就是让MySQL自动检索同名列作为合并条件*
* *最好别用，因为不确定合并条件是否找对了，有时会造成无法预料的问题，编程时保持对结果的控制是非常重要的*
#### **示例**
```
sql
USE sql_store;

SELECT 
    o.order_id,
    c.first_name
FROM orders o
NATURAL JOIN customers c
```
### 12. **交叉连接 | Cross Joins**
* *得到名字和产品的所有组合，因此不需要合并条件。 实际运用如：要得到尺寸和颜色的全部组合*
#### **实例**
```sql
USE sql_store;

SELECT 
    c.first_name AS customer,
    p.name AS product
FROM customers c
CROSS JOIN products p
ORDER BY c.first_name
--上面是显性语法，还有隐式语法，之前讲过，其实就是隐式内合并忽略WHERE子句（即合并条件）的情况，也就是把 CROSS JOIN 改为逗号，即 FROM A CROSS JOIN B 等效于 FROM A, B，Mosh更推荐显式语法，因为更清晰

USE sql_store;

SELECT 
    c.first_name,
    p.name
FROM customers c, products p
ORDER BY c.first_name
```
#### **练习**
*交叉合并shippers和products，分别用显式和隐式语法*
```sql
USE sql_store;

SELECT 
    sh.name AS shippers,
    p.name AS product
FROM shippers sh
CROSS JOIN products p
ORDER BY sh.name
--或者

SELECT 
    sh.name AS shippers,
    p.name AS product
FROM shippers sh, products p
ORDER BY sh.name
```
### 13. **联合 | Unions**
* *FROM …… JOIN …… 可对多张表进行横向列合并，而 …… UNION …… 可用来按行纵向合并多个查询结果，这些查询结果可能来自相同或不同的表*
* *同一张表可通过UNION添加新的分类字段，即先通过分类查询并添加新的分类字段再UNION合并为带分类字段的新表*
* *不同表通过UNION合并的情况如：将一张18年的订单表和19年的订单表纵向合并起来在一张表里展示*
* *合并的查询结果必须列数相等，否则会报错*
* *合并表里的列名由排在 UNION 前面的决定*
#### **实例**
*给订单表增加一个新字段——status，用以区分今年的订单和今年以前的订单*
```sql
USE sql_store;

    SELECT 
        order_id,
        order_date,
        'Active' AS status
    FROM orders
    WHERE order_date >= '2019-01-01'

UNION

    SELECT 
        order_id,
        order_date,
        'Archived' AS status  -- Archived 归档
    FROM orders
    WHERE order_date < '2019-01-01';
--合并不同表的例子——在同一列里显示所有顾客名以及所有商品名

USE sql_store;

    SELECT first_name AS name_of_all
    -- 新列名由排UNION前面的决定
    FROM customers

UNION

    SELECT name
    FROM products
```
#### **练习**
*给顾客按积分大小分类，添加新字段type，并按顾客id排序，分类标准如下*
points | type
--- | ---
`<`2000|Bronze
2000`~`3000|Silver
`>`3000|Gold
```sql
SELECT 
        customer_id,
        first_name,
        points,
        'Bronze' AS type
    FROM customers 
    WHERE points < 2000

UNION

    SELECT 
        customer_id,
        first_name,
        points,
        'Silver' AS type
    FROM customers 
    WHERE points BETWEEN 2000 and 3000

UNION

    SELECT 
        customer_id,
        first_name,
        points,
        'Gold' AS type
    FROM customers 
    WHERE points > 3000

ORDER BY customer_id
```
* *ORDER BY的优先级在UNION之后*
## **四、插入、更新、删除语句 | INSERT、UPDATE、DELETE**
* *INSERT INTO 目标表 （目标列，可选，逗号隔开）
VALUES (目标值，逗号隔开)*
### 1. **插入单行 | Inserting a Row**
#### **示例**
*在顾客表里插入一个新顾客的信息*
```sql
--法1. 若不指明列名，则插入的值必须按所有字段的顺序完整插入

USE sql_store;

INSERT INTO customers -- 目标表
VALUES (
    DEFAULT,
    'Michael',
    'Jackson',
    '1958-08-29',  -- DEFAULT/NULL/'1958-08-29'
    DEFAULT,
    '5225 Figueroa Mountain Rd', 
    'Los Olivos',
    'CA',
    DEFAULT
    );

--法2. 指明列名，可跳过取默认值的列且可更改顺序，一般用这种，更清晰

INSERT INTO customers (
    address,
    city,
    state,
    last_name,
    first_name,
    birth_date,
    )
VALUES (
    '5225 Figueroa Mountain Rd',
    'Los Olivos',
    'CA',
    'Jackson',
    'Michael',    
    '1958-08-29',  
    )
```
### 2. *插入多行 | Inserting Multiple Rows**
* *VALUES …… 里一行内数据用括号内逗号隔开，而多行数据用括号间逗号隔开*
#### **实例**
*插入多条运货商信息*
```sql
USE sql_store

INSERT INTO shippers (name)
VALUES ('shipper1'),
       ('shipper2'),
       ('shipper3');
```
#### **练习**
*插入多条产品信息*
```sql
USE sql_store;

INSERT INTO products 
VALUES (DEFAULT, 'product1', 1, 10),
       (DEFAULT, 'product2', 2, 20),
       (DEFAULT, 'product3', 3, 30);

--或者

INSERT INTO products (name, quantity_in_stock, unit_price)
VALUES ('product1', 1, 10),
       ('product2', 2, 20),
       ('product3', 3, 30);
--更为清晰
```
### 3. *插入分层行 | Inserting Hierarchical Rows**
* *订单表（orders表）里的一条记录对应订单项目表（order_items表）里的多条记录，一对多，是相互关联的父子表。通过添加一条订单记录和对应的多条订单项目记录，学习如何向父子表插入分级（层）/耦合数据（insert hierarchical data）：*
    * *关键：在插入子表记录时，需要用内建函数 LAST_INSERT_ID() 获取相关父表记录的自增ID（这个例子中就是 order_id)*
    * *内建函数：MySQL里有很多可用的内置函数，也就是可复用的代码块，各有不同的功能，注意函数名的单词之间用下划线连接*
    * *LAST_INSERT_ID()：获取最新的成功的 INSERT 语句 中的自增id，在这个例子中就是父表里新增的 order_id*
#### **示例**
*新增一个订单（order），里面包含两个订单项目/两种商品（order_items），请同时更新订单表和订单项目表*
```sql
USE sql_store;

INSERT INTO orders (customer_id, order_date, status)
VALUES (1, '2019-01-01', 1);

-- 可以先试一下用 SELECT last_insert_id() 看能否成功获取到的最新的 order_id

INSERT INTO order_items  -- 全是必须字段，就不用指定了
VALUES 
    (last_insert_id(), 1, 2, 2.5),
    (last_insert_id(), 2, 5, 1.5)
```
### 4. **创建表复制 | Creating a Copy of a Table**
* *CREAT TABLE 新表名 AS 子查询*
* *INSERT INTO 表名 子查询*
* *DROP TABLE 要删的表名、CREATE TABLE 新表名 AS 子查询*
* *TRUCATE '要清空的表名'、INSERT INTO 表名 子查询*
#### **实例**
```sql
--快速创建表 orders 的副本表 orders_archived
USE sql_store;

CREATE TABLE orders_archived AS
    SELECT * FROM orders  -- 子查询

DROP TABLE orders_archived;
CREATE TABLE orders_archived AS
    SELECT * FROM orders
    WHERE order_date < '2019-01-01'

TRUNCATE 'orders_archived';
INSERT INTO orders_archived  
-- 不用指明列名，会直接用子查询表里的列名
    SELECT * FROM orders  
    -- 子查询，替代原先插入语句中VALUES(……,……),(……,……),…… 的部分
    WHERE order_date < '2019-01-01'
```
#### **练习**
*创建一个存档发票表，只包含有过支付记录的发票并将顾客id换成顾客名字*
```sql
USE sql_invoicing;

DROP TABLE invoices_archived;  

CREATE TABLE invoices_archived AS
    SELECT i.invoice_id, c.name AS client, i.payment_date  
    -- 为了简化，就选这三列
    FROM invoices i
    JOIN clients c
        USING (client_id)
    WHERE i.payment_date IS NOT NULL
    -- 或者 i.payment_total > 0
```
### 5. **更新单行 | Updating a Single Row**
* *UPDATE 表 SET 要修改的字段 = 具体值/NULL/DEFAULT/列间数学表达式 WHERE 行筛选*
#### **示例**
```sql
USE sql_invoicing;

UPDATE invoices
SET 
    payment_total = 100 --/ 0 / DEFAULT / NULL / 0.5 * invoice_total, 
    /*注意 0.5 * invoice_total 的结果小数部分会被舍弃，
    之后讲数据类型会讲到这个问题*/
    payment_date = '2019-01-01' --/ DEFAULT / NULL / due_date
WHERE invoice_id = 3
```
### 6. **更新多行 | Updating Multiple Rows**
#### **实例**
```sql
USE sql_invoicing;

UPDATE invoices
SET payment_total = 233, payment_date = due_date
-- 该客户的发票记录不止一条，将同时更改
WHERE client_id IN (3, 4)
```
#### **练习**
*让所有非90后顾客的积分增加50点*
```sql
USE sql_store;

UPDATE customers
SET points = points + 50
WHERE birth_date < '1990-01-01'
```
### 7. **在Updates中使用子查询 | Using Subqueries in Updates**
* *本质上是将子查询用在 WHERE…… 行筛选条件中*
#### **实例**
*更改发票记录表中名字叫 Yadel 的记录*
```sql
USE sql_invoicing;

UPDATE invoices
SET payment_total = 567, payment_date = due_date

WHERE client_id = 
    (SELECT client_id 
    FROM clients
    WHERE name = 'Yadel');
    -- 放入括号，确保先执行

-- 若子查询返回多个数据（一列多条数据）时就不能用等号而要用 IN 了：
WHERE client_id IN 
    (SELECT client_id 
    FROM clients
    WHERE state IN ('CA', 'NY'))
```
#### **练习**
*将 orders 表里那些 分数>3k 的用户的订单 comments 改为 'gold customer'*
```sql
USE sql_store;

UPDATE orders
SET comments = 'gold customer'
WHERE customer_id IN
    (SELECT customer_id
    FROM customers
    WHERE points > 3000)
```
### 8. **删除行 | Deleting Rows**
* *DELETE FROM 表 
WHERE 行筛选条件*
* *当然也可用子查询*
* *若省略 WHERE 条件语句会删除表中所有记录（和 TRUNCATE 等效？）*
#### **示例**
*选出顾客id为3/顾客名字叫'Myworks'的发票记录*
```sql
USE sql_invoicing;

DELETE FROM invoices
WHERE client_id = 
    (SELECT client_id  
    FROM clients
    WHERE name = 'Myworks')
```
## **五、汇总数据 | Roll Up**
### 1. **聚合函数 | Aggregate Functions**
* *聚合函数：输入一系列值并聚合为一个结果的函数*
#### **实例**
```sql
USE sql_invoicing;

SELECT 
    MAX(invoice_date) AS latest_date,  
    -- SELECT选择的不仅可以是列，也可以是数字、列间表达式、列的聚合函数
    MIN(invoice_total) lowest,
    AVG(invoice_total) average,
    SUM(invoice_total * 1.1) total,
    COUNT(*) total_records,
    COUNT(invoice_total) number_of_invoices, 
    -- 和上一个相等
    COUNT(payment_date) number_of_payments,  
    -- 【聚合函数会忽略空值】，得到的支付数少于发票数
    COUNT(DISTINCT client_id) number_of_distinct_clients
    -- DISTINCT client_id 筛掉了该列的重复值，再COUNT计数，会得到不同顾客数
FROM invoices
WHERE invoice_date > '2019-07-01'  -- 想只统计下半年的结果
```
#### **练习**
date_range | total_sales | total_payments | what_we_expect (the difference)
--- | --- | --- | ---
1st_half_of_2019			
2nd_half_of_2019			
Total
```sql
USE sql_invoicing;

    SELECT 
        '1st_half_of_2019' AS date_range,
        SUM(invoice_total) AS total_sales,
        SUM(payment_total) AS total_payments,
        SUM(invoice_total - payment_total) AS what_we_expect
    FROM invoices
    WHERE invoice_date BETWEEN '2019-01-01' AND '2019-06-30'

UNION

    SELECT 
        '2st_half_of_2019' AS date_range,
        SUM(invoice_total) AS total_sales,
        SUM(payment_total) AS total_payments,
        SUM(invoice_total - payment_total) AS what_we_expect
    FROM invoices
    WHERE invoice_date BETWEEN '2019-07-01' AND '2019-12-31'

UNION

    SELECT 
        'Total' AS date_range,
        SUM(invoice_total) AS total_sales,
        SUM(payment_total) AS total_payments,
        SUM(invoice_total - payment_total) AS what_we_expect
    FROM invoices
    WHERE invoice_date BETWEEN '2019-01-01' AND '2019-12-31'
```
### 2. **GROUP BY子句 | The GROUP BY Clause**
* *按一列或多列分组，注意语句的位置*
#### **实例**
*在发票记录表中按不同顾客分组统计下半年总销售额并降序排列*<br>
*计算各州各城市的总销售额*
```sql
USE sql_invoicing;

SELECT 
    client_id,  
    SUM(invoice_total) AS total_sales
    FROM invoices
WHERE invoice_date >= '2019-07-01'  -- 筛选，过滤器
GROUP BY client_id  -- 分组
ORDER BY invoice_total DESC

SELECT 
    state,
    city,
    SUM(invoice_total) AS total_sales
FROM invoices
JOIN clients USING (client_id) 
-- 别忘了USING之后是括号，太容易忘了
GROUP BY state, city  
-- 逗号分隔就行
-- 这个例子里 GROUP BY 里去掉 state 结果一样
ORDER BY state
```
#### **练习**
*在 payments 表中，按日期和支付方式分组统计总付款额*
```sql
USE sql_invoicing;

SELECT 
    date, 
    pm.name AS payment_method,
    SUM(amount) AS total_payments
FROM payments p
JOIN payment_methods pm
    ON p.payment_method = pm.payment_method_id
GROUP BY date, payment_method
-- 用的是 SELECT 里的列别名
ORDER BY date
```
### 3. **HAVING子句 | The HAVING Clause**
* *HAVING 和 WHERE 都是是条件筛选语句，条件的写法相通，数学、比较（包括特殊比较）、逻辑运算都可以用（如 AND、REGEXP 等等）*
    * *WHERE 是对 FROM JOIN 里原表中的列进行 事前筛选，所以WHERE可以对没选择的列进行筛选，但必须用原表列名而不能用SELECT中确定的列别名*
    * *相反 HAVING …… 对 SELECT …… 查询后（通常是分组并聚合查询后）的结果列进行 事后筛选，若SELECT里起了别名的字段则必须用别名进行筛选，且不能对SELECT里未选择的字段进行筛选。唯一特殊情况是，当HAVING筛选的是聚合函数时，该聚合函数可以不在SELECT里显性出现，见最后补充*
#### **实例**
*筛选出总发票金额大于500且总发票数量大于5的顾客*
```sql
USE sql_invoicing;

SELECT 
    client_id,
    SUM(invoice_total) AS total_sales,
    COUNT(*/invoice_total/invoice_date) AS number_of_invoices
FROM invoices
GROUP BY client_id
HAVING total_sales > 500 AND number_of_invoices > 5
-- 均为 SELECT 里的列别名
```
#### **练习**
*在 sql_store 数据库（有顾客表、订单表、订单项目表等）中，找出在 'VA' 州且消费总额超过100美元的顾客*
```sql
USE sql_store;

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM customers c
JOIN orders o USING (customer_id)  -- 别忘了括号，特容易忘
JOIN order_items oi USING (order_id)
WHERE state = 'VA'
GROUP BY 
    c.customer_id, 
    c.first_name, 
    c.last_name
HAVING total_sales > 100
```
### 4. **ROLLUP运算符 | The ROLLUP OPerator**
* *GROUP BY …… WITH ROLL UP 自动汇总型分组，若是多字段分组的话汇总也会是多层次的，注意这是MySQL扩展语法，不是SQL标准语法*
#### **实例**
1. *分组查询各客户的发票总额以及所有人的总发票额*<br>
2. *分组查询各州、市的总销售额（发票总额）以及州层次和全国层次的两个层次的汇总额*<br>
3. *分组查询特定日期特定付款方式的总支付额以及单日汇总和整体汇总*
```sql
USE sql_invoicing;
--1
SELECT 
    client_id,
    SUM(invoice_total)
FROM invoices
GROUP BY client_id WITH ROLLUP
--2
SELECT 
    state,
    city,
    SUM(invoice_total) AS total_sales
FROM invoices
JOIN clients USING (client_id) 
GROUP BY state, city WITH ROLLUP
--3
SELECT 
    date, 
    pm.name AS payment_method,
    SUM(amount) AS total_payments
FROM payments p
JOIN payment_methods pm
    ON p.payment_method = pm.payment_method_id
GROUP BY date, pm.name WITH ROLLUP
```
#### **练习**
*分组计算各个付款方式的总付款 并汇总*
```sql
SELECT 
    pm.name AS payment_method,
    SUM(amount) AS total
FROM payments p
JOIN payment_methods pm
    ON p.payment_method = pm.payment_method_id
GROUP BY pm.name WITH ROLLUP
```
## **六、复杂查询 | Complex Queries**
### 1. **子查询 | Subqueries**
* *子查询： 任何一个充当另一个SQL语句的一部分的 SELECT…… 查询语句都是子查询，子查询是一个很有用的技巧。子查询的层级用括号实现。*
#### **实例**
*在 products 中，找到所有比生菜（id = 3）价格高的*
* *子查询不仅可用在 WHERE …… 中，也可用在 SELECT …… 或 FROM …… 等子句中，本章后面会讲*
```sql
USE sql_store;

SELECT *
FROM products
WHERE unit_price > (
    SELECT unit_price
    FROM products
    WHERE product_id = 3
)
```
#### **练习**
*在 sql_hr 库 employees 表里，选择所有工资超过平均工资的雇员*
```sql
USE sql_hr;

SELECT *
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
)
```
### 2. **IN运算符 | The IN Operator**
#### **实例**
*在 sql_store 库 products 表中找出那些从未被订购过的产品*
```sql
USE sql_store;

SELECT *
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id
    FROM order_items
)
```
#### **练习**
*在 sql_invoicing 库 clients 表中找到那些没有过发票记录的客户*
```sql
USE sql_invoicing;

SELECT *
FROM clients
WHERE client_id NOT IN (
    SELECT DISTINCT client_id
    FROM invoices
)
```
### 3. **子查询vs连接 | Subqueries vs Joins**
* *子查询（Subquery）是将一张表的查询结果作为另一张表的查询依据并层层嵌套，其实也可以先将这些表链接（Join）合并成一个包含所需全部信息的详情表再直接在详情表里筛选查询。两种方法一般是可互换的，具体用哪一种取决于 效率/性能（Performance） 和 可读性（readability），之后会学习 执行计划，到时候就知道怎样编写并更快速地执行查询，现在主要考虑可读性*
#### **实例**
*找出从未订购（没有invoices）的顾客：*
```sql
--法1. 子查询
USE sql_invoicing;

SELECT *
FROM clients
WHERE client_id NOT IN (
    SELECT DISTINCT client_id
    /*其实这里加不加DISTINCT对子查询返回的结果有影响
    但对最后的结果其实没有影响*/
    FROM invoices
)

--法2. 链接表

USE sql_invoicing;

SELECT DISTINCT client_id, name …… 
-- 不能SELECT DISTINCT *
FROM clients
LEFT JOIN invoices USING (client_id)
-- 注意不能用内链接，否则没有发票记录的顾客（我们的目标）直接就被筛掉了
WHERE invoice_id IS NULL
```
#### **练习**
*在 sql_store 中，选出买过生菜（id = 3）的顾客的id、姓和名*
```sql
--法1. 完全子查询
USE sql_store;

SELECT customer_id, first_name, last_name
FROM customers
WHERE customer_id IN (  
    -- 子查询2：从订单表中找出哪些顾客买过生菜
    SELECT customer_id
    FROM orders
    WHERE order_id IN (  
        -- 子查询1：从订单项目表中找出哪些订单包含生菜
        SELECT DISTINCT order_id
        FROM order_items
        WHERE product_id = 3
    )
)

--法2. 混合：子查询 + 表连接

USE sql_store;

SELECT customer_id, first_name, last_name
FROM customers
WHERE customer_id IN (  
    -- 子查询：哪些顾客买过生菜
    SELECT customer_id
    FROM orders
    JOIN order_items USING (order_id)  
    -- 表连接：合并订单和订单项目表得到 订单详情表
    WHERE product_id = 3
)

--法3. 完全表连接

USE sql_store;

SELECT DISTINCT customer_id, first_name, last_name
FROM customers
LEFT JOIN orders USING (customer_id)
LEFT JOIN order_items USING (order_id)
WHERE product_id = 3
```
### 4. **ALL关键字 | The ALL Keyword**
* *> (MAX (……)) 和 > ALL(……) 等效可互换*
#### **示例**
*sql_invoicing 库中，选出金额大于3号顾客所有发票金额（或3号顾客最大发票金额） 的发票*
```sql
--法1. 用MAX关键字

USE sql_invoicing;

SELECT *
FROM invoices
WHERE invoice_total > (
    SELECT MAX(invoice_total)
    FROM invoices
    WHERE client_id = 3
)

--法2. 用ALL关键字

USE sql_invoicing;

SELECT *
FROM invoices
WHERE invoice_total > ALL (
    SELECT invoice_total
    FROM invoices
    WHERE client_id = 3
)
```
### 5. **ANY关键字 | The ANY Keyword**
* *> ANY/SOME (……) 与 > (MIN (……)) 等效*
* *= ANY/SOME (……) 与 IN (……) 等效*
#### **示例**
1. *sql_invoicing 库中，选出金额大于3号顾客任何发票金额（或最小发票金额） 的发票*
2. *选出至少有两次发票记录的顾客*
```sql
--1
USE sql_invoicing;

SELECT *
FROM invoices

WHERE invoice_total > ANY (
    SELECT invoice_total
    FROM invoices
    WHERE client_id = 3
)

或

WHERE invoice_total > (
    SELECT MIN(invoice_total)
    FROM invoices
    WHERE client_id = 3
)

--2

USE sql_invoicing;

SELECT *
FROM clients
WHERE client_id IN (  -- 或 = ANY ( 
    -- 子查询：有2次以上发票记录的顾客
    SELECT client_id
    FROM invoices
    GROUP BY client_id
    HAVING COUNT(*) >= 2
)
```
### 6. **相关子查询 | Correlated Subqueries**
* *之前都是非关联主/子（外/内）查询，比如子查询先查出整体的某平均值或满足某些条件的一列id，作为主查询的筛选依据，这种子查询与主查询无关，会先一次性得出查询结果再返回给主查询供其使用。*
* *而下面这种相关联子查询例子里，子查询要查询的是某员工所在办公室的平均值，子查询是依赖主查询的，注意这种关联查询是在主查询的每一行/每一条记录层面上依次进行的，这一点可以为我们写关联子查询提供线索（注意表别名的使用），另外也正因为这一点，相关子查询会比非关联查询执行起来慢一些。*
#### **实例**
*选出 sql_hr.employees 里那些工资超过他所在办公室平均工资（而不是整体平均工资）的员工*
```sql
USE sql_hr;

SELECT *
FROM employees e  -- 关键 1
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE office_id = e.office_id  -- 关键 2
    -- 【子查询表字段不用加前缀，主查询表的字段要加前缀，以此区分】
)
```
#### **练习**
*在 sql_invoicing 库 invoices 表中，找出高于每位顾客平均发票金额的发票*
```sql
USE sql_invoicing;

SELECT *
FROM invoices i
WHERE  invoice_total > (
    -- 子查询：目前客户的平均发票额
    SELECT AVG(invoice_total)
    FROM invoices
    WHERE client_id = i.client_id
)
```
### 7. **EXISTS运算符 | The EXISTS Operator**
* *IN + 子查询 等效于 EXIST + 相关子查询，如果前者子查询的结果集过大占用内存，用后者逐条验证更有效率。另外 EXIST() 本质上是根据是否为空返回 TRUE 和 FALSE，所以也可以加 NOT 取反。*
#### **实例**
*找出有过发票记录的客户，第4节学过用子查询或表连接来实现*
```sql
--法1. 子查询

USE sql_invoicing;

SELECT *
FROM clients
WHERE client_id IN (
    SELECT DISTINCT client_id
    FROM invoices
)

--法2. 链接表

USE sql_invoicing;

SELECT DISTINCT client_id, name …… 
FROM clients
JOIN invoices USING (client_id)
-- 内链接，只留下有过发票记录的客户

--第3种方法是用EXISTS运算符实现

USE sql_invoicing;

SELECT *
FROM clients c
WHERE EXISTS (
    SELECT */client_id  
    /* 就这个子查询的目的来说，SELECT的选择不影响结果，
    因为EXISTS()函数只根据是否为空返回 TRUE 和 FALSE */
    FROM invoices
    WHERE client_id = c.client_id
)
```
#### **练习**
*在sql_store中，找出从来没有被订购过的产品*
```sql
USE sql_store;

SELECT *
FROM products 
WHERE product_id NOT IN (
    SELECT product_id 
    -- 加不加DISTINCT对最终结果无影响
    FROM order_items
)

--或

SELECT *
FROM products p
WHERE NOT EXISTS (
    SELECT *
    FROM order_items
    WHERE product_id = p.product_id
)
```
*对于亚马逊这样的大电商来说，如果用IN+子查询法，子查询可能会返回一个百万量级的产品id列表，这种情况还是用EXIST+相关子查询逐条验证法更有效率*
### 8. **SELECT子句的子查询 | Subqueries in the SELECT Clause**
* *不仅 WHERE 筛选条件里可以用子查询，SELECT 选择子句和 FROM 来源表子句也能用子查询*
#### **实例**
*得到一个有如下列的表格：invoice_id, invoice_total, avarege（总平均发票额）, difference（前两个值的差）*
```sql
USE sql_invoicing;

SELECT 
    invoice_id,
    invoice_total,
    (SELECT AVG(invoice_total) FROM invoices) AS invoice_average,
    /*不能直接用聚合函数，因为“比较强势”，会压缩聚合结果为一条
    用括号+子查询(SELECT AVG(invoice_total) FROM invoices) 
    将其作为一个数值结果 152.388235 加入主查询语句*/
    invoice_total - (SELECT invoice_average) AS difference
    /*SELECT表达式里要用原列名，不能直接用别名invoice_average
    要用列别名的话用子查询（SELECT 同级的列别名）即可
    说真的，感觉这个子查询有点难以理解，但记住会用就行*/
FROM invoices
```
#### **练习**
*得到一个有如下列的表格：client_id, name, total_sales（各个客户的发票总额）, average（总平均发票额）, difference（前两个值的差）*
```sql
USE sql_invoicing;

SELECT 
    client_id,
    name,
    (SELECT SUM(invoice_total) FROM invoices WHERE client_id = c.client_id) AS total_sales,
    -- 要得到【相关】客户的发票总额，要用相关子查询 WHERE client_id = c.client_id
    (SELECT AVG(invoice_total) FROM invoices) AS average,
    (SELECT total_sales - average) AS difference   
    /* 如前所述，引用同级的列别名，要加括号和 SELECT，
    和前两行子查询的区别是，引用同级的列别名不需要说明来源，
    所以没有 FROM …… */
FROM clients c
```
### 9. **FROM子句的子查询 | Subqueries in the FROM Clause**
* *子查询的结果同样可以充当一个“虚拟表”作为FROM语句中的来源表，即将筛选查询结果作为来源再进行进一步的筛选查询*
#### **示例**
*将上一节练习里的查询结果当作来源表，查询其中 total_sales 非空的记录*
```sql
USE sql_invoicing;

SELECT * 
FROM (
    SELECT 
        client_id,
        name,
        (SELECT SUM(invoice_total) FROM invoices WHERE client_id = c.client_id) AS total_sales,
        (SELECT AVG(invoice_total) FROM invoices) AS average,
        (SELECT total_sales - average) AS difference   
    FROM clients c
) AS sales_summury
/* 在FROM中使用子查询，即使用 “派生表” 时，
必须给派生表取个别名（不管用不用），这是硬性要求，不写会报错：
Error Code: 1248. Every derived table（派生表、导出表）
must have its own alias */
WHERE total_sales IS NOT NULL
```
## **七、MySQL的基本函数 | Essential MySQL Functions**
### 1. **数值函数 | Numeric Functions**
* *主要介绍最常用的几个数值函数：ROUND、TRUNCATE、CEILING、FLOOR、ABS、RAND*
* *查看MySQL全部数值函数可谷歌 'mysql numeric function'，第一个就是官方文档*
#### **示例**
```sql
SELECT ROUND(5.7365, 2)  -- 四舍五入
SELECT TRUNCATE(5.7365, 2)  -- 截断
SELECT CEILING(5.2)  -- 天花板函数，大于等于此数的最小整数
SELECT FLOOR(5.6)  -- 地板函数，小于等于此数的最大整数
SELECT ABS(-5.2)  -- 绝对值
SELECT RAND()  -- 随机函数，0到1的随机值
```
### 2. **字符串函数 | String Functions**
* *依然介绍最常用的字符串函数：*
    * *1. LENGTH, UPPER, LOWER*
    * *2. TRIM, LTRIM, RTRIM*
    * *3. LEFT, RIGHT, SUBSTRING*
    * *4. LOCATE, REPLACE, 【CONCAT】*
* *查看全部搜索关键词 'mysql string functions'*
#### **示例**
```sql
--长度、转大小写：

SELECT LENGTH('sky')  -- 字符串字符个数/长度（LENGTH）
SELECT UPPER('sky')  -- 转大写
SELECT LOWER('Sky')  -- 转小写
--用户输入时时常多打空格，下面三个函数用于处理/修剪（trim）字符串前后的空格，L、R 表示 LEFT、RIGHT：

SELECT LTRIM('  Sky')
SELECT RTRIM('Sky  ')
SELECT TRIM(' Sky ')
切片：

-- 取左边，取右边，取中间
SELECT LEFT('Kindergarden', 4)  -- 取左边（LEFT）4个字符
SELECT RIGHT('Kindergarden', 6)  -- 取右边（RIGHT）6个字符
SELECT SUBSTRING('Kindergarden', 7, 6)  
-- 取中间从第7个开始的长度为6的子串（SUBSTRING）
-- 注意是从第1个（而非第0个）开始计数的
-- 省略第3参数（子串长度）则一直截取到最后

--定位：

SELECT LOCATE('gar', 'Kindergarden')  -- 定位（LOCATE）首次出现的位置
-- 没有的话返回0（其他编程语言大多返回-1，可能因为索引是从0开始的）
-- 这个定位/查找函数依然是不区分大小写的

--替换：

SELECT REPLACE('Kindergarten', 'garten', 'garden')

--连接：

USE sql_store;

SELECT CONCAT(first_name, ' ', last_name) AS full_name
-- concatenate v. 连接
FROM customers
```
### 3. **MySQL中的日期函数 | Date Functions in MySQL**
* *本节学基本的处理时间日期的函数，下节课学日期时间的格式化*
    1. *NOW, CURDATE, CURTIME*
    2. *YEAR, MONTH, DAY, HOUR, MINUTE, SECOND, DAYNAME, MONTHNAME*
    3. *EXTRACT(单位 FROM 日期时间对象)， 如 EXTRACT(YEAR FROM NOW())*
#### **实例**
```sql
--当前时间

SELECT NOW()  -- 2020-09-12 08:50:46
SELECT CURDATE()  -- current date, 2020-09-12
SELECT CURTIME()  -- current time, 08:50:46
以上函数将返回时间日期对象

--提取时间日期对象中的元素：

SELECT YEAR(NOW())  -- 2020
还有MONTH, DAY, HOUR, MINUTE, SECOND。

--以上函数均返回整数，还有另外两个返回字符串的：

SELECT DAYNAME(NOW())  -- Saturday
SELECT MONTHNAME(NOW())  -- September
--标准SQL语句有一个类似的函数 EXTRACT()，若需要在不同DBMS中录入代码，最好用EXTRACT()：

SELECT EXTRACT(YEAR FROM NOW())
--当然第一参数也可以是MONTH, DAY, HOUR ……
--总之就是：EXTRACT(单位 FROM 日期时间对象)
```
#### **练习**
*返回【今年】的订单*
```sql
USE sql_store;

SELECT * 
FROM orders
WHERE YEAR(order_date) = YEAR(now())
```
### 4. **格式化日期和时间 | Formatting Dates and Times**
* *DATE_FORMAT(date, format) 将 date 根据 format 字符串进行格式化*
* *TIME_FORMAT(time, format) 类似于 DATE_FORMAT 函数，但这里 format 字符串只能包含用于小时，分钟，秒和微秒的格式说明符。其他说明符产生一个 NULL 值或0*
* *很多像这种完全不需要记也不可能记得完，重要的是知道有这么个可以实现这个功能的函数，具体的格式说明符（Specifiers）可以需要的时候去查，至少有两种方法：*
    1. *直接谷歌关键词 如 mysql date format functions, 其实是在官方文档的 12.7 Date and Time Functions 小结里，有两个函数的说明和 specifiers 表*
    2. *用软件里的帮助功能，如 workbench 里的 HELP INDEX 打开官方文档查询或者右侧栏的 automatic comtext help (其是也是查官方文档，不过是自动的)*
#### **示例**
```sql
SELECT DATE_FORMAT(NOW(), '%M %d, %Y')  -- September 12, 2020
-- 格式说明符里，大小写是不同的，这是目前SQL里第一次出现大小写不同的情况
SELECT TIME_FORMAT(NOW(), '%H:%i %p')  -- 11:07 AM
```
### 5. **计算日期和时间 | Calculating Dates and Times**
* *有时需要对日期事件对象进行运算，如增加一天或算两个时间的差值之类，介绍一些最有用的日期时间计算函数：*
    1. DATE_ADD, DATE_SUB
    2. DATEDIFF
    3. TIME_TO_SEC*
#### **示例**
```sql
--增加或减少一定的天数、月数、年数、小时数等等

SELECT DATE_ADD(NOW(), INTERVAL -1 DAY)
SELECT DATE_SUB(NOW(), INTERVAL 1 YEAR)
--但其实不用函数，直接加减更简洁：

NOW() - INTERVAL 1 DAY
NOW() - INTERVAL 1 YEAR 
--计算日期差异

SELECT DATEDIFF('2019-01-01 09:00', '2019-01-05')  -- -4
-- 会忽略时间部分，只算日期差异

--借助 TIME_TO_SEC 函数计算时间差异

--TIME_TO_SEC：计算从 00:00 到某时间经历的秒数

SELECT TIME_TO_SEC('09:00')  -- 32400
SELECT TIME_TO_SEC('09:00') - TIME_TO_SEC('09:02')  -- -120
```
### 6. **IFNULL和COALESCE函数 | The IFNULL and COALESCE Functions**
* *之前讲了基本的处理数值、文本、日期时间的函数，再介绍几个其它的有用的MySQL函数*
    * *两个用来替换空值的函数：IFNULL, COALESCE. 后者更灵活*
#### **实例**
1. *将 orders 里 shipper.id 中的空值替换为 'Not Assigned'（未分配）*
2. *将 orders 里 shipper.id 中的空值替换为 comments，若 comments 也为空则替换为 'Not Assigned'（未分配）*
```sql
--1
USE sql_store;

SELECT 
    order_id,
    IFNULL(shipper_id, 'Not Assigned') AS shipper
    /* If expr1 is not NULL, IFNULL() returns expr1; 
    otherwise it returns expr2. */
FROM orders

--2
USE sql_store;

SELECT 
    order_id,
    COALESCE(shipper_id, comments, 'Not Assigned') AS shipper
    /* Returns the first non-NULL value in the list, 
    or NULL if there are no non-NULLvalues. */
FROM orders
```
*COALESCE 函数是返回一系列值中的首个非空值，更灵活（coalesce vi. 合并；结合；联合）*
#### **练习**
*返回一个有如下两列的查询结果：*
1. *customer (顾客的全名)*
2. *phone (没有的话，显示'Unknown')*
```sql
USE sql_store;

SELECT 
    CONCAT(first_name, ' ', last_name) AS customer,
    IFNULL/COALESCE(phone, 'Unknown') AS phone   
FROM customers
```
### 7. **IF函数 | The IF Function**
* *根据是否满足条件返回不同的值:*
    * *IF(条件表达式, 返回值1, 返回值2) 返回值可以是任何东西，数值 文本 日期时间 空值null 均可*
#### **实例**
*将订单表中订单按是否是今年的订单分类为active（活跃）和archived（存档）*
```sql
USE sql_store;

SELECT 
    *,
    IF(YEAR(order_date) = YEAR(NOW()),
       'Active',
       'Archived') AS category
FROM orders
```
#### **练习**
*得到包含如下字段的表：*
1. *product_id*
2. *name (产品名称)*
3. *orders (该产品出现在订单中的次数)*
4. *frequency (根据是否多于一次而分类为'Once'或'Many times')*
```sql
USE sql_store;

SELECT 
    product_id,
    name,
    COUNT(*) AS orders,
    IF(COUNT(*) = 1, 'Once', 'Many times') AS frequency
    /* 因为之后的内连接筛选掉了无订单的商品，
    所以这里不变考虑次数为0的情况 */
FROM products
JOIN order_items USING(product_id)
GROUP BY product_id
```
### 8. **CASE运算符 | The CASE Operator**
* *当分类多余两种时，可以用IF嵌套，也可以用CASE语句，后者可读性更好*
* *CASE语句结构：*
```sql
CASE 
    WHEN …… THEN ……
    WHEN …… THEN ……
    WHEN …… THEN ……
    ……
    --[ELSE ……] （ELSE子句是可选的）
END
```
#### **实例**
*不是将订单分两类，而是分为三类：今年的是 'Active', 去年的是 'Last Year', 比去年更早的是 'Achived'：*
```sql
USE sql_store;

SELECT
    order_id,
    CASE
        WHEN YEAR(order_date) = YEAR(NOW()) THEN 'Active'
        WHEN YEAR(order_date) = YEAR(NOW()) - 1 THEN 'Last Year'
        WHEN YEAR(order_date) < YEAR(NOW()) - 1 THEN 'Achived'
        ELSE 'Future'  
    END AS 'category'
FROM orders
```
#### **练习**
*得到包含如下字段的表：customer, points, category（根据积分 <2k、2k~3k（包含两端）、>3k 分为青铜、白银和黄金用户）*
```sql
USE sql_store;

SELECT
    CONCAT(first_name, ' ', last_name) AS customer,
    points,
    CASE
        WHEN points < 2000 THEN 'Bronze'
        WHEN points BETWEEN 2000 AND 3000 THEN 'Silver'
        WHEN points > 3000 THEN 'Gold'
        -- ELSE null
    END AS category
FROM customers
ORDER BY points DESC

--IF嵌套同样可以实现，但可读性没有那么好

SELECT
    CONCAT(first_name, ' ', last_name) AS customer,
    points,
    IF(points < 2000, 'Bronze', 
        IF(points BETWEEN 2000 AND 3000, 'Silver', 
        -- 第二层的条件表达式也可以简化为 <= 3000
            IF(points > 3000, 'Gold', null))) AS category
FROM customers
ORDER BY points DESC
```
## **八、视图 | Views**
### 1. **创建视图 | Creating ViewsCreating Views**
* *就是创建虚拟表，自动化一些重复性的查询模块，简化各种复杂操作（包括复杂的子查询和连接等）*
* *注意视图虽然可以像一张表一样进行各种操作，但并没有真正储存数据，数据仍然储存在原始表中，视图只是储存起来的模块化的查询结果，是为了方便和简化后续进一步操作而储存起来的虚拟表*
#### **实例**
*创建 sales_by_client 视图*
```sql
USE sql_invoicing;

CREATE VIEW sales_by_client AS
    SELECT 
        client_id,
        name,
        SUM(invoice_total) AS total_sales
    FROM clients c
    JOIN invoices i USING(client_id)
    GROUP BY client_id, name;
    -- 虽然实际上这里加不加上name都一样
```
#### **练习**
*创建一个客户差额表视图，可以看到客户的id，名字以及差额（发票总额-支付总额）*
```sql
USE sql_invoicing;

CREATE VIEW clients_balance AS
    SELECT 
        client_id,
        c.name,
        SUM(invoice_total - payment_total) AS balance
    FROM clients c
    JOIN invoices USING(client_id)
    GROUP BY client_id
```
### 2. **更新或删除视图 | Altering or Dropping Views**
* *修改视图可以先DROP在CREATE（也可以用CREATE OR REPLACE）*
* *视图的查询语句可以在编辑模式下查看和修改，但最好是保存为sql文件并放在源码控制妥善管理*
#### **示例**
*想在上一节的顾客差额视图的查询语句最后加上按差额降序排列*
```sql
--法1. 先删除再重建

USE sql_invoicing;

DROP VIEW IF EXISTS clients_balance;
-- 若不存在这个视图，直接 DROP 会报错，所以要加上 IF EXISTS 先检测有没有这个视图

CREATE VIEW clients_balance AS 
    ……
    ORDER BY balance DESC
--法2. 用REPLACE关键字，即用 CREATE OR REPLACE VIEW clients_balance AS，和上面等效，不过上面那种分成两个语句的方式要用的多一点

USE sql_invoicing;

CREATE OR REPLACE VIEW clients_balance AS
    ……
    ORDER BY balance DESC
```
*建议将原始查询语句保存为 views 文件夹下的和与视图同名的 clients_balance.sql 文件，然后将这个文件夹放在源码控制下（put these files under source control）, 通常放在 git repository（仓库）里与其它人共享，团队其他人因此能在自己的电脑上重建这个数据库*
### 3. **可更新视图 | Updatable Views**
* *视图作为虚拟表/衍生表，除了可用在查询语句SELECT中，也可以用在增删改（INSERT DELETE UPDATE）语句中，但后者有一定的前提条件*
* *如果一个视图的原始查询语句中没有如下元素，则该视图是可更新视图（Updatable Views），可以增删改，否则只能查*
    1. DISTINCT 去重
    2. GROUP BY/HAVING/聚合函数 (后两个通常是伴随着 GROUP BY 分组出现的)
    3. UNION 纵向连接
* *另外，增（INSERT）还要满足附加条件：视图必须包含底层原表的所有必须字段*
* *总之，一般通过原表修改数据，但当出于安全考虑或其他原因没有某表的直接权限时，可以通过视图来修改底层数据（？），前提是视图是可更新的*
#### **示例**
*创建视图（新虚拟表）invoices_with_balance（带差额的发票记录表）*
```sql
USE sql_invoicing;

CREATE OR REPLACE VIEW invoices_with_balance AS
SELECT 
    /* 这里有个小技巧，要插入表中的多列列名时，
    可从左侧栏中连选并拖入相关列 */
    invoice_id, 
    number, 
    client_id, 
    invoice_total, 
    payment_total, 
    invoice_date,
    invoice_total - payment_total AS balance,  -- 新增列
    due_date, 
    payment_date
FROM invoices
WHERE (invoice_total - payment_total) > 0
/* 这里不能用列别名balance，会报错说不存在，
必须用原列名的表达式，这还是执行顺序的问题
之前讲WHERE和HAVING作为事前筛选和事后筛选的区别时提到过 */
--该视图满足条件，是可更新视图，故可以增删改：

--删：
--删掉id为1的发票记录

DELETE FROM invoices_with_balance
WHERE invoice_id = 1
--改：
--将2号发票记录的期限延后两天

UPDATE invoices_with_balance
SET due_date = DATE_ADD(due_date, INTERVAL 2 DAY)
WHERE invoice_id = 2
```
### 4. **WITH CHECK OPTION 子句 | THE WITH CHECK OPTION Clause**
* *在视图的原始查询语句最后加上 WITH CHECK OPTION 可以防止执行那些会让视图中某些行（记录）消失的修改语句*
#### **示例**
```sql
--接前面的 invoices_with_balance 视图的例子，该视图与原始的 orders 表相比增加了balance(invouce_total - payment_total) 列，且只显示 balance 大于0的行（记录），若将某记录（如2号订单）的 payment_total 改为和 invouce_total 相等，则 balance 为0，该记录会从视图中消失：

UPDATE invoices_with_balance
SET payment_total = invoice_total
WHERE invoice_id = 2
--更新后会发现invoices_with_balance视图里2号订单消失。

--但在视图原始查询语句最后加入 WITH CHECK OPTION 后，对3号订单执行类似上面的语句后会报错：

UPDATE invoices_with_balance
SET payment_total = invoice_total
WHERE invoice_id = 3

-- Error Code: 1369. CHECK OPTION failed 'sql_invoicing.invoices_with_balance'
```
### 5. **视图的其他优点 | Other Benefits of Views**
* *三大优点：简化查询、增加抽象层和减少变化的影响、数据安全性*
* *具体来讲：*
    1. *（首要优点）简化查询 simplify queries*
    2. *增加抽象层，减少变化的影响 Reduce the impact of changes：视图给表增加了一个抽象层（模块化），这样如果数据库设计改变了（如一个字段从一个表转移到了另一个表），只需修改视图的查询语句使其能保持原有查询结果即可，不需要修改使用这个视图的那几十个查询。相反，如果没有视图这一层的话，所有查询将直接使用指向原表的原始查询语句，这样一旦更改原表设计，就要相应地更改所有的这些查询*
    3. *限制对原数据的访问权限 Restrict access to the data：在视图中可以对原表的行和列进行筛选，这样如果你禁止了对原始表的访问权限，用户只能通过视图来修改数据，他们就无法修改视图中未返回的那些字段和记录。但注意这通常并不简单，需要良好的规划，否则最后可能搞得一团乱*
## **九、存储过程 | Stored Procedures**
### 1. **什么是存储过程 | What are Stored Procedures**
* *存储过程三大作用：*
    1. *储存和管理SQL代码 Store and organize SQL*
    2. *性能优化 Faster execution*
    3. *数据安全 Data security*
* *假设你要开发一个使用数据库的应用程序，你应该将SQL语句写在哪里呢？如果将SQL语句内嵌在应用程序的代码里，将使其混乱且难以维护，所以应该将SQL代码和应用程序代码分开，将SQL代码储存在所属的数据库中，具体来说，是放在储存过程（stored procedure）和函数中*
* *储存过程是一个包含SQL代码模块的数据库对象，在应用程序代码中，我们调用储存过程来获取和保存数据（get and save the data）。也就是说，我们使用储存过程来储存和管理SQL代码*
* *使用储存程序还有另外两个好处*
    1. *首先，大部分DBMS会对储存过程中的代码进行一些优化，因此有时储存过中的SQL代码执行起来会更快*
    2. *此外，就像视图一样，储存过程能加强数据安全。比如，我们可以移除对所有原始表的访问权限，让各种增删改的操作都通过储存过程来完成，然后就可以决定谁可以执行何种储存过程，用以限制用户对我们数据的操作范围，例如，防止特定的用户删除数据*
### 2. **创建一个存储过程 | Creating a Stored Procedure**
```sql
DELIMITER $$
-- delimiter n. 分隔符

    CREATE PROCEDURE 过程名()  
        BEGIN
            ……;
            ……;
            ……;
        END$$

DELIMITER ;
```
#### **实例**
*创造一个get_clients()过程*
```sql
CREATE PROCEDURE get_clients()  
-- 括号内可传入参数，之后会讲
-- 过程名用小写单词和下划线表示，这是约定熟成的做法
    BEGIN
        SELECT * FROM clients;
    END
```
* *BEGIN 和 END 之间包裹的是此过程（PROCEDURE）的内容（body），内容里可以有多个语句，但每个语句都要以 ; 结束，包括最后一个*
* *为了将过程内容内部的语句分隔符与SQL本身执行层面的语句分隔符 ; 区别开，要先用 DELIMITER(分隔符) 关键字暂时将SQL语句的默认分隔符改为其他符号，一般是改成双美元符号 `$$` ，创建过程结束后再改回来。注意创建过程本身也是一个完整SQL语句，所以别忘了在END后要加一个暂时语句分隔符 `$$`*
* *过程内容中所有语句都要以 ; 结尾并且因此要暂时修改SQL本身的默认分隔符，这些都是MySQL地特性，在SQL Server等就不需要这样*
```sql
DELIMITER $$

    CREATE PROCEDURE get_clients()  
        BEGIN
            SELECT * FROM clients;
        END$$

DELIMITER ;

--用CALL关键字调用存储过程

USE sql_invoicing;
CALL get_clients()

--或

CALL sql_invoicing.get_clients()
```
#### **练习**
*创造一个储存过程 get_invoices_with_balance（取得有差额（差额不为0）的发票记录）*
```sql
DROP PROCEDURE get_invoices_with_balance;
-- 注意DROP语句里这个过程没有带括号

DELIMITER $$

    CREATE PROCEDURE get_invoices_with_balance()
        BEGIN
            SELECT *
            FROM invoices_with_balance 
            -- 这是之前创造的视图
            -- 用视图好些，因为有现成的balance列
            WHERE balance > 0;
        END$$

DELIMITER ;

CALL get_invoices_with_balance();
```
### 3. **删除存储过程 | Dropping Stored Procedures**
*一个创建过程（get_clients）的标准模板*
#### **示例**
```sql
USE sql_invoicing;

DROP PROCEDURE IF EXISTS get_clients;
-- 注意加上【IF EXISTS】，以免因为此过程不存在而报错

DELIMITER $$

    CREATE PROCEDURE get_clients()
        BEGIN
            SELECT * FROM clients;
        END$$

DELIMITER ;

CALL get_clients();
```
* *同视图一样，最好把删除和创建每一个过程的代码也储存在不同的SQL文件中，并把这样的文件放在 Git 这样的源码控制下，这样就能与其它团队成员共享 Git 储存库。他们就能在自己的机器上重建数据库以及该数据库下的所有的视图和储存过程*

* *如上面那个实例，可储存在 stored_procedures 文件夹（之前已有 views 文件夹）下的 get_clients.sql 文件。当你把所有这些脚本放进源码控制，你能随时回来查看你对数据库对象所做的改动。*
### 4. **参数 | Parameters**
* *基本格式*
```sql
CREATE PROCEDURE 过程名
(
    参数1 数据类型,
    参数2 数据类型,
    ……
)
BEGIN
……
END
```
#### **实例**
*创建过程 get_clients_by_state，可返回特定州的顾客*
```sql
USE sql_invoicing;

DROP PROCEDURE IF EXISTS get_clients_by_state;

DELIMITER $$

CREATE PROCEDURE get_clients_by_state
(
    state CHAR(2)  -- 参数的数据类型
)
BEGIN
    SELECT * FROM clients c
    WHERE c.state = state;
END$$

DELIMITER ;

CALL get_clients_by_state('CA')
```
#### **练习**
*创建过程 get_invoices_by_client，通过 client_id 来获得发票记录*
```sql
USE sql_invoicing;

DROP PROCEDURE IF EXISTS get_invoices_by_client ;

DELIMITER $$

CREATE PROCEDURE get_invoices_by_client
(
    client_id INT  -- 为何不写INT(11)？
)
BEGIN
SELECT * 
FROM invoices i
WHERE i.client_id = client_id;
END$$

DELIMITER ;

CALL get_invoices_by_client(1);
```
### 5. **带默认值的参数 | Parameters with Default Value**
* *给参数设置默认值，主要是运用条件语句块和替换空值函数*
* *SQL中的条件类语句：*
    1. *替换空值 IFNULL(值1，值2)*
    2. *条件函数 IF(条件表达式, 返回值1, 返回值2)*
    3. *条件语句块*
    ```sql
    IF 条件表达式 THEN
        语句1;
        语句2;
        ……;
    [ELSE]（可选）
        语句1;
        语句2;
        ……;
    END IF;
    -- 别忘了【END IF】
    ```
#### **实例**
1. *把 get_clients_by_state 过程的默认参数设为'CA'，即默认查询加州的客户*
2. *将 get_clients_by_state 过程设置为默认选取所有顾客*
```sql
--1
USE sql_invoicing;

DROP PROCEDURE IF EXISTS get_clients_by_state;

DELIMITER $$

CREATE PROCEDURE get_clients_by_state
(
    state CHAR(2)  
)
BEGIN
    IF state IS NULL THEN 
        SET state = 'CA';  
        /* 注意别忽略SET，
        SQL 里单个等号 '=' 是比较操作符而非赋值操作符
        '=' 与 SET 配合才是赋值 */
    END IF;
    SELECT * FROM clients c
    WHERE c.state = state;
END$$

DELIMITER ;

CALL get_clients_by_state(NULL)

--2

--法1. 用IF条件语句块实现
……
BEGIN
    IF state IS NULL THEN 
        SELECT * FROM clients c;
    ELSE
        SELECT * FROM clients c
        WHERE c.state = state;
    END IF;    
END$$
……
--法2. 用IFNULL替换空值函数实现

……
BEGIN
    SELECT * FROM clients c
    WHERE c.state = IFNULL(state, c.state)
END$$
……
```
#### **练习**
*创建一个叫 get_payments 的过程，包含 client_id 和 payment_method_id 两个参数，数据类型分别为 INT(4) 和 TINYINT(1)*
```sql
USE sql_invoicing;

DROP PROCEDURE IF EXISTS get_payments;

DELIMITER $$

CREATE PROCEDURE get_payments
(
    client_id INT,  -- 不用写成INT(4)
    payment_method_id TINYINT
)
BEGIN
    SELECT * FROM payments p
    WHERE 
        p.client_id = IFNULL(client_id, p.client_id) AND
        p.payment_method = IFNULL(payment_method_id, p.payment_method);
        -- 再次小心这种实际工作中各表相同字段名称不同的情况
END$$

DELIMITER ;
--所有支付记录
CALL get_payments(NULL, NULL)
--1号顾客的所有记录
CALL get_payments(1, NULL)
--3号支付方式的所有记录
CALL get_payments(NULL, 3)
--5号顾客用2号支付方式的所有记录
CALL get_payments(5, 2)
```
### 6. **参数验证 | Parameter Validation**
* *主要利用条件语句块和 SIGNAL SQLSTATE MESSAGE_TEXT 关键字*
* *具体来说是在过程的内容开头加上这样的语句：*
    ```sql
    IF 错误参数条件表达式 THEN
    SIGNAL SQLSTATE '错误类型'
        [SET MESSAGE_TEXT = '关于错误的补充信息']（可选）
    ```
#### **示例**
*创建一个 make_payment 过程，含 invoice_id, payment_amount, payment_date 三个参数*
```sql
CREATE DEFINER=`root`@`localhost` PROCEDURE `make_payment`(
    invoice_id INT,
    payment_amount DECIMAL(9, 2),
    /*
    9是精度， 2是小数位数。
    精度表示值存储的有效位数，
    小数位数表示小数点后可以存储的位数
    见：
    https://dev.mysql.com/doc/refman/8.0/en/fixed-point-types.html 
    */
    payment_date DATE    
)
BEGIN   
    UPDATE invoices i
    SET 
        i.payment_total = payment_amount,
        i.payment_date = payment_date
    WHERE i.invoice_id = invoice_id;
END
```
### 7. **输出参数 | Output Parameters**
* *输入参数是用来给过程传入值的，我们也可以用输出参数来获取过程的结果值*
* *具体是在参数的前面加上 OUT 关键字，然后再 SELECT 后加上 INTO……*
* *调用麻烦，如无需要，不要多此一举*
#### **示例**
*创造 get_unpaid_invoices_for_client 过程，获取特定顾客所有未支付过的发票记录（即 payment_total = 0 的发票记录）*
```sql
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_unpaid_invoices_for_client`(
        client_id INT,
        OUT invoice_count INT,
        OUT invoice_total DECIMAL(9, 2)
        -- 默认是输入参数，输出参数要加【OUT】前缀
)
BEGIN
    SELECT COUNT(*), SUM(invoice_total)
    INTO invoice_count, invoice_total
    -- SELECT后跟上INTO语句将SELECT选出的值传入输出参数（输出变量）中
    FROM invoices i
    WHERE 
        i.client_id = client_id AND
        payment_total = 0;
END

set @invoice_count = 0;
set @invoice_total = 0;
call sql_invoicing.get_unpaid_invoices_for_client(3, @invoice_count, @invoice_total);
select @invoice_count, @invoice_total;
```
### 8. **变量 | Variables**
* *两种变量:*
    1. *用户或会话变量 SET @变量名 = ……*
        * *上节课讲过，用 SET 语句并在变量名前加 @ 前缀来定义，将在整个用户会话期间存续，在会话结束断开MySQL链接时才被清空，这种变量主要在调用带输出的储存过程时，作为输出参数来获取结果值*
    2. *本地变量 DECLARE 变量名 数据类型 [DEFAULT 默认值]*
        * *在储存过程或函数中通过 DECLARE 声明并使用，在函数或储存过程执行结束时就被清空，常用来执行过程（或函数）中的计算*
#### **示例**
*创造一个 get_risk_factor 过程，使用公式 risk_factor = invoices_total / invoices_count * 5*
```sql
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_risk_factor`()
BEGIN
    -- 声明三个本地变量，可设默认值
    DECLARE risk_factor DECIMAL(9, 2) DEFAULT 0;
    DECLARE invoices_total DECIMAL(9, 2);
    DECLARE invoices_count INT;

    -- 用SELECT得到需要的值并用INTO传入invoices_total和invoices_count
    SELECT SUM(invoice_total), COUNT(*)
    INTO invoices_total, invoices_count
    FROM invoices;

    -- 用SET语句给risk_factor计算赋值
    SET risk_factor = invoices_total / invoices_count * 5;

    -- 展示最终结果risk_factor
    SELECT risk_factor;        
END
```
### 9. **函数 | Functions**
* *创建函数和创建过程的两点不同*
1. *参数设置和body内容之间，有一段确定返回值类型以及函数属性的语句段*
    * *RETURNS INTEGER*
    * *DETERMINISTIC*
    * *READS SQL DATA*
    * *MODIFIES SQL DATA*
……
2. *最后是返回（RETURN）值而不是查询（SELECT）值
RETURN IFNULL(risk_factor, 0);*
* *删除*
    * *DROP FUNCTION [IF EXISTS] 函数名*
#### **示例**
*在上一节的储存过程 get_risk_factor 的基础上，创建函数 get_risk_factor_for_client，计算特定顾客的 risk_factor*
1. *DETERMINISTIC 决定性的：唯一输入决定唯一输出，和数据的改动更新无关，比如税收是订单总额的10%，则以订单总额为输入税收为输出的函数就是决定性的（？），但这里每个顾客的 risk_factor 会随着其发票记录的增加更新而改变，所以不是DETERMINISTIC的*
2. *READS SQL DATA：需要用到 SELECT 语句进行数据读取的函数，几乎所有函数都满足*
3. *MODIFIES SQL DATA：函数中有 增删改 或者说有 INSERT DELETE UPDATE 语句，这个例子不满足*
```sql
CREATE DEFINER=`root`@`localhost` FUNCTION `get_risk_factor_for_client`
(
    client_id INT
) 
RETURNS INTEGER
-- DETERMINISTIC
READS SQL DATA
-- MODIFIES SQL DATA
BEGIN
    DECLARE risk_factor DECIMAL(9, 2) DEFAULT 0;
    DECLARE invoices_total DECIMAL(9, 2);
    DECLARE invoices_count INT;

    SELECT SUM(invoice_total), COUNT(*)
    INTO invoices_total, invoices_count
    FROM invoices i
    WHERE i.client_id = client_id;
    -- 注意不再是整体risk_factor而是特定顾客的risk_factor

    SET risk_factor = invoices_total / invoices_count * 5;
    RETURN IFNULL(risk_factor, 0);       
END

SELECT 
    client_id,
    name,
    get_risk_factor_for_client(client_id) AS risk_factor
    -- 函数当然是可以处理整列的，我第一时间竟只想到传入具体值
    -- 不过这里更像是一行一行的处理，所以应该每次也是传入1个client_id值
FROM clients

DROP FUNCTION [IF EXISTS] get_risk_factor_for_client
```
