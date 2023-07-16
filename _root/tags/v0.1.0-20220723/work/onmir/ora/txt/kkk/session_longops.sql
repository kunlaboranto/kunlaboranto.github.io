select SID
     , serial#
     , context
     , sofar
     , totalwork
     , round(sofar/totalwork*100,2) "%_complete"
     , SQL_EXEC_START
     , START_TIME
     , LAST_UPDATE_TIME
     , ROUND( ( LAST_UPDATE_TIME - START_TIME ) * 24 * 3600, 2) "DTM_SS"
     , ELAPSED_SECONDS
     , TIME_REMAINING
     , a.*
  from v$session_longops a
 where 1=1
   and a.opname like 'RMAN%'
   and a.opname not like '%aggregate%'
   --and a.totalwork <> 0
   --and a.sofar <> a.totalwork 
 order by a.start_time desc
;
