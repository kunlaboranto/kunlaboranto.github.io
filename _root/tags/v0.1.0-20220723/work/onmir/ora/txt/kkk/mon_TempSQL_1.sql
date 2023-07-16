-- temp 영역 사용 조사 쿼리
SELECT /* DBA_MON */
       /*+ ordered */
       "SID"
     , s.serial# "Serial"
     , s.MODULE "Module"
     , s.program "Program"
     , u.TABLESPACE "TS 명"
     , u.CONTENTS "Cont."
     , u.blocks "Temp Blocks"
     , ((u.blocks*v.value)/(1024*1024)) "Temp Size(MB)"
     , substr(q.sql_text,1,50) "SQL"
     , substr(p.sql_text,1,50) "이전 SQL"
  FROM v$sort_usage u
     , v$session s
     , v$sqltext q
     , v$sqltext p
     , (SELECT value
          FROM v$parameter
         WHERE name = 'db_block_size') v
 WHERE s.saddr = u.session_addr
   AND s.sql_hash_value = q.hash_value(+)
   AND q.piece = 0
   AND s.prev_hash_value = p.hash_value(+)
   AND p.piece = 0
   
  ;
