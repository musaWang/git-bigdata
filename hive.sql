


悟空	A	男
大海	A	男
宋宋	B	男
凤姐	A	女
婷姐	B	女
婷婷	B	女






//一  列转行
函数
{
	1 concat
	2 concat
	3 collect_set

}

// 建标语句

create table person_info(
name string, 
constellation string, 
blood_type string) 
row format delimited fields terminated by "\t";

// 元数据

孙悟空	白羊座	A
大海	射手座	A
宋宋	白羊座	B
猪八戒	白羊座	A
凤姐	射手座	A
苍老师	白羊座	B

// 1 血型和星座拼接
select name,concat(constellation,',',blood_type) conn from person_info;

select name ,  conn_blood from person_info group by concat(constellation,',',blood_type) conn_blood;

select concat(constellation,',',blood_type) conn_blood ,name from person_info group by conn_blood;

+-------+--------+
| name  |  _c1   |
+-------+--------+
| 孙悟空   | 白羊座,A  |
| 大海    | 射手座,A  |
| 宋宋    | 白羊座,B  |
| 猪八戒   | 白羊座,A  |
| 凤姐    | 射手座,A  |
| 苍老师   | 白羊座,B  |
+-------+--------+

// 2 按照拼接好的数据进行分组
select
   collect_set(t1.name) name_arr,
   t1.conn_blood
from
   (select name, concat(constellation,',',blood_type) conn_blood from person_info) t1
group by t1.conn_blood ;

+----------------+----------------+
|    name_arr    | t1.conn_blood  |
+----------------+----------------+
| ["大海","凤姐"]    | 射手座,A          |
| ["孙悟空","猪八戒"]  | 白羊座,A          |
| ["宋宋","苍老师"]   | 白羊座,B          |
+----------------+----------------+

// 3 拼接数组
select
   concat_ws('|',collect_set(t1.name)) name_con,
   t1.conn_blood
from
   (select name, concat(constellation,',',blood_type) conn_blood from person_info) t1
group by t1.conn_blood ;

+-----------+----------------+
| name_con  | t1.conn_blood  |
+-----------+----------------+
| 大海|凤姐     | 射手座,A          |
| 孙悟空|猪八戒   | 白羊座,A          |
| 宋宋|苍老师    | 白羊座,B          |
+-----------+----------------+


二 一行变多行

// 原数据

《疑犯追踪》	悬疑,动作,科幻,剧情
《Lie to me》	悬疑,警匪,动作,心理,剧情
《战狼 2》	战争,动作,灾难

+-------------------+----------------------+
| movie_info.movie  | movie_info.category  |
+-------------------+----------------------+
| 《疑犯追踪》            | 悬疑,动作,科幻,剧情          |
| 《Lie to me》       | 悬疑,警匪,动作,心理,剧情       |
| 《战狼 2》            | 战争,动作,灾难             |
+-------------------+----------------------+
// 建标语句
create table movie_info(
movie string,
category string)
row format delimited fields terminated by "\t";

// 1 explode & split
select explode(split(category,',')) from movie_info;
+------+
| col  |
+------+
| 悬疑   |
| 动作   |
| 科幻   |
| 剧情   |
| 悬疑   |
| 警匪   |
| 动作   |
| 心理   |
| 剧情   |
| 战争   |
| 动作   |
| 灾难   |
+------+

// 2 lateral view & explode & split
如果炸裂出来的数据，还需要跟之前的字段进行关联，则需要使用laterval view
SELECT
   movie,
   category_name
FROM
   movie_info
   lateral VIEW explode(split(category,",")) movie_info_tmp AS category_name;
+--------------+----------------+
|    movie     | category_name  |
+--------------+----------------+
| 《疑犯追踪》       | 悬疑             |
| 《疑犯追踪》       | 动作             |
| 《疑犯追踪》       | 科幻             |
| 《疑犯追踪》       | 剧情             |
| 《Lie to me》  | 悬疑             |
| 《Lie to me》  | 警匪             |
| 《Lie to me》  | 动作             |
| 《Lie to me》  | 心理             |
| 《Lie to me》  | 剧情             |
| 《战狼 2》       | 战争             |
| 《战狼 2》       | 动作             |
| 《战狼 2》       | 灾难             |
+--------------+----------------+

三 窗口函数 - over

// 3.1 原数据

jack,2017-01-01,10
tony,2017-01-02,15
jack,2017-02-03,23
tony,2017-01-04,29
jack,2017-01-05,46
jack,2017-04-06,42
tony,2017-01-07,50
jack,2017-01-08,55
mart,2017-04-08,62
mart,2017-04-09,68
neil,2017-05-10,12
mart,2017-04-11,75
neil,2017-06-12,80
mart,2017-04-13,94

// 3.2 建表sql
create table business(
name string,
orderdate string,
cost int
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

// 3.3 sql

// 1 在2017年四月份购买过的顾客及总人数

// 1.1 2017年四月份的购买记录
select * 
from business
where substring(orderdate,0,7)="2017-04";

+----------------+---------------------+----------------+
| business.name  | business.orderdate  | business.cost  |
+----------------+---------------------+----------------+
| jack           | 2017-04-06          | 42             |
| mart           | 2017-04-08          | 62             |
| mart           | 2017-04-09          | 68             |
| mart           | 2017-04-11          | 75             |
| mart           | 2017-04-13          | 94             |
+----------------+---------------------+----------------+

// 1.2 2017年四月份的购买顾客
select 
   distinct(name)
from business
where substring(orderdate,0,7)="2017-04";


+-------+
| name  |
+-------+
| jack  |
| mart  |
+-------+

// 1.2 2017年四月份的购买顾客人数
select 
   count(distinct(name))
from business
where substring(orderdate,0,7)="2017-04";

+------+
| _c0  |
+------+
| 2    |
+------+



2 查询顾客的购买明细及月购买总额  ---- over

2.1 select name, count(*) over() from business;
+----------------+---------------------+----------------+
| business.name  | business.orderdate  | business.cost  |
+----------------+---------------------+----------------+
| jack           | 2017-01-01          | 10             |
| tony           | 2017-01-02          | 15             |
| jack           | 2017-02-03          | 23             |
| tony           | 2017-01-04          | 29             |
| jack           | 2017-01-05          | 46             |
| jack           | 2017-04-06          | 42             |
| tony           | 2017-01-07          | 50             |
| jack           | 2017-01-08          | 55             |
| mart           | 2017-04-08          | 62             |
| mart           | 2017-04-09          | 68             |
| neil           | 2017-05-10          | 12             |
| mart           | 2017-04-11          | 75             |
| neil           | 2017-06-12          | 80             |
| mart           | 2017-04-13          | 94             |
+----------------+---------------------+----------------+

2.1 查询用户的购买明细及购买总额

select 
   name,
   orderdate,
   cost, 
   sum(cost) over(partition by name)
from business

+-------+-------------+-------+---------------+
| name  |  orderdate  | cost  | sum_window_0  |
+-------+-------------+-------+---------------+
| jack  | 2017-01-05  | 46    | 176           |
| jack  | 2017-01-08  | 55    | 176           |
| jack  | 2017-01-01  | 10    | 176           |
| jack  | 2017-04-06  | 42    | 176           |
| jack  | 2017-02-03  | 23    | 176           |
| mart  | 2017-04-13  | 94    | 299           |
| mart  | 2017-04-11  | 75    | 299           |
| mart  | 2017-04-09  | 68    | 299           |
| mart  | 2017-04-08  | 62    | 299           |
| neil  | 2017-05-10  | 12    | 92            |
| neil  | 2017-06-12  | 80    | 92            |
| tony  | 2017-01-04  | 29    | 94            |
| tony  | 2017-01-02  | 15    | 94            |
| tony  | 2017-01-07  | 50    | 94            |
+-------+-------------+-------+---------------+

2.2 查询用户的购买明细及月购买总额
select 
   name,
   orderdate,
   cost, 
   sum(cost) over(partition by name,month(orderdate))
from business

+-------+-------------+-------+---------------+
| name  |  orderdate  | cost  | sum_window_0  |
+-------+-------------+-------+---------------+
| jack  | 2017-01-05  | 46    | 111           |
| jack  | 2017-01-08  | 55    | 111           |
| jack  | 2017-01-01  | 10    | 111           |
| jack  | 2017-02-03  | 23    | 23            |
| jack  | 2017-04-06  | 42    | 42            |
| mart  | 2017-04-13  | 94    | 299           |
| mart  | 2017-04-11  | 75    | 299           |
| mart  | 2017-04-09  | 68    | 299           |
| mart  | 2017-04-08  | 62    | 299           |
| neil  | 2017-05-10  | 12    | 12            |
| neil  | 2017-06-12  | 80    | 80            |
| tony  | 2017-01-04  | 29    | 94            |
| tony  | 2017-01-02  | 15    | 94            |
| tony  | 2017-01-07  | 50    | 94            |
+-------+-------------+-------+---------------+

3 上述的场景, 将每个顾客的 cost 按照日期进行累加
select 
   name,
   orderdate,
   cost,
   sum(cost) over(partition by name order by orderdate)
from business;

+-------+-------------+-------+---------------+
| name  |  orderdate  | cost  | sum_window_0  |
+-------+-------------+-------+---------------+
| jack  | 2017-01-01  | 10    | 10            |
| jack  | 2017-01-05  | 46    | 56            |
| jack  | 2017-01-08  | 55    | 111           |
| jack  | 2017-02-03  | 23    | 134           |
| jack  | 2017-04-06  | 42    | 176           |
| mart  | 2017-04-08  | 62    | 62            |
| mart  | 2017-04-09  | 68    | 130           |
| mart  | 2017-04-11  | 75    | 205           |
| mart  | 2017-04-13  | 94    | 299           |
| neil  | 2017-05-10  | 12    | 12            |
| neil  | 2017-06-12  | 80    | 92            |
| tony  | 2017-01-02  | 15    | 15            |
| tony  | 2017-01-04  | 29    | 44            |
| tony  | 2017-01-07  | 50    | 94            |
+-------+-------------+-------+---------------+

4 查询每个顾客上次的购买时间. ----lag
(LAG(col,n,default_val)：往前第 n 行数据
 LEAD(col,n, default_val)：往后第 n 行数据)

select 
   name,
   orderdate,
   cost,
   lag(orderdate,1,'1900-01-01') over(partition by name order by orderdate ) 
as time1, 
   lag(orderdate,2) over (partition by name order by orderdate) 
as time2 
from business;

+-------+-------------+-------+-------------+-------------+
| name  |  orderdate  | cost  |    time1    |    time2    |
+-------+-------------+-------+-------------+-------------+
| jack  | 2017-01-01  | 10    | 1900-01-01  | NULL        |
| jack  | 2017-01-05  | 46    | 2017-01-01  | NULL        |
| jack  | 2017-01-08  | 55    | 2017-01-05  | 2017-01-01  |
| jack  | 2017-02-03  | 23    | 2017-01-08  | 2017-01-05  |
| jack  | 2017-04-06  | 42    | 2017-02-03  | 2017-01-08  |
| mart  | 2017-04-08  | 62    | 1900-01-01  | NULL        |
| mart  | 2017-04-09  | 68    | 2017-04-08  | NULL        |
| mart  | 2017-04-11  | 75    | 2017-04-09  | 2017-04-08  |
| mart  | 2017-04-13  | 94    | 2017-04-11  | 2017-04-09  |
| neil  | 2017-05-10  | 12    | 1900-01-01  | NULL        |
| neil  | 2017-06-12  | 80    | 2017-05-10  | NULL        |
| tony  | 2017-01-02  | 15    | 1900-01-01  | NULL        |
| tony  | 2017-01-04  | 29    | 2017-01-02  | NULL        |
| tony  | 2017-01-07  | 50    | 2017-01-04  | 2017-01-02  |
+-------+-------------+-------+-------------+-------------+

5 查询前20%事件的订单信息 ------ntile
select 
   name,
   orderdate,
   cost,
   ntile(5) over (order by orderdate) groupId
from business;
+-------+-------------+-------+----------+
| name  |  orderdate  | cost  | groupid  |
+-------+-------------+-------+----------+
| jack  | 2017-01-01  | 10    | 1        |
| tony  | 2017-01-02  | 15    | 1        |
| tony  | 2017-01-04  | 29    | 1        |
| jack  | 2017-01-05  | 46    | 2        |
| tony  | 2017-01-07  | 50    | 2        |
| jack  | 2017-01-08  | 55    | 2        |
| jack  | 2017-02-03  | 23    | 3        |
| jack  | 2017-04-06  | 42    | 3        |
| mart  | 2017-04-08  | 62    | 3        |
| mart  | 2017-04-09  | 68    | 4        |
| mart  | 2017-04-11  | 75    | 4        |
| mart  | 2017-04-13  | 94    | 4        |
| neil  | 2017-05-10  | 12    | 5        |
| neil  | 2017-06-12  | 80    | 5        |
+-------+-------------+-------+----------+

4 窗口函数 - rank

RANK()         排序相同时会重复，总数不会变
DENSE_RANK()   排序相同时会重复，总数会减少
ROW_NUMBER()   会根据顺序计算

4.1 原始数据
孙悟空 语文 87
孙悟空 数学 95
孙悟空 英语 68
大海 语文 94
大海 数学 56
大海 英语 84
宋宋 语文 64
宋宋 数学 86
宋宋 英语 84
婷婷 语文 65
婷婷 数学 85
婷婷 英语 78

4.2 建表sql
create table score(
name string,
subject string, 
score int) 
row format delimited fields terminated by "\t";


4.3 rank
select 
   name,
   subject,
   score,
rank() over (order by score)
from score;

+-------+----------+--------+----------------+
| name  | subject  | score  | rank_window_0  |
+-------+----------+--------+----------------+
| 大海    | 数学       | 56     | 1              |
| 宋宋    | 语文       | 64     | 2              |
| 婷婷    | 语文       | 65     | 3              |
| 孙悟空  | 英语       | 68     | 4              |
| 婷婷    | 英语       | 78     | 5              |
| 宋宋    | 英语       | 84     | 6              |
| 大海    | 英语       | 84     | 6              |
| 婷婷    | 数学       | 85     | 8              |
| 宋宋    | 数学       | 86     | 9              |
| 孙悟空  | 语文       | 87     | 10             |
| 大海    | 语文       | 94     | 11             |
| 孙悟空  | 数学       | 95     | 12             |
+-------+----------+--------+----------------+

select name,
subject,
score,
rank() over(partition by subject order by score desc) rp,
dense_rank() over(partition by subject order by score desc) drp,
row_number() over(partition by subject order by score desc) rmp
from score;
name subject score rp drp rmp
孙悟空 数学    95   1  1     1
宋宋 数学       86 2 2 2
婷婷 数学 85 3 3 3
大海 数学 56 4 4 4
宋宋 英语 84 1 1 1
大海 英语 84 1 1 2
婷婷 英语 78 3 2 3
孙悟空 英语 68 4 3 4
大海 语文 94 1 1 1
孙悟空 语文 87 2 2 2
婷婷 语文 65 3 3 3
宋宋 语文 64 4 4 4


四 自定义UDF函数
create  temporary function my_len as "com.datasum.udf.MyUdf.java"








1.8.64.69 -73  
255.

五 练习
5.1 原始数据表
（1）gulivideo_ori
create table gulivideo_ori(
videoId string, 
uploader string, 
age int, 
category array<string>, 
length int, 
views int, 
rate float, 
ratings int, 
comments int,
relatedId array<string>)
row format delimited fields terminated by "\t"
collection items terminated by "&"
stored as textfile;

（2）创建原始数据表: gulivideo_user_ori
create table gulivideo_user_ori(
uploader string,
videos int,
friends int)
row format delimited 
fields terminated by "\t" 
stored as textfile;

5.2 ORC表
（1）gulivideo_orc
create table gulivideo_orc(
videoId string, 
uploader string, 
age int, 
category array<string>, 
length int, 
views int, 
rate float, 
ratings int, 
comments int,
relatedId array<string>)
stored as orc
tblproperties("orc.compress"="SNAPPY");

（2）gulivideo_user_orc
create table gulivideo_user_orc(
uploader string,
videos int,
friends int)
row format delimited 
fields terminated by "\t" 
stored as orc
tblproperties("orc.compress"="SNAPPY");


统计datasum影音视频网站的常规指标，各种 TopN 指标：
   1 统计视频观看数 Top10

select 
    videoId
from gulivideo_orc
order by views desc
limit 10;
   2 统计视频类别热度 Top10(每个类别下的视频数)
   2.1 将数组炸裂
select   
   explode(category) 
from gulivideo_orc; 

+----------------+
|      col       |
+----------------+
| Entertainment  |
| Music          |
| Comedy         |
| Comedy         |
| Music          |
| Music          |
| Comedy         |
| People         |
| Blogs          |
| Entertainment  |
+----------------+

   2.2 将视频 类型炸裂出来  并与videoIDg关联
select 
   videoId, 
   category_name 
from  gulivideo_orc 
lateral view explode(category) category_tmp as category_name
limit 10 ;
+--------------+----------------+
|   videoid    | category_name  |
+--------------+----------------+
| LKh7zAJ4nwo  | Entertainment  |
| 7D0Mf4Kn4Xk  | Music          |
| n1cEq1C8oqQ  | Comedy         |
| OHkEzL4Unck  | Comedy         |
| -boOvAGNKUc  | Music          |
| hFFH8DaOHQg  | Music          |
| LzHjIj3fpR8  | Comedy         |
| SDNkMu8ZT68  | People         |
| SDNkMu8ZT68  | Blogs          |
| PkGUU_ggO3k  | Entertainment  |
+--------------+----------------+
2.2 将视频 类型炸裂出来   并取前10名
select 
   category_name,
   count(*) ct
from (select   
   explode(category) category_name 
   from gulivideo_orc )  t1
group  by category_name
order by ct desc
limit 10;

   3 统计出视频观看数最高的 20 个视频的所属类别以及类别包含 Top20 视频的个数
3.1 求出视频观看数最多的20个视频的所属类别
select
   category,
   views
from gulivideo_orc
order by views  desc
limit 20;t1
+---------------------+-----------+
|      category       |   views   |
+---------------------+-----------+
| ["Comedy"]          | 42513417  |
| ["Comedy"]          | 20282464  |
| ["Entertainment"]   | 16087899  |
| ["Entertainment"]   | 15712924  |
| ["Music"]           | 15256922  |
| ["People","Blogs"]  | 13199833  |
| ["Comedy"]          | 11970018  |
| ["Music"]           | 11823701  |
| ["Music"]           | 11672017  |
| ["People","Blogs"]  | 11184051  |
| ["Entertainment"]   | 10786529  |
| ["Entertainment"]   | 10334975  |
| ["Comedy"]          | 10107491  |
| ["Music"]           | 9579911   |
| ["Comedy"]          | 9566609   |
| ["UNA"]             | 8825788   |
| ["Music"]           | 7533070   |
| ["Entertainment"]   | 7456875   |
| ["Comedy"]          | 7066676   |
| ["Entertainment"]   | 6952767   |
+---------------------+-----------+

3.2 将所属类别炸开
select
   explode(category)  category_name
from  (
  select
      category
  from gulivideo_orc
  order by views  desc
  limit 20
)t1 ; t2

+----------------+
| category_name  |
+----------------+
| Comedy         |
| Comedy         |
| Entertainment  |
| Entertainment  |
| Music          |
| People         |
| Blogs          |
| Comedy         |
| Music          |
| Music          |
| People         |
| Blogs          |
| Entertainment  |
| Entertainment  |
| Comedy         |
| Music          |
| Comedy         |
| UNA            |
| Music          |
| Entertainment  |
| Comedy         |
| Entertainment  |
+----------------+
3.3 计算各个类别包含 Top20的个数
select 
   category_name,
   count(*) ct
from (select
   explode(category)  category_name
from  (
  select
      category
  from gulivideo_orc
  order by views  desc
  limit 20
  )t1 
) t2
group by category_name;
+----------------+-----+
| category_name  | ct  |
+----------------+-----+
| Blogs          | 2   |
| Comedy         | 6   |
| Entertainment  | 6   |
| Music          | 5   |
| People         | 2   |
| UNA            | 1   |
+----------------+-----+
   4 统计视频观看数 Top50 所关联视频的所属类别排序
4.1  求出视频观看数top50的视频所关联的视频（数组）
select
   relatedId,
   views
from gulivideo_orc
order by views  desc
limit 50;
+----------------------------------------------------+-----------+
|                     relatedid                      |   views   |
+----------------------------------------------------+-----------+
| ["OxBtqwlTMJQ","1hX1LxXwdl8","NvVbuVGtGSE","Ft6fC6RI4Ms","plv1e3MvxFw","1VL-ShAEjmg","y8k5QbVz3SE","weRfgj_349Q","_MFpPziLP9o","0M-xqfP1ibo","n4Pr_iCxxGU","UrWnNAMec98","QoREX_TLtZo","I-cm3GF-jX0","doIQXfJvydY","6hD3gGg9jMk","Hfbzju1FluI","vVN_pLl5ngg","3PnoFu027hc","7nrpwEDvusY"] | 42513417  |
| ["ut5fFyTkKv4","cYmeG712dD0","aDiNeF5dqnA","lNFFR1uwPGo","5Iyw4y6QR14","N1NO0iLbEt0","YtmGrR0tR7E","GZltV9lWQL4","qUDLSsSrrRA","wpQ1llsQ7qo","u9w2z-xtmqY","txVJgU3n72g","M6KcfOAckmw","orkbRVgRys0","HSuSo9hG_RI","3H3kKJLQgPs","46EsU9PmPyk","nn4XzrI1LLk","VTpKh6jFS7M","xH4b9ydgaHk"] | 20282464  |
| ["x0dzQeq6o5Q","BVvxtb0euBY","Tc4iq0IaPgE","caYdEBT36z0","Wch5akcVofs","FgN4E9-U82s","a0ffAHbxsLY","BaR9j3-radY","jbNCtXtAwUo","XJBfdkDlubU","c6JRE4ZBcuA","nRGZJ8GMg3g","BfR7iz2UqZY","cVHrwiP2vro","CowiFyYfcH4","uYxKs7xXopc","dzYaq2yOCb8","9o_D-M91Hhc","0O04jXoZmgY","XphZDHtt3D0"] | 16087899  |
| ["RB-wUgnyGv0","Bdgffnf8Hfw","YSLFsov31dA","KDmGXlOJPbQ","Hr-48XYy9Ns","6E1s0LDL-uM","0j3iXi0V3hk","uEXlbUV45pw","KvMsc6OdKWc","9kGIbR7dqyQ","pEu1muGrREA","DolERIvMbzM","gPtR2eSeDIw","3EpF4fRoT4U","Dl2roCEKffM","QERUjf8fbII","9oviIyGYolo","dblCjXdP7bo","IMPGIaXCnaA","TdGgKd4ZyuY"] | 15712924  |
| ["O9mEKMz2Pvo","Ddn4MGaS3N4","CBgf2ZxIDZk","r2BOApUvFpw","dVUgd8ot6BE","OUi9-jqq_i0","AbndgwfG22k","K3fvB4QO1qo","6rIJJp6aMlA","9wItsn3r_kc","cueXmJDbbvU","Ua3hZXfNZOE","Z2Rl5BsnfdY","pZ9jrBg4Lwc","dt1fB62cGbo","idb2dUtTpuU","j01x2lAFRwk","LmcjAGJOPR0","kFhQM7R4yjM","rNNcMDZn2Qk"] | 15256922  |
| ["GkVBObv8TQk","7XLt3Xwk3tQ","sr6GxRTdVlI","B1VllaFM17s","uwYkpZ7w5zc","4i4FWzjFTD8","HSrnW-5ygGI","5dBqnUbWOvg","4jvWyog4mWc","PZzkv2lVWeo","AxM5-6ASt_Y","y14JVDMHTUI","EuB8ARGq4og","motWHRAG7vM","IcG5txNV86U","C2PtULZvEpk","EOLEVxmZr1A","156Fi29rrMc","LjeXlIhTrgY","3oLq8kUVYco"] | 13199833  |
| ["brh6KRvQHBc","PICUHGauaj8","VLakIz4VzVo","RD7rhrm1wEo","qG7TQlDPRHk","_gyL1Hf0hjg","_1eRU6zZrJM","iIls6F7pI1Q","rtpJ4ZdFodU","4jvWyog4mWc","vg5eoNgxHn0","87BKJzxeJPY","xVf7wIePbD0","jTMwm0hioKA","6grHp7kOGMU","Z7FqXfye2io","NeZFDgsTCJc","5g3EwTZffn4","XHDWL1n1oFg","hl7RHY2H6-A"] | 11970018  |

4.2  将关联视频炸开
select
  explode(relatedId) related_id
from (
   select
     relatedId,
     views
   from gulivideo_orc
   order by views  desc
   limit 50
)t1 ;
+--------------+
|  related_id  |
+--------------+
| K6FJukNqMKc  |
| JojoMIZTr44  |
| XR8L2aVVq2A  |
| _zdT1IoScRE  |
| -0NOL61faoQ  |
| AW7Uyf0wtt0  |
| 8Ip854CID0I  |
| b_jvk2-6l58  |
| C1d3wf40iVA  |
| qSEwr3ApDDk  |
| 4Kk34Sqs9Fk  |
| EhGItc9HJCg  |

4.3  join 原表,取出关联视频所属的类别(数组)
select 
   g.category
from (
   select
   explode(relatedId) related_Id
from (
   select
     relatedId,
     views
   from gulivideo_orc
   order by views  desc
   limit 50
) t1 ) t2  
join gulivideo_orc  g
on t2.related_Id=g.videoId;

4.4 炸裂类别字段
select 
   explode(category)
from(
   select 
   g.category
from (
   select
   explode(relatedId) related_Id
from (
   select
     relatedId,
     views
   from gulivideo_orc
   order by views  desc
   limit 50
) t1 ) t2  
join gulivideo_orc  g
on t2.related_Id=g.videoId
) t3

|      col       |
+----------------+
| Entertainment  |
| Entertainment  |
| Entertainment  |
| Sports         |
| Comedy         |
| Music          |
| Entertainment  |
| Music          |
| Music          |
| Film           |
| Animation      |
| Comedy         |
| Film           |
| Animation      |
| Entertainment  |
| Entertainment  |
| Travel         |
| Places         |
| Music          |
| Howto          |
| DIY            |
| Entertainment  |
| Entertainment  |
| Comedy         |
| Comedy         |
| Music          |
| Entertainment  |
| Entertainment  |
| Comedy         |
| Comedy         |
| Comedy         |
| Howto          |
| DIY            |
| News           |
| Politics       |
| Entertainment  |
| Gadgets        |
| Games          |
| Music          |
| Entertainment  |
| Music          |
| Comedy         |
| Comedy         |
| Gadgets        |
| Games          |
| Entertainment  |
| Comedy         |
| Music          |
| Entertainment  |
| Comedy         |
+----------------+

4.5 按照类别分组，求 count,并按照count排序。
select
   category_name,
   count(category_name) ct
from (
   select 
   explode(category) category_name
from(
   select 
   g.category
from (
   select
   explode(relatedId) related_Id
from (
   select
     relatedId,
     views
   from gulivideo_orc
   order by views  desc
   limit 50
) t1 ) t2  
join gulivideo_orc  g
on t2.related_Id=g.videoId
) t3
)t4
group by  category_name
order by ct  desc

+----------------+------+
| category_name  |  ct  |
+----------------+------+
| Comedy         | 237  |
| Entertainment  | 216  |
| Music          | 195  |
| People         | 51   |
| Blogs          | 51   |
| Film           | 47   |
| Animation      | 47   |
| Politics       | 24   |
| News           | 24   |
| Gadgets        | 22   |
| Games          | 22   |
| Sports         | 19   |
| DIY            | 14   |
| Howto          | 14   |
| UNA            | 13   |
| Travel         | 12   |
| Places         | 12   |
| Animals        | 11   |
| Pets           | 11   |
| Autos          | 4    |
| Vehicles       | 4    |
+----------------+------+

   5 统计每个类别中的视频热度 Top10,(以 Music 为例)
5.1 将所属类别炸开，并存储在新表中
create table gulivideo_orc_category(
videoId string, 
uploader string, 
age int, 
category string, 
length int, 
views int, 
rate float, 
ratings int, 
comments int,
relatedId array<string>)
stored as orc
tblproperties("orc.compress"="SNAPPY");

insert into table gulivideo_orc_category
select
  videoId , 
  uploader , 
  age , 
  category_name , 
  length , 
  views , 
  rate , 
  ratings , 
  comments ,
  relatedId 
from gulivideo_orc lateral view explode(category) category_tmp as category_name;

5.3 最终sql
select 
   videoId,
   views
from gulivideo_orc_category
where category="Music"
order by views desc
limit 10;

   6 统计每个类别视频观看数 Top10 
 
 6.1 求每个类别视频观看数排行
 select
   category,
   videoId,
   views
   rank() over(partition by category order by views desc) rk 
from gulivideo_orc_category;

6.2 取出前三名
select
   category,
   videoId,
   views
from(
  select
   category,
   videoId,
   views,
   rank() over(partition by category order by views desc) rk 
  from gulivideo_orc_category
) t1 
where t1.rk <= 3; 

+----------------+--------------+-----------+
|    category    |   videoid    |   views   |
+----------------+--------------+-----------+
| Comedy         | dMH0bHeiRNg  | 42513417  |
| Comedy         | 0XxI-hvPRRA  | 20282464  |
| Comedy         | 49IDp76kjPw  | 11970018  |
| UNA            | aRNzWyD7C9o  | 8825788   |
| UNA            | jtExxsiLgPM  | 5320895   |
| UNA            | PxNNR4symuE  | 4033376   |
| Autos          | RjrEQaG5jPM  | 2803140   |
| Autos          | cv157ZIInUk  | 2773979   |
| Autos          | Gyg9U1YaVk8  | 1832224   |
| Blogs          | -_CSo1gOd48  | 13199833  |
| Blogs          | D2kJZOfq7zk  | 11184051  |
| Blogs          | pa_7P5AbUww  | 5705136   |
| DIY            | hut3VRL5XRE  | 2684989   |
| DIY            | YYTpb-QXV0k  | 2492153   |
| DIY            | Pf3z935R37E  | 2096661   |
| Travel         | bNF_P281Uu4  | 5231539   |
| Travel         | s5ipz_0uC_U  | 1198840   |
| Travel         | 6jJW7aSNCzU  | 1143287   |
| Animation      | sdUUx5FdySs  | 5840839   |
| Animation      | 6B26asyGKDo  | 5147533   |
| Animation      | H20dhY01Xjk  | 3772116   |
| Music          | QjA5faZF1A8  | 15256922  |
| Music          | tYnn51C3X_w  | 11823701  |
| Music          | pv5zWaTEVkI  | 11672017  |
| Gadgets        | pFlcqWQVVuU  | 3651600   |
| Gadgets        | bcu8ZdJ2dQo  | 2617568   |
| Gadgets        | -G7h626wJwM  | 2565170   |
| Places         | bNF_P281Uu4  | 5231539   |
| Places         | s5ipz_0uC_U  | 1198840   |
| Places         | 6jJW7aSNCzU  | 1143287   |
| Sports         | Ugrlzm7fySE  | 2867888   |
| Sports         | q8t7iSGAKik  | 2735003   |
| Sports         | 7vL19q8yL54  | 2527713   |
| Vehicles       | RjrEQaG5jPM  | 2803140   |
| Vehicles       | cv157ZIInUk  | 2773979   |
| Vehicles       | Gyg9U1YaVk8  | 1832224   |
| Animals        | 2GWPOPSXGYI  | 3660009   |
| Animals        | xmsV9R8FsDA  | 3164582   |
| Animals        | 12PsUW-8ge4  | 3133523   |
| Film           | sdUUx5FdySs  | 5840839   |
| Film           | 6B26asyGKDo  | 5147533   |
| Film           | H20dhY01Xjk  | 3772116   |
| People         | -_CSo1gOd48  | 13199833  |
| People         | D2kJZOfq7zk  | 11184051  |
| People         | pa_7P5AbUww  | 5705136   |
| Politics       | hr23tpWX8lM  | 4706030   |
| Politics       | YgW7or1TuFk  | 2899397   |
| Politics       | nda_OSWeyn8  | 2817078   |
| Games          | pFlcqWQVVuU  | 3651600   |
| Games          | bcu8ZdJ2dQo  | 2617568   |
| Games          | -G7h626wJwM  | 2565170   |
| Howto          | hut3VRL5XRE  | 2684989   |
| Howto          | YYTpb-QXV0k  | 2492153   |
| Howto          | Pf3z935R37E  | 2096661   |
| Pets           | 2GWPOPSXGYI  | 3660009   |
| Pets           | xmsV9R8FsDA  | 3164582   |
| Pets           | 12PsUW-8ge4  | 3133523   |
| Entertainment  | 1dmVU08zVpA  | 16087899  |
| Entertainment  | RB-wUgnyGv0  | 15712924  |
| Entertainment  | vr3x_RRJdd4  | 10786529  |
| News           | hr23tpWX8lM  | 4706030   |
| News           | YgW7or1TuFk  | 2899397   |
| News           | nda_OSWeyn8  | 2817078   |
+----------------+--------------+-----------+

   7 统计上传视频最多的用户 Top10 以及他们上传的视频观看次数在自己前 20 的视频

7.1 统计上传视频最多的用户 Top10
select
  uploader,
  videos
from gulivideo_user_orc
order by videos desc
limit 10;

+---------------------+---------+
|      uploader       | videos  |
+---------------------+---------+
| expertvillage       | 86228   |
| TourFactory         | 49078   |
| myHotelVideo        | 33506   |
| AlexanderRodchenko  | 24315   |
| VHTStudios          | 20230   |
| ephemeral8          | 19498   |
| HSN                 | 15371   |
| rattanakorn         | 12637   |
| Ruchaneewan         | 10059   |
| futifu              | 9668    |
+---------------------+---------+

7.2 取出前10用户所上传的所有视频
select
  uploader,
  videoId,
  views
from 
  t1 
join gulivideo_orc g 
on t1.uploader=g.uploader;

7.3 对上传视频最多的用户的视频进行排名
select
  uploader,
  videoId,
  views,
  rank() over(partition by uploader order by views) rk 
from t2;

7.4 取上传视频最多的用户的视频 排名前3的
select
 uploader,
 videoId,
 views
 from
 (select
  uploader,
  videoId,
  views,
  rank() over(partition by uploader order by views) rk 
from (
   select
  uploader,
  videoId,
  views
from(
   select
  uploader,
  videos
from gulivideo_user_orc
order by videos desc
limit 10
) 
  t1 
join gulivideo_orc g 
on t1.uploader=g.uploader
) t2)t3 
 where rk <= 5;









六 Spark-sql 案例实操

一共有3张表： 1张用户行为表，1张城市表，1 张产品表
1 数据准备
CREATE TABLE `user_visit_action`(
  `date` string,  
  `user_id` bigint,
  `session_id` string,
  `page_id` bigint,
  `action_time` string,
  `search_keyword` string,
  `click_category_id` bigint,
  `click_product_id` bigint,
  `order_category_ids` string,
  `order_product_ids` string,
  `pay_category_ids` string,
  `pay_product_ids` string,
  `city_id` bigint)
row format delimited fields terminated by '\t';
load data local inpath 'input/user_visit_action.txt' into table user_visit_action;

CREATE TABLE `product_info`(
  `product_id` bigint,
  `product_name` string,
  `extend_info` string)
row format delimited fields terminated by '\t';
load data local inpath 'input/product_info.txt' into table product_info;

CREATE TABLE `city_info`(
  `city_id` bigint,
  `city_name` string,
  `area` string)
row format delimited fields terminated by '\t';
load data local inpath 'input/city_info.txt' into table city_info;


2 需求简介
这里的热门商品是从点击量的维度来看的，计算各个区域前三大热门商品，并备注上每个商品在主要城市中的分布比例，超过两个城市用其他显示。

地区 商品名称    点击次数      城市备注
华北 商品A      100000       北京21.2%，天津13.2%，其他65.6%
华北 商品P      80200        北京63.0%，太原10%，其他27.0%
华北 商品M      40000        北京63.0%，太原10%，其他27.0%
东北 商品J      92000        大连28%，辽宁17.0%，其他 55.0%

3 sql实现

// 1 数据join生成所需宽表
select
    a.*,
    p.product_name,
    c.area,
    c.city_name
from user_visit_action a
join product_info p on a.click_product_id=p.product_id
join city_info c on a.city_id = c.city_id
where a.click_product_id > -1



// 2 按地区和商品名称分组
select
    area,
    product_name,
    count(*)
from(
    select
        a.*,
        p.product_name,
        c.area,
        c.city_name
    from user_visit_action a
    join product_info p on a.click_product_id=p.product_id
    join city_info c on a.city_id = c.city_id
    where a.click_product_id > -1

    ) t1 group by area,product_name

area   product_name     count(1)
华东,   商品_72,         311
华东,   商品_53,         345
华北,   商品_94,         235
华中,   商品_69,         110
华东,   商品_58,         350
西南,   商品_9,          138
东北,   商品_100,        131
西北,   商品_59,         92
西北,   商品_43,         98
华南,   商品_11,         209
西北,   商品_87,         98
华北,   商品_54,         229
西北,   商品_97,         89


select
*
from(
    select
        *,
        rank() over (partition by area order by click_cnt desc) as rank

    from (

        select
            area,
            product_name,
            count(*) click_cnt
        from(
            select
                a.*,
                p.product_name,
                c.area,
                c.city_name
            from user_visit_action a
            join product_info p on a.click_product_id=p.product_id
            join city_info c on a.city_id = c.city_id
            where a.click_product_id > -1

        ) t1 group by area,product_name
         ) t2
        ) t3 where t3.rank <= 3


area product_name count rank
华东,商品_86,371,1
华东,商品_47,366,2
华东,商品_75,366,2
华南,商品_23,224,1
华南,商品_65,222,2
华南,商品_50,212,3
西北,商品_15,116,1
西北,商品_2,114,2
西北,商品_22,113,3
东北,商品_41,169,1
东北,商品_91,165,2
东北,商品_93,159,3
东北,商品_58,159,3
华中,商品_62,117,1
华中,商品_4,113,2
华中,商品_29,111,3
华中,商品_57,111,3
华北,商品_99,264,1
华北,商品_42,264,1
华北,商品_19,260,3
西南,商品_1,176,1
西南,商品_44,169,2
西南,商品_60,163,3


