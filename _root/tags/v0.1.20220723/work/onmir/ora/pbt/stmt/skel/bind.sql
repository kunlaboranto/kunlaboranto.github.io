with wx as (
select /* OKT_MON_SKIP */
       LAST_CAPTURED
     , SQL_ID
     , POSITION
     , VALUE_STRING
  from V$SQL_BIND_CAPTURE a
 where 1=1
   --and sql_id = '70xbgqbtvdbj2'
   and sql_id in 
       ( select sql_id 
          from v$sqlarea x 
         where 1=1
           --and SQL_TEXT not like '%OKT_MON_SKIP%'
           and ( 1 = 0
               OR SQL_TEXT like '%/* SQL_ID xx */%' 
               )
       )   
 order by LAST_CAPTURED desc, POSITION
)
select *
  from wx
 pivot ( max(VALUE_STRING) for POSITION in (1,2,3,4,5,6) )
;
