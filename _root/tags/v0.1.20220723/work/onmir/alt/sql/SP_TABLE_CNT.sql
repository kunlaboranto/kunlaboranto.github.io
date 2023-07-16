create or replace procedure SYS.SP_TABLE_CNT
(
  A_TABLE_NAME in VARCHAR(40)
, A_CHK_CNT    in NUMBER(10) DEFAULT 0
, A_USER_NANE  in VARCHAR(40) DEFAULT NULL
) as
    V_USER_NAME VARCHAR(40);
    V_TABLE_NAME VARCHAR(40);
    V_KOR_NM VARCHAR(100);
    V_TABLE_TYPE VARCHAR(40);
    V_TABLE_ID VARCHAR(40);
    V_TABLE_OID VARCHAR(40);
    V_SQL VARCHAR(1024);
    V_CNT_TB_SUM NUMBER(19);
    V_CNT_TB NUMBER(10);
    V_CNT NUMBER(10);
    V_LEN15 NUMBER(10);
    V_LEN05 NUMBER(10);
    V_LEN14 NUMBER(10);

    cursor C1
    is
    select U.USER_NAME
         , T.TABLE_NAME
         , DECODE(T.TABLE_TYPE,'T','TABLE','V','VIEW','S','SEQ') TABLE_TYPE
         , T.TABLE_ID
         , T.TABLE_OID
         --, M.TAB_NAME
      from SYSTEM_.SYS_USERS_ U
         , SYSTEM_.SYS_TABLES_ T 
           --left outer join MIG.TBMAP_TABLIST M 
                   --on M.DATA_TYPE='T' and M.TAB_ID = T.TABLE_NAME
     where 1=1
       AND U.USER_NAME LIKE NVL(A_USER_NANE, 'US_%OWN')
       AND U.USER_ID = T.USER_ID
       and T.TABLE_NAME like UPPER(A_TABLE_NAME)
       and T.TABLE_TYPE = 'T'
       --and U.USER_NAME IN ('US_xx')
    ORDER BY T.TABLE_NAME
    ;

begin

    /********
    select
        MAX( LENGTH(T.TABLE_NAME) )
        into V_LEN15
    from
        SYSTEM_.SYS_USERS_ U,
        SYSTEM_.SYS_TABLES_ T
    where
        U.USER_ID = T.USER_ID
        and T.TABLE_NAME like UPPER(A_TABLE_NAME)
        and T.TABLE_TYPE = 'T'
    ;
    ***********/

    -- V_LEN15 := CASE2( V_LEN15>15, 15, V_LEN15 );
    --V_LEN15 := 15;
    V_LEN15 := 30;
    V_LEN05 := 5;
    V_LEN14 := 14;

    open C1;

    SYSTEM_.PRINTLN( RPAD('OWNERE',V_LEN14)||' '||RPAD('TABLE_ID',V_LEN15)||'  '||LPAD('CNT',V_LEN14) );
    SYSTEM_.PRINTLN( RPAD('-',100,'-') );

    V_CNT := 0;
    V_CNT_TB_SUM := 0;
    loop

        fetch C1 into V_USER_NAME, V_TABLE_NAME, V_TABLE_TYPE, V_TABLE_ID, V_TABLE_OID
        --, V_KOR_NM
        ;
        exit when C1%NOTFOUND;

        if V_TABLE_TYPE = 'TABLE' then

            -- # COUNT
            V_SQL := 'select COUNT(*) from '||V_USER_NAME||'.'||V_TABLE_NAME;
            EXECUTE IMMEDIATE V_SQL into V_CNT_TB;
        end if;

        if V_CNT_TB >= A_CHK_CNT then
           V_CNT := V_CNT + 1;
           V_CNT_TB_SUM := V_CNT_TB_SUM + V_CNT_TB;
           SYSTEM_.PRINTLN(
               RPAD(V_USER_NAME,V_LEN14)||' '||
               RPAD(V_TABLE_NAME,V_LEN15)||'  '||
               LPAD(TRIM(TO_CHAR(V_CNT_TB,'999,999,999,999')),V_LEN14) 
               --|| '  '||V_KOR_NM 
           );

        end if;
    end loop;

    close C1;

    SYSTEM_.PRINTLN( RPAD('-',100,'-') );
    SYSTEM_.PRINTLN(RPAD('Total Count',V_LEN15)||'  '||LPAD(TRIM(TO_CHAR(V_CNT_TB_SUM,'999,999,999,999')),V_LEN14));
    SYSTEM_.PRINTLN( V_CNT||' rows selected.' );
end;
/

