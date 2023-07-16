create or replace procedure SYS.SP_TABLE_INFO
(
  A_TABLE_NAME in VARCHAR(40)
) as
    V_USER_NAME VARCHAR(40);
    V_TABLE_NAME VARCHAR(40);
    V_TABLE_TYPE VARCHAR(40);
    V_TABLE_ID VARCHAR(40);
    V_TABLE_OID VARCHAR(40);
    V_SQL VARCHAR(1024);
    V_CNT_TB INTEGER;
    V_CNT_IX INTEGER;
    V_CNT_COL INTEGER;
    V_CNT_FK1 INTEGER;
    V_CNT_FK2 INTEGER;
    V_CNT INTEGER;
    V_SZ_TB NUMERIC(10,3);
    V_SZ_IX NUMERIC(10,3);
    V_LEN20 INTEGER;
    V_LEN05 INTEGER;
    V_LEN12 INTEGER;

    cursor C1
    is
    select U.USER_NAME
         , T.TABLE_NAME
         --, DECODE(T.TABLE_TYPE,'T','TABLE','V','VIEW','S','SEQ') TABLE_TYPE     
         , CASE WHEN TBS.TYPE IN (0,1,2) THEN 'M'
                WHEN TBS.TYPE IN (3,4) THEN 'D'
                WHEN TBS.TYPE IN (8) THEN 'V'
                ELSE T.TABLE_TYPE
            END AS TABLE_TYPE
         , T.TABLE_ID
         , T.TABLE_OID
      from SYSTEM_.SYS_USERS_ U
         , SYSTEM_.SYS_TABLES_ T
         , v$tablespaces TBS
     where U.USER_ID = T.USER_ID
       and U.USER_NAME LIKE 'US_%'
       and T.TABLE_NAME like UPPER(A_TABLE_NAME)
       and T.TABLE_TYPE = 'T' 
       and TBS.id = T.TBS_ID  
    ;

begin

    select
        MAX( LENGTH(T.TABLE_NAME) )
        into V_LEN20
    from
        SYSTEM_.SYS_USERS_ U,
        SYSTEM_.SYS_TABLES_ T
    where
        U.USER_ID = T.USER_ID
        and T.TABLE_NAME like UPPER(A_TABLE_NAME)
        and T.TABLE_TYPE = 'T'
    ;

    V_LEN20 := CASE2( V_LEN20>20, V_LEN20, 20 );
    V_LEN05 := 5;
    V_LEN12 := 14;

    open C1;

    SYSTEM_.PRINTLN( RPAD('OWNER',V_LEN12)||' |'||RPAD('TNAME',V_LEN20)||' |'||RPAD('TABTYPE',V_LEN05)||' |'||
LPAD('COL#',V_LEN05)||' |'||LPAD('NUM_ROWS',V_LEN12)||' |'||LPAD('TB (MB)',V_LEN12)||' |'||LPAD('IXs (MB)',V_LEN12)||' |'||
LPAD('IX#',V_LEN05)||' |'||LPAD('F_FK#',V_LEN05)||' |'||LPAD('T_FK#',V_LEN05) );
    SYSTEM_.PRINTLN( RPAD('-',120,'-') );

    V_CNT := 0;
    loop
        V_CNT_IX := NULL;
        V_CNT_FK1 := NULL;
        V_CNT_FK2 := NULL;

        fetch C1 into V_USER_NAME, V_TABLE_NAME, V_TABLE_TYPE, V_TABLE_ID, V_TABLE_OID;
        exit when C1%NOTFOUND;

        --if V_TABLE_TYPE = 'TABLE' then
        if V_TABLE_TYPE IN ('D', 'M', 'V') then

            -- UNIQUE CONSTRAINT 는 체크하지 못함 (BUG)
            select COUNT(*) into V_CNT_IX from SYSTEM_.SYS_INDICES_ where TABLE_ID = V_TABLE_ID ;

            -- COL#
            select COUNT(*) into V_CNT_COL from SYSTEM_.SYS_COLUMNS_ where TABLE_ID = V_TABLE_ID ;


            /* CONSTRAINT_TYPE 종류 : 1 - NOT NULL, 2 - UNIQUE, 3 - PK, 0 - FK */
            select
                COUNT(*) into V_CNT_FK1
            from SYSTEM_.SYS_CONSTRAINTS_
            where TABLE_ID = V_TABLE_ID and CONSTRAINT_TYPE = 0;

            select
                COUNT(*) into V_CNT_FK2
            from SYSTEM_.SYS_CONSTRAINTS_
            where REFERENCED_TABLE_ID = V_TABLE_ID and CONSTRAINT_TYPE = 0;

            -- # COUNT
            V_SQL := 'select COUNT(*) from '||V_USER_NAME||'.'||V_TABLE_NAME;
            EXECUTE IMMEDIATE V_SQL into V_CNT_TB;

            -- # TB SZ (MB)
            V_SQL := '
select round(c.extent_page_count * c.page_size * d.extent_total_count/1024/1024, 3) alloc
  from v$tablespaces c, v$segment d
 where 1 = 1
   and c.id = d.space_id
   and d.table_oid = ?
   and d.segment_type=''TABLE''
 UNION ALL
select round((c.fixed_alloc_mem+c.var_alloc_mem)/1024/1024,3) alloc
  from v$memtbl_info c
 where 1=1
   and c.table_oid = ?
';
            BEGIN
                EXECUTE IMMEDIATE V_SQL into V_SZ_TB using V_TABLE_OID, V_TABLE_OID;
            EXCEPTION
                WHEN OTHERS THEN
                    -- IF NOT FOUND, THEN MEMTBL
                    SYSTEM_.PRINTLN( 'V_TABLE_OID='||V_TABLE_OID );
                    RAISE;
            END;


            -- # IX SZ SUM (MB)
            if V_TABLE_TYPE IN ('M', 'V') then
                V_SZ_IX := ROUND( V_CNT_IX*V_CNT_TB*16/1024/1024, 3 );
            else -- 'D'
                V_SQL := '
select  
    sum(round(c.extent_page_count * c.page_size * d.extent_total_count/1024/1024, 3)) alloc
from v$tablespaces c, v$segment d, v$index e
where 1 = 1
    and c.id = d.space_id
    and d.table_oid = ?
    and d.segment_type=''INDEX''
    and d.segment_pid = e.index_seg_pid
    --and d.table_oid = e.table_oid
';
                EXECUTE IMMEDIATE V_SQL into V_SZ_IX using V_TABLE_OID;
            end if;

        end if;

        SYSTEM_.PRINTLN( RPAD(V_USER_NAME,V_LEN12)||' |'||RPAD(V_TABLE_NAME,V_LEN20)||' |'||RPAD(V_TABLE_TYPE,V_LEN05)||' |'||
LPAD(V_CNT_COL,V_LEN05)||' |'||LPAD(TRIM(TO_CHAR(V_CNT_TB,'9,999,999,999')),V_LEN12)||' |'||LPAD(TRIM(TO_CHAR(V_SZ_TB,'999,999.999')),V_LEN12)||' |'||LPAD(TRIM(TO_CHAR(NVL(V_SZ_IX,0),'999,999.999')),V_LEN12)||' |'||
LPAD(NVL(V_CNT_IX,0),V_LEN05)||' |'||LPAD(NVL(V_CNT_FK1,0),V_LEN05)||' |'||LPAD(NVL(V_CNT_FK2,0),V_LEN05) );

        V_CNT := V_CNT + 1;
    end loop;

    close C1;

    SYSTEM_.PRINTLN( RPAD('-',120,'-') );
    SYSTEM_.PRINTLN( V_CNT||' rows selected.' );
end;
/
