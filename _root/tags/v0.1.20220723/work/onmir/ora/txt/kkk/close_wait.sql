select p.spid
     , s.sid
     , s.program
     , s.module
     , s.username
     , s.process
     , s.port
--, s.*
     , p.*
  from v$session s
     , v$process p
 where 1=1
   and s.program like 'sqlplus%'
--and s.sid = 1876
   and p.addr = s.paddr
   and s.username = 'MON_IMSI'
--and s.process = 649
   and s.port = 50056
;   
