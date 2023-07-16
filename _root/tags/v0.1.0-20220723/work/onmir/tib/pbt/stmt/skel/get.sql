set linesize 200
set pagesize 1000
col PROG_NAME format a60
col ERROR_MESSAGE format a88
col ERROR_LINE format a4                                                                            
col ERROR_DATE format a20

SELECT *
  FROM (SELECT *
          FROM (SELECT PROG_NAME
                     , ERROR_MESSAGE
                     , ERROR_LINE
                     , ERROR_DATE
                     , ERROR_SEQ
                  FROM US_SELECT.ERROR_LOG
                 WHERE 1=1
                   AND ERROR_DATE BETWEEN SYSDATE - 30 AND SYSDATE
                   AND ( 1=0
                       OR PROG_NAME LIKE 'OKT%'
                       OR PROG_NAME LIKE 'SP_KB_IKB010MT_JEOKJAE%' )
                 ORDER BY ERROR_DATE DESC , ERROR_SEQ DESC )
         WHERE ROWNUM < 400 )
 ORDER BY ERROR_DATE , ERROR_SEQ 
;
 
