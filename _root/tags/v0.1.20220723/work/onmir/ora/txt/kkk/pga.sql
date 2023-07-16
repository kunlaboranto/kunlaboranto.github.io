select * from (
select s.sid
     , s.serial#
     , p.spid as "os pid"
     , s.username
     , s.module
     , s.sql_id
     , s.status
     , event
     , seconds_in_wait
     , st.value as "cpu sec"
     , round(p.PGA_MAX_MEM/1024/1024) AS PGA_MAX_MEM
     , round(p.PGA_ALLOC_MEM/1024/1024) AS PGA_ALLOC_MEM
     , round(p.PGA_USED_MEM/1024/1024) AS PGA_USED_MEM
     , round(p.PGA_FREEABLE_MEM/1024/1024) AS PGA_FREEABLE_MEM
  from v$sesstat st
     , v$statname sn
     , v$session s
     , v$process p
 where 1=1
   and sn.name = 'CPU used by this session' -- cpu
   --and sn.name = '%session uga memory max%'
   and st.statistic# = sn.statistic#
   and st.sid = s.sid
   and s.paddr = p.addr
   and s.type <> 'BACKGROUND'
   --and s.last_call_et < 1800 -- active within last 1/2 hour
   --and s.logon_time > (SYSDATE - 240/1440) -- sessions logged on within 4 hours
 --order by st.value 
 order by p.pga_used_mem desc
) where rownum <= 10
;
