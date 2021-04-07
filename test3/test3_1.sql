/*
ʵ�����ű��ļ�:
���ȴ����Լ����˺�your_user��Ȼ����system���ݵ�¼:

[student@deep02 ~]$sqlplus system/123@localhost/pdborcl
sql>alter user your_user quota unlimited on users;
sql>alter user your_user quota unlimited on users02;
sql>alter user your_user quota unlimited on users03;
sql>exit

Ȼ�����Լ����˺�your_user���ݵ�¼,�����нű��ļ�test3.sql:
[student@deep02 ~]$cat test3.sql
[student@deep02 ~]$sqlplus your_user/123@localhost/pdborcl
sql>@test3.sql
sql>exit

�ýű�������˺��´�����������������orders��һ�������ݣ���order_details�����������ݣ���


�ο���
1. oracle��������-- interval paritionʵ�鼰�ܽ�
   http://blog.chinaunix.net/uid-23284114-id-3304525.html
*/

declare
      num   number;
begin
      select count(1) into num from user_tables where table_name = 'order_details';
      if   num=1   then
          execute immediate 'drop table order_details cascade constraints purge';
      end   if;

      select count(1) into num from user_tables where table_name = 'orders';
      if   num=1   then
          execute immediate 'drop table orders cascade constraints purge';
      end   if;
end;
/

create table orders
(
  order_id number(10, 0) not null
, customer_name varchar2(40 byte) not null
, customer_tel varchar2(40 byte) not null
, order_date date not null
, employee_id number(6, 0) not null
, discount number(8, 2) default 0
, trade_receivable number(8, 2) default 0
, constraint orders_pk primary key
  (
    order_id
  )
  using index
  (
      create unique index orders_pk on orders (order_id asc)
      logging
      tablespace users
      pctfree 10
      initrans 2
      storage
      (
        buffer_pool default
      )
      noparallel
  )
  enable
)
tablespace users
pctfree 10
initrans 1
storage
(
  buffer_pool default
)
nocompress
noparallel
partition by range (order_date)
(
  partition partition_2015 values less than (to_date(' 2016-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss', 'nls_calendar=gregorian'))
  nologging
  tablespace users
  pctfree 10
  initrans 1
  storage
  (
    initial 8388608
    next 1048576
    minextents 1
    maxextents unlimited
    buffer_pool default
  )
  nocompress no inmemory
, partition partition_2016 values less than (to_date(' 2017-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss', 'nls_calendar=gregorian'))
  nologging
  tablespace users
  pctfree 10
  initrans 1
  storage
  (
    buffer_pool default
  )
  nocompress no inmemory
, partition partition_2017 values less than (to_date(' 2018-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss', 'nls_calendar=gregorian'))
  nologging
  tablespace users
  pctfree 10
  initrans 1
  storage
  (
    buffer_pool default
  )
  nocompress no inmemory
, partition partition_2018 values less than (to_date(' 2019-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss', 'nls_calendar=gregorian'))
  nologging
  tablespace users02
  pctfree 10
  initrans 1
  storage
  (
    buffer_pool default
  )
  nocompress no inmemory
, partition partition_2019 values less than (to_date(' 2020-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss', 'nls_calendar=gregorian'))
  nologging
  tablespace users02
  pctfree 10
  initrans 1
  storage
  (
    buffer_pool default
  )
  nocompress no inmemory
, partition partition_2020 values less than (to_date(' 2021-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss', 'nls_calendar=gregorian'))
  nologging
  tablespace users02
  pctfree 10
  initrans 1
  storage
  (
    buffer_pool default
  )
  nocompress no inmemory
, partition partition_2021 values less than (to_date(' 2022-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss', 'nls_calendar=gregorian'))
  nologging
  tablespace users03
  pctfree 10
  initrans 1
  storage
  (
    buffer_pool default
  )
  nocompress no inmemory
);

create table order_details
(
id number(10, 0) not null
, order_id number(10, 0) not null
, product_name varchar2(40 byte) not null
, product_num number(8, 2) not null
, product_price number(8, 2) not null
, constraint order_details_fk1 foreign key  (order_id)
references orders  (  order_id   )
enable
)
tablespace users
pctfree 10 initrans 1
storage (buffer_pool default )
nocompress noparallel
partition by reference (order_details_fk1);

declare
  dt date;
  m number(8,2);
  v_employee_id number(6);
  v_order_id number(10);
  v_name varchar2(100);
  v_tel varchar2(100);
  v number(10,2);
  v_order_detail_id number;
begin
-- system login:
-- ALTER USER "user_wen" QUOTA UNLIMITED ON USERS;
-- ALTER USER "user_wen" QUOTA UNLIMITED ON USERS02;
-- ALTER USER "user_wen" QUOTA UNLIMITED ON USERS03;
  v_order_detail_id:=1;
  delete from order_details;
  delete from orders;
  for i in 1..10000
  loop
    if i mod 6 =0 then
      dt:=to_date('2015-3-2','yyyy-mm-dd')+(i mod 60); --partition_2015
    elsif i mod 6 =1 then
      dt:=to_date('2016-3-2','yyyy-mm-dd')+(i mod 60); --partition_2016
    elsif i mod 6 =2 then
      dt:=to_date('2017-3-2','yyyy-mm-dd')+(i mod 60); --partition_2017
    elsif i mod 6 =3 then
      dt:=to_date('2018-3-2','yyyy-mm-dd')+(i mod 60); --partition_2018
    elsif i mod 6 =4 then
      dt:=to_date('2019-3-2','yyyy-mm-dd')+(i mod 60); --partition_2019
    else
      dt:=to_date('2020-3-2','yyyy-mm-dd')+(i mod 60); --partition_2020
    end if;
    v_employee_id:=case i mod 6 when 0 then 11 when 1 then 111 when 2 then 112
                                when 3 then 12 when 4 then 121 else 122 end;
    v_order_id:=i;
    v_name := 'aa'|| 'aa';
    v_name := 'zhang' || i;
    v_tel := '139888883' || i;
    insert into orders (order_id,customer_name,customer_tel,order_date,employee_id,discount)
      values (v_order_id,v_name,v_tel,dt,v_employee_id,dbms_random.value(100,0));
    v:=dbms_random.value(10000,4000);
    v_name:='computer'|| (i mod 3 + 1);
    insert into order_details(id,order_id,product_name,product_num,product_price)
      values (v_order_detail_id,v_order_id,v_name,2,v);
    v:=dbms_random.value(1000,50);
    v_name:='paper'|| (i mod 3 + 1);
    v_order_detail_id:=v_order_detail_id+1;
    insert into order_details(id,order_id,product_name,product_num,product_price)
      values (v_order_detail_id,v_order_id,v_name,3,v);
    v:=dbms_random.value(9000,2000);
    v_name:='phone'|| (i mod 3 + 1);

    v_order_detail_id:=v_order_detail_id+1;
    insert into order_details(id,order_id,product_name,product_num,product_price)
      values (v_order_detail_id,v_order_id,v_name,1,v);
    select sum(product_num*product_price) into m from order_details where order_id=v_order_id;
    if m is null then
     m:=0;
    end if;
    update orders set trade_receivable = m - discount where order_id=v_order_id;
    if i mod 1000 =0 then
      commit;
    end if;
  end loop;
end;
/
select count(*) from orders;
select count(*) from order_details;


set autotrace on

select * from your_user.orders where order_date
between to_date('2017-1-1','yyyy-mm-dd') and to_date('2018-6-1','yyyy-mm-dd');

select a.order_id,a.customer_name,
b.product_name,b.product_num,b.product_price
from your_user.orders a,your_user.order_details b where
a.order_id=b.order_id and
a.order_date between to_date('2017-1-1','yyyy-mm-dd') and to_date('2018-6-1','yyyy-mm-dd');