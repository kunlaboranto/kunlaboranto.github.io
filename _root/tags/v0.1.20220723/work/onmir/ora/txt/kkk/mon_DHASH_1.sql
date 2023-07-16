select to_char(SAMPLE_TIME, 'yyyy/mm/dd')
      , program
      , count(1) 
--      , sum(ROWS_PROCESSED_DELTA )
from DBA_HIST_ACTIVE_SESS_HISTORY 
where 1=1
  and to_char(SAMPLE_TIME, 'yyyy/mm/dd') >= to_char(sysdate - 9, 'yyyy/mm/dd')
  and program like 'iComBatchReceipt2.exe%'
group by to_char(SAMPLE_TIME, 'yyyy/mm/dd'), program
;
