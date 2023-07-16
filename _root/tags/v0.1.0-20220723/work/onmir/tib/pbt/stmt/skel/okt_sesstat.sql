
drop table okt_sesstat_0;
drop table okt_sesstat_1;
drop table okt_sesstat_2;
drop table okt_sesstat_3;

create table okt_sesstat_0
as select sysdate dt, a.* from v$sesstat a where sid = 925 /* and name like '%time%' */ order by value desc
;

!sleep 10

create table okt_sesstat_2
as select sysdate dt, a.* from v$sesstat a where sid = 925 /* and name like '%time%' */ order by value desc
;


select x.*, ROUND( ( x.DF/x.DTM/1000 ), 1) AS VALUE2 from (
select b.*
     , (b.dt - a.dt) * ( 24 * 3600 ) AS DTM
     , b.value - a.value AS DF
  from okt_sesstat_0 a
     , okt_sesstat_2 b
 where 1=1
   and a.name = b.name
   and b.name like '%time%'
   and b.value > a.value
) x
order by DF desc
;

