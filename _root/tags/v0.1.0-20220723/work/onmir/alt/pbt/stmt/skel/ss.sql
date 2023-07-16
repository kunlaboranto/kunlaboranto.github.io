set term off
set linesize 200
set colsize 40

!rm -f spool.out
spool spool.out

select sysdate from dual;

--select name, value from v$sesstat a where sid = session_id() and name like '%page%';

select sysdate, name, value 
  from v$sesstat a 
 where 1=1
   and sid = session_id() 
   --and sid = 871
   --and name like '%page%'
   and ( value <> 0 
         --or name like '%page%' 
           or ( 1=0
                 --or name like '%time%' 
                 or ( name like '%time%' and value <> 0 )
                 or name like '%data page read'
                 --or name like '%data page write'
                 or name like '%data page gets'
                 or name like '%data page fix'
                 --or name like '%data page create'
                 --or name like '%undo page%'
               )
       )
   and ( 1=1 
         and name not like '%logon%' 
         --and name not like '%success%' 
         --and name not like '%socket%' 
         --and name not like '%byte%' 
         --and name not like '%lock%' 
         --and name not like '%scan%' 
       )
union all
select sysdate, '[event_us] '|| event as name, TIME_WAITED_MICRO value 
  from v$SESSION_EVENT a 
 where 1=1
   and sid = session_id() 
   --and sid = 871
   and TIME_WAITED_MICRO <> 0
;

!echo ""
select sysdate, '[ wait_ms] '|| a.event, a.WAIT_TIME, '   MySID='||a.SID from v$SESSION_WAIT a where a.SID = session_id();
select sysdate, '[ wait_ms] '|| a.event, a.WAIT_TIME, 'OtherSID='||a.SID from v$SESSION_WAIT a where a.SID <> session_id() and WAIT_TIME <> 0;

spool off
set term on

!echo ""
!cat spool.out |sed -e "s/ [ ]*$//g" |grep -e "^SYSDATE.*NAME" -e 20[12]

