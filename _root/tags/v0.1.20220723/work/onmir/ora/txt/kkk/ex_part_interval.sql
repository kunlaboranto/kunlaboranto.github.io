create table okt_intv_p (id number, dt date) partition by range(dt)
--interval( NUMTOYMinterval(1,'MONTH') )
interval( NUMTODSinterval(1,'DAY') )
--interval( NUMTODSinterval(1,'WEEK') )
--(partition pt_201604 values less than( to_date('20160501','YYYYMMDD') ))
(partition pt_max values less than( to_date('99991231','YYYYMMDD') ))
/

