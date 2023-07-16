SELECT SYSDATE
     , A.*
     , ROUND(A.VALUE*100/X.VALUE_SUM,2) PCT
  FROM 
       (
       SELECT SUM(VALUE) VALUE_SUM
         FROM V$SYSSTAT A
        WHERE 1=1
          AND A.NAME LIKE 'elapsed time%'
          AND A.NAME NOT LIKE 'elapsed time: query fetch'
          AND A.NAME LIKE 'elapsed time: query execute'
       ) X
     , V$SYSSTAT A
 WHERE 1=1
   AND A.NAME LIKE 'elapsed time%'
 ORDER BY A.VALUE DESC 
;
