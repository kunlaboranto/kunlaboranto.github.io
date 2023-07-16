create or replace procedure SYS.SP_TABLE_FK
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
    V_SZ_TB INTEGER;
    V_SZ_IX INTEGER;
    V_LEN20 INTEGER;
    V_LEN05 INTEGER;
    V_LEN12 INTEGER;

    cursor C1
    is
    select U.USER_NAME
         , T.TABLE_NAME
         , DECODE(T.TABLE_TYPE,'T','TABLE','V','VIEW','S','SEQ') TABLE_TYPE
         , T.TABLE_ID
         , T.TABLE_OID
      from SYSTEM_.SYS_USERS_ U
         , SYSTEM_.SYS_TABLES_ T
     where 1=1
       AND U.USER_ID = T.USER_ID
       and T.TABLE_NAME like UPPER(A_TABLE_NAME)
       --and U.USER_NAME IN ('US_xx')
       and T.TABLE_TYPE = 'T'
     ORDER BY 1, 2
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
    V_LEN12 := 12;

    open C1;

    SYSTEM_.PRINTLN( RPAD('OWNER',V_LEN12)||' '||RPAD('TNAME',V_LEN20)||' '||RPAD('TABTYPE',V_LEN05)||' '||
LPAD('COL#',V_LEN05)||' '||LPAD('CNT',V_LEN12)||' '||LPAD('TB (MB)',V_LEN12)||' '||LPAD('IXs (MB)',V_LEN12)||' '||
LPAD('IX#',V_LEN05)||' '||LPAD('F_FK#',V_LEN05)||' '||LPAD('T_FK#',V_LEN05) );
    SYSTEM_.PRINTLN( RPAD('-',110,'-') );

    V_CNT := 0;
    loop
        V_CNT_IX := NULL;
        V_CNT_FK1 := NULL;
        V_CNT_FK2 := NULL;

        fetch C1 into V_USER_NAME, V_TABLE_NAME, V_TABLE_TYPE, V_TABLE_ID, V_TABLE_OID;
        exit when C1%NOTFOUND;

        if V_TABLE_TYPE = 'TABLE' then

            -- UNIQUE CONSTRAINT 는 체�㈖舊�못함 (BUG)
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
select  
    round(c.extent_page_count * c.page_size * d.extent_total_count/1024/1024, 3) alloc
from v$tablespaces c, v$segment d
where 1 = 1
    and c.id = d.space_id
    and d.table_oid = ?
    and d.segment_type=''TABLE''
';
            --EXECUTE IMMEDIATE V_SQL into V_SZ_TB using V_TABLE_OID;
            V_SZ_TB := -1;

            -- # IX SZ SUM (MB)
            V_SQL := '
select  
    sum(round(c.extent_page_count * c.page_size * d.extent_total_count/1024/1024, 3)) alloc
from v$tablespaces c, v$segment d, v$index e
where 1 = 1
    and c.id = d.space_id
    and d.table_oid = ?
    and d.segment_type=''INDEX''
    and d.segment_pid = e.index_seg_pid
    and d.table_oid = e.table_oid
';
            --EXECUTE IMMEDIATE V_SQL into V_SZ_IX using V_TABLE_OID;
            V_SZ_IX := -1;

        end if;

        SYSTEM_.PRINTLN( RPAD(V_USER_NAME,V_LEN12)||' '||RPAD(V_TABLE_NAME,V_LEN20)||' '||RPAD(V_TABLE_TYPE,V_LEN05)||' '||
LPAD(V_CNT_COL,V_LEN05)||' '||LPAD(TRIM(TO_CHAR(V_CNT_TB,'9,999,999,999')),V_LEN12)||' '||LPAD(TRIM(TO_CHAR(V_SZ_TB,'999,999')),V_LEN12)||' '||LPAD(TRIM(TO_CHAR(V_SZ_IX,'999,999')),V_LEN12)||' '||
LPAD(V_CNT_IX,V_LEN05)||' '||LPAD(V_CNT_FK1,V_LEN05)||' '||LPAD(V_CNT_FK2,V_LEN05) );

        V_CNT := V_CNT + 1;
    end loop;

    close C1;

    SYSTEM_.PRINTLN( RPAD('-',110,'-') );
    SYSTEM_.PRINTLN( V_CNT||' rows selected.' );
end;
/
