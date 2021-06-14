# 商品售卖系统数据库设计

## 一、引言

无论是网上购物还是超市购物系统，商品售卖场景已经随处可见了。简单来说就是在同一时刻大量的数据情求与同一件商品并完成交易，从架构的角度来看，商品售卖系统本质是一个高可用，高一致性高性能的三高系统 ，数据库的设计也是在抗并发的解决措施里面，本数据库设计则是应用于此类商品售卖系统中。

## 二、数据库设计

数据库中有5张表，分别是tb_goods（商品表），tb_sale_info（商品售卖信息表），tb_user（用户表），tb_order(订单表)，tb_manager(管理员表)

### 实体属性：

#### 商品实体：

属性的意思分别为g_id（商品id），g_name（商品名称），g_title（商品标题），g_img（商品图片），g_details（商品的详细描述），g_prices（商品价格），g_discount（商品折扣），g_stack（商品的库存）。

#### 商品售卖信息实体；

s_id(信息id), content(信息内容), over_time(结束时间), status(状态), create_time(创建时间), send_type(发送类型), s_type(0 商品售卖消息 1 购买消息 2 推送消息).

#### 用户表实体；

U_id(用户id)，Username(用户名/账号), password(密码), head(头像), register_date(注册日期), last_login_date(最后登录日期), login_count(登录次数).

#### 管理员表实体；

m_id(管理员id)，Username(用户名/账号), password(密码), last_login_date(最后登录日期), login_count(登录次数).

#### 订单实体：

O_id(订单id),User_id(用户id), g_id(商品id), delivery_addr_id(邮寄方式) , O_chnner(1pc，2android，3ios), status(订单状态), create_date(创建日期), pay_date(付款日期).

### 关联表：

tb_order（商品售卖-订单-商品），是将用户、商品表关联起来的数据表。

E-R图

简易的e-r图，如下：

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210614105726149.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDc1MzY5MQ==,size_16,color_FFFFFF,t_70)




## 三、表和数据添加

### 一、建表和插入数据

如下是本次数据库的建表sql，使用的是pl/sql语言写的一个文件。

在建表之前应该判断数据库中是否有该表的存在，如果有删除，如果没有，则执行建表语句。

这里使用的是查找该表中的数据条数，来判断是是否有表，然后执行drop table 来删除表。Declare表示申明，begin表示执行开始，需要在结尾加上end；/ 表示执行以上所有代码。

```sql
declare

   num  number;

begin

   select count(1) into num from user_tables where TABLE_NAME = 'TB_GOODS';

   if  num=1  then

     execute immediate 'drop table TB_GOODS cascade constraints PURGE';

   end  if;

   

   select count(1) into num from user_tables where TABLE_NAME = 'TB_DISCOUNT_GOODS';

   if  num=1  then

     execute immediate 'drop table TB_DISCOUNT_GOODS cascade constraints PURGE';

   end  if;

   

   select count(1) into num from user_tables where TABLE_NAME = 'TB_SALE_INFO';

   if  num=1  then

     execute immediate 'drop table TB_SALE_INFO cascade constraints PURGE';

   end  if;

   

   select count(1) into num from user_tables where TABLE_NAME = 'TB_USER';

   if  num=1  then

     execute immediate 'drop table TB_USER cascade constraints PURGE';

   end  if;

   

   select count(1) into num from user_tables where TABLE_NAME = 'TB_ORDER';

   if  num=1  then

     execute immediate 'drop table TB_ORDER cascade constraints PURGE';

   end  if;

   

   select count(1) into num from user_tables where TABLE_NAME = 'TB_MANAGER';

   if  num=1  then

     execute immediate 'drop table TB_MANAGER cascade constraints PURGE';

   end  if;

   

    select count(1) into num from user_tables where TABLE_NAME = 'O_INFOR';

   if  num=1  then

     execute immediate 'drop table O_INFOR cascade constraints PURGE';

   end  if;

   

   select count(1) into num from user_tables where TABLE_NAME = 'USERS';

   if  num=1  then

     execute immediate 'drop table USERS cascade constraints PURGE';

   end  if;

end;

/
```


以下是建表语句，根据数据字段的设计，在数据库中设计数据库表，这里不赘述。
--创建tb_sale_info表

```sql
CREATE TABLE TB_SALE_INFO(
  `s_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `content` VARCHAR(45) NOT NULL,
  `over_time` DATETIME NOT NULL,
  `status` VARCHAR(45) NOT NULL,
  `create_time` DATETIME NOT NULL,
  `send_type` INT NOT NULL,
  `s_type` INT NOT NULL,
  PRIMARY KEY (`s_id`));
```

--创建tb_goods 表

```sql
CREATE TABLE IF NOT EXISTS `tb_goods` (
  `g_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `g_name` VARCHAR(45) NOT NULL,
  `g_title` VARCHAR(45) NOT NULL,
  `g_img` VARCHAR(45) NOT NULL,
  `g_details` VARCHAR(45) NOT NULL,
  `g_prices` DECIMAL(10,2) NOT NULL,
  `g_discount` DECIMAL(10,2) NOT NULL,
  `g_stack` INT NOT NULL,
  `tb_sale_info_s_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`g_id`),
  INDEX `fk_tb_goods_tb_sale_info_idx` (`tb_sale_info_s_id` ASC) VISIBLE,
  CONSTRAINT `fk_tb_goods_tb_sale_info`
    FOREIGN KEY (`tb_sale_info_s_id`)
    REFERENCES `mydb`.`tb_sale_info` (`s_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
```


--创建tb_user

```sql
CREATE TABLE TB_USER(
  `u_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `head` VARCHAR(45) NOT NULL,
  `register_date` DATE NOT NULL,
  `last_login_date` DATETIME NOT NULL,
  `login_count` INT NOT NULL,
  PRIMARY KEY (`u_id`));
```

 

--创建表tb_order表

```sql
CREATE TABLE TB_ORDER(
  `O_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `delivery_addr` VARCHAR(45) NOT NULL,
  `O_chnner` INT NOT NULL,
  `status` VARCHAR(45) NOT NULL,
  `create_date` DATETIME NOT NULL,
  `pay_date` DATETIME NULL,
  `tb_goods_g_id` INT UNSIGNED NOT NULL,
  `tb_user_u_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`O_id`),
  INDEX `fk_tb_order_tb_goods1_idx` (`tb_goods_g_id` ASC) VISIBLE,
  INDEX `fk_tb_order_tb_user1_idx` (`tb_user_u_id` ASC) VISIBLE,
  CONSTRAINT `fk_tb_order_tb_goods1`
    FOREIGN KEY (`tb_goods_g_id`)
    REFERENCES `mydb`.`tb_goods` (`g_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_tb_order_tb_user1`
    FOREIGN KEY (`tb_user_u_id`)
    REFERENCES `mydb`.`tb_user` (`u_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
 );
```

 

--创建表tb_manager

```sql
CREATE TABLE TB_MANAGER(
 `m_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `last_login_date` DATETIME NOT NULL,
  `login_count` INT NOT NULL,
  PRIMARY KEY (`m_id`)
);
```

 

### 二、数据库表导入相应数据

使用pl/sql语句来添加数据。

#### 1、向tb_goods表中添加数据

这里定义了6个数组，数据库表中的每个字段随机从每个数组中选取数据，构成一个记录，插入到数据库中相应表中，数据条数为10000条。

```sql
set SERVEROUTPUT ON;
create or replace function RANDOM
  return number 
  is 
    a number ; 
  begin
    select round(dbms_random.value(1,5)) rnum
    into a 
    from dual;
    return a ;
  end;
 

DECLARE
  type g_name is varray(5) of varchar2(20);
  type g_details is varray(5) of VARCHAR2(100);
  type g_img is varray(5) of VARCHAR2(20);
  type g_info is varray(5) of VARCHAR2(50);
  type g_price is varray(5) of VARCHAR2(20);
  type g_have is varray(5) of VARCHAR2(20);

 
  indexRandom NUMBER;

  g_name_list g_name:=g_name('iphoneX','华为Meta9','小米6','一加','vivo'); 
  g_details_list g_details:=g_details('64GB 银色 移动联通电信4G手机','4GB+32GB版 移动联通电信4G手机 双卡双待','64GB 银色 移动联通电信3G手机','月光银 移动联通电信4G手机','玫瑰金 64g 晓龙a382'); 
  g_img_list g_img:=g_img('/img/iphonex.png','/img/meta10.png','/img/iphone8.png','/img/mi6.png','/img/mi9.png');
  g_info_list g_info:=g_info('移动联通电信4G手机','4GB+32GB版','月光银','玫瑰金','64GB 银色'); 
  g_price_list g_price:=g_price('8765.00','3212.00','5589.00','3212.00','7212.00'); 
  g_have_list g_have:=g_have('8765','-1','558','3212','7212'); 
  
 BEGIN
  dbms_output.put_line(indexRandom);
  DBMS_OUTPUT.PUT_LINE(g_name_list(5));
  for i in 1..10000
  loop
    indexRandom:=RANDOM();
    INSERT INTO TB_GOODS VALUES (i, g_name_list(indexRandom), g_details_list(indexRandom), g_img_list(indexRandom), g_info_list(indexRandom), g_price_list(indexRandom), g_have_list(indexRandom));
  end loop;

 END;
```

#### 2、向tb_sale_info 中添加数据

如上面的导入数据方式，使用i值的不同，构造不同记录。

```sql
declare

begin
  for i in 2..5000
  loop
    INSERT INTO TB_SALE_INFO VALUES (i,'533324506110885888', '尊敬的用户你好，你已经成功注册！', null, '0', null, null, '0', null, null);

  end loop;

end;


-- tb_manager

declare
  id number;
  user_id number;
  username number;

begin
  id:=18912341247;
  username:=18612766444;
  user_id:=1;

  loop
    id:=id+1;
    user_id:=user_id+1;
    username:=username+1;
    INSERT INTO TB_MANAGER VALUES (id, user_id, username, 'b7797cce01b4b131b433b6acf4add449', '1a2b3c4d', null, '11-1月-19', null, '0');
    exit when id=18912344246;
  end loop;

end;
```

#### 3、向tb_oder中添加数据

导入O_info使用的是循环loop….end，创建变量O_id,user_id，g_id，并赋以初值，然后在执行完一条insert之后，是这些变量的值进行相应的改变，达到数据导入的目的。

```sql
DECLARE

--  INSERT INTO `O_info` VALUES ('1564', '18912341234', '3', null, 'iphone8', '1', '0.01', '1', '0', '2017-12-16 16:35:20', null);

  O_ID NUMBER;
  USER_ID NUMBER;
  G_ID NUMBER;
  ID NUMBER:=1;

BEGIN

--20000
  O_ID:=1564;
  USER_ID:=1;
  G_ID:=1;
  LOOP

    INSERT INTO O_INFOR VALUES(ID, O_ID, USER_ID, G_ID,null, 'iphone8', '1', '0.01', '1', '0', '16-12月-17', null);
    O_ID:=O_ID+1;
    USER_ID:=USER_ID+1;
    G_ID:=G_ID+1;
    EXIT 

  END LOOP;

END;

```

 

## 四、ORACLE中相关配置

首先就是新建pdb 的操作，oracle没有办法对cdb进行操作，只能操作pdb，所以在oracle中的开始，我就需要新建一个pdb数据库，以上的相关操作，都是建立在这次之后的操作，这里新建一个salespdb的pdb数据库。

大致解释以下语句的含义：

Create pluggable database 就是新建一个pdb的语句，其中salespdb是数据库的名称，然后就是用户名和密码，使用的tablespace的大小，默认的存储文件地址。

CREATE PLUGGABLE DATABASE salespdb ADMIN USER sale5deng IDENTIFIED BY sale5deng STORAGE (MAXSIZE 2G) DEFAULT TABLESPACE sales DATAFILE '/database/oracle/oracle/oradata/orcl/salespdb/sales01.dbf' SIZE 250M AUTOEXTEND ON PATH_PREFIX = '/database/oracle/oracle/oradata/orcl/salespdb/' FILE_NAME_CONVERT = ('/database/oracle/oracle/oradata/orcl/pdbseed/', '/database/oracle/oracle/oradata/orcl/salespdb/');

#### 一、表设计

创建表空间的过程，创建了三个表空间，分别叫做sales，sales02，sales03，大小最大为50M，数据文件存放在/database/oracle/oracle/oradata/orcl/orclpdb/目录下面。

```sql
CREATE TABLESPACE SALES 

DATAFILE '/database/oracle/oracle/oradata/orcl/salespdb/sales.dbf' 

SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED 

EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;

 

CREATE TABLESPACE USERS01 

DATAFILE '/database/oracle/oracle/oradata/orcl/ salespdb / sales02.dbf' 

SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED 

EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;

 

CREATE TABLESPACE USERS02 

DATAFILE '/database/oracle/oracle/oradata/orcl/ salespdb / sales03.dbf' 

SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED 

EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;
```

 

#### 二、用户管理

##### 创建用户

这里创建了两个用户，分别叫做sale5deng和buyer5deng

 

```sql
SYSTEM@192.168.44.183:1521/salespdb>create role sales5deng identified sales5deng;

角色已创建。

 

SYSTEM@192.168.44.183:1521/salespdb>create role buyer5deng identified buyer5deng;

角色已创建。

##### 权限配置

给刚创建的两个用户添加connect，resource，create view的权限

 

SYSTEM@192.168.44.183:1521/salespdb>grant connect, resource, CREATE VIEW TO sales5deng;

授权成功。

 

SYSTEM@192.168.44.183:1521/salespdb>grant connect, resource, CREATE VIEW TO buyer5deng;

授权成功。
```

##### 表空间分配

数据库中有三个刚才创建的表空间，分别为sales，sales02，sales03.

```sql
SYSTEM@192.168.44.229:1521/salespdb>select tablespace_name from user_tablespaces;

 

TABLESPACE_NAME

SYSTEM

SYSAUX

UNDOTBS1

TEMP

SALES

SALES02

SALES03

 

已选择 7 行。
```

 

#### 三、PL/SQL设计

查找tb_order 表中的数据，使用tb_manager的user_id，使用存储过程queryUser传入user_id，从miasha_order表中查出相应的数据记录，然后取出tb_goods，使用g_id，在tb_discount_goods中进行查询，查询出相应的记录

```sql
set serveroutput on;
create or replace procedure queryUser
(
  u_user_id in TB_MANAGER.user_id%type,
  u_g_id out tb_discount_goods.g_id%type
)
as

begin

  select g_id into u_g_id from O_infor where O_id = (select O_id from (select O_id from tb_order where rownum=1 and tb_order.user_id=u_user_id));
  dbms_output.put_line(u_g_id);

exception

  when no_data_found then
    dbms_output.put_line('error');
    when others then
    dbms_output.put_line('one error');
end queryUser;

--调用

declare

  v1 tb_discount_goods.g_id%TYPE;

BEGIN

  queryUser('178', v1);

  dbms_output.put_line('name');

end;
```

输出结果如下。

Procedure QUERYUSER 已编译

 

423

name

 

PL/SQL 过程已成功完成。

#### 四、备份设计

**备份**

从虚拟机中拷贝出脚本文件rman_leve10.sh(全备份)，rman_level1.sh(增量备份)，查看脚本内容

```sql
[oracle@oracle-pc ~]$ cat rman_level0.sh 

\#rman_level0.sh 

\#!/bin/sh

 

export NLS_LANG='SIMPLIFIED CHINESE_CHINA.AL32UTF8'

export ORACLE_HOME=/home/oracle/app/oracle/product/12.1.0/dbhome_1 

export ORACLE_SID=orcl 

export PATH=$ORACLE_HOME/bin:$PATH 

 

 

rman target / nocatalog msglog=/home/oracle/rman_backup/lv0_`date +%Y%m%d-%H%M%S`_L0.log << EOF

run{

configure retention policy to redundancy 1;

configure controlfile autobackup on;

configure controlfile autobackup format for device type disk to '/home/oracle/rman_backup/%F';

configure default device type to disk;

crosscheck backup;

crosscheck archivelog all;

allocate channel c1 device type disk;

backup as compressed backupset incremental level 0 database format '/home/oracle/rman_backup/dblv0_%d_%T_%U.bak'

  plus archivelog format '/home/oracle/rman_backup/arclv0_%d_%T_%U.bak';

report obsolete;

delete noprompt obsolete;

delete noprompt expired backup;

delete noprompt expired archivelog all;

release channel c1;

}

EOF

 

exit
```

在用户oracle下运行脚本rman_level10.sh，

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210614111057421.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDc1MzY5MQ==,size_16,color_FFFFFF,t_70)


*.log 是日志文件

Dblv0*.bak 是数据库的备份文件

arclv0*.bak是归档日期的备份文件

c-1392946895-20191120-01是控制文件和参数的备份。

**修改数据**

```sql
[oracle@oracle-pc ~]$ sqlplus study/123@pdborcl

SQL> create table t2 (id number,name varchar2(50));

Table created.

SQL> insert into t2 values(1,'zhang');

1 row created.

SQL> commit;

Commit complete.

SQL> select * from t2;

 

    ID NAME

---------- --------------------------------------------------

     1 zhang

SQL> exit
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210614111110619.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDc1MzY5MQ==,size_16,color_FFFFFF,t_70)




**删除数据**

```sql
[oracle@oraclepc~]$ rm/home/oracle/app/oracle/oradata/orcl/pdborcl/SAMPLE_SCHEMA_users01.dbf

 

挂载数据库到mount状态

SQL> shutdown immediate

ORA-01116: 打开数据库文件 10 时出错

ORA-01110: 数据文件 10: '/home/oracle/app/oracle/oradata/orcl/pdborcl/SAMPLE_SCHEMA_users01.dbf'

ORA-27041: 无法打开文件

Linux-x86_64 Error: 2: No such file or directory

Additional information: 3

SQL> shutdown abort

ORACLE instance shut down.

SQL> startup mount

ORACLE instance started.

 

Total System Global Area 1577058304 bytes

Fixed Size         2924832 bytes

Variable Size       738201312 bytes

Database Buffers     654311424 bytes

Redo Buffers        13848576 bytes

In-Memory Area      167772160 bytes

Database mounted.

SQL>
```

![](https://img-blog.csdnimg.cn/20210614111121993.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDc1MzY5MQ==,size_16,color_FFFFFF,t_70)


恢复数据

```sql
[oracle@oracle-pc ~]$ rman target /

RMAN> restore database ;
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210614111137188.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NDc1MzY5MQ==,size_16,color_FFFFFF,t_70)


## 五、所遇到的问题和如何解决的

①、lsnrctl status 无监听

使用lsnrctl start来开启监听，但是在开启的过程中，监听要去寻找一个叫做listen.ora的文件，当时我将此文件更名为listen.ora.bak，所以在启动的时候没有找到文件，一直没有启动起来。

Lsnrctl的基本操作有server，start，stop。

②、ORACEL12C ORA-01033: ORACLE 正在初始化或关闭 进程 ID: 0 会话 ID: 0 序列号: 0

Oracle 中和其他版本的数据的启动关闭都是一样的，但是12c中有一个特殊点，就是在启动的时候需要修改会话到链接的pdb上面。例如：alter session set container=orclpdb.

③、使用sys或system用户登录，却没有权限？

Sqlplus “/ as sysdba” 