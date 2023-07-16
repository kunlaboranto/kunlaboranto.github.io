set linesize 200;
select b.session_id,
       --a.comm_name,
       --a.client_pid,
       b.id as stmt_id,
       --round(b.total_time/1000000) as total_time,
       b.total_time/1000000 as total_time,
       --nvl(ltrim(b.query), 'none') as query
       CAST( substr(nvl(ltrim(b.query), 'none'),1,20) AS VARCHAR(20) ) as query,
       b.execute_time/1000000 as execute_time,
       decode(last_query_start_time, 0, '-', to_char(to_date('1970010109', 'yyyymmddhh') + last_query_start_time / (24*60*60), 'mm/dd hh:mi:ss')) last_start_time
       --1
  from v$session a,
       v$statement b
 where a.id = b.session_id
   --and (b.execute_time/1000000) > 3600
   and execute_flag = 1
 order by b.execute_time desc
 limit 20
;
