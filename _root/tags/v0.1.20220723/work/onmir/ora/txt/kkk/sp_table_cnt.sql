create or replace procedure SYS.SP_TABLE_CNT
(
  A_TABLE_NAME		in VARCHAR
, A_CHK_CNT			in INTEGER DEFAULT 0
)
as
    V_OWNER			VARCHAR(40);
    V_TABLE_NAME	VARCHAR(40);
    V_SQL			VARCHAR(1024);
    V_TBL_M			NUMBER(15);
    V_IDX_M			NUMBER(15);
    V_IDX_N			NUMBER(15);
    V_CNT_TB		NUMBER(15);
    V_CNT_TB_SUM	NUMBER(15);
    V_LEN30			INTEGER;
    V_LEN14			INTEGER;
    V_LEN05			INTEGER;
    V_LEN09			INTEGER;

    cursor C1 is
    select T.OWNER
         , T.TABLE_NAME
      from DBA_TABLES T 
     where 1=1
       and T.TABLE_NAME like UPPER(A_TABLE_NAME)
	   AND T.OWNER LIKE '%ADM'
    ORDER BY T.TABLE_NAME
    ;

begin
    V_LEN30 := 30;
    V_LEN14 := 14;
    V_LEN05 := 5;
    V_LEN09 := 9;

    open C1;

    DBMS_OUTPUT.PUT_LINE( ' | '||RPAD('OWNER',V_LEN14)||' | '||RPAD('TABLE_NAME',V_LEN30)
		||' | '||LPAD('TBL,n',V_LEN14)
		--||' | '||LPAD('Row',V_LEN14)
		||' | '||LPAD('TBL,m',V_LEN09)||' | '||LPAD('IDX,m',V_LEN09)||' | '||LPAD('IDX,n',V_LEN05)
		||' | '
		);
    DBMS_OUTPUT.PUT_LINE( RPAD('-',100,'-') );
/*
    DBMS_OUTPUT.PUT_LINE( 
		  ' | '||RPAD('---',V_LEN14)||' | '||RPAD('---',V_LEN30)||' | '||LPAD('---',V_LEN14)
		||' | '||LPAD('---',V_LEN09)||' | '||LPAD('---',V_LEN09)||' | '||LPAD('---',V_LEN05)
		||' | '
		);
*/

    V_CNT_TB_SUM := 0;
    loop
        fetch C1 into V_OWNER, V_TABLE_NAME
        ;
        exit when C1%NOTFOUND;

		--# TABLE_SIZE (MB)
		--  [TODO] LOB Size Must Add
		SELECT --A.OWNER, SEGMENT_NAME,
			   NVL(ROUND(SUM(BYTES)/1024/1024),-1) TBL_M
		  INTO V_TBL_M
		  FROM DBA_SEGMENTS A
		 WHERE 1=1
		   AND A.OWNER = V_OWNER
		   AND A.SEGMENT_NAME = V_TABLE_NAME
		   AND A.SEGMENT_TYPE LIKE 'TABLE%'
		 --GROUP BY A.OWNER, A.SEGMENT_NAME
		;

		--# COUNT
		--{
		SELECT NVL(
				( 
				SELECT NVL(MAX(NUM_ROWS),0) NUM_ROWS
				  FROM DBA_INDEXES A
				 WHERE 1=1
				   AND TABLE_OWNER = V_OWNER
				   AND TABLE_NAME = V_TABLE_NAME
				 GROUP BY TABLE_OWNER, TABLE_NAME
				), -1) 
		      , NVL(
				( 
				SELECT COUNT(*) IDX_N
				  FROM DBA_INDEXES A
				 WHERE 1=1
				   AND TABLE_OWNER = V_OWNER
				   AND TABLE_NAME = V_TABLE_NAME
				 GROUP BY TABLE_OWNER, TABLE_NAME
				), 0) 
		  INTO V_CNT_TB, V_IDX_N
		  FROM DUAL
		;

        if V_CNT_TB != -1 then
			NULL;
			SELECT --A.OWNER, SEGMENT_NAME,
			       NVL(ROUND(SUM(BYTES)/1024/1024),-1) IDX_M
			     --, COUNT(*) IDX_N
			  INTO V_IDX_M
			  FROM DBA_SEGMENTS A
			 WHERE 1=1
			   AND A.OWNER = V_OWNER
			   AND A.SEGMENT_NAME IN (SELECT B.INDEX_NAME FROM DBA_INDEXES B WHERE B.OWNER = V_OWNER AND B.TABLE_NAME = V_TABLE_NAME)
			   AND A.SEGMENT_TYPE LIKE 'INDEX%'
			;
		else
        	V_CNT_TB := 0;
        	V_IDX_M := 0;
        	V_IDX_N := 0;
        end if;

        --if V_CNT_TB = 0 then
        if V_CNT_TB = 0 AND V_TBL_M > 0 then
			-- [TODO] xx
			-- ex) select COUNT(*) from (SELECT 1 FROM SYSTEM."097-ISDADM-TB_ISD_5011NT.dmp" WHERE ROWNUM < 100)
			V_SQL := 'select COUNT(*) * (-1) from (SELECT 1 FROM '||V_OWNER||'."'||V_TABLE_NAME ||'" WHERE ROWNUM < 100)';
            --DBMS_OUTPUT.PUT_LINE('V_SQL='||V_SQL);
			EXECUTE IMMEDIATE V_SQL into V_CNT_TB;
		end if;
		--}

        --if V_CNT_TB >= A_CHK_CNT then
           V_CNT_TB_SUM := V_CNT_TB_SUM + V_CNT_TB;
           DBMS_OUTPUT.PUT_LINE(
                 ' | '||RPAD(V_OWNER,V_LEN14)
			   ||' | '||RPAD(V_TABLE_NAME,V_LEN30)
			   ||' | '||LPAD(TRIM(TO_CHAR(V_CNT_TB,'999,999,999,999')),V_LEN14) 
			   ||' | '||LPAD(TRIM(TO_CHAR(V_TBL_M,'999,999')),V_LEN09) 
			   ||' | '||LPAD(TRIM(TO_CHAR(V_IDX_M,'999,999')),V_LEN09) 
			   ||' | '||LPAD(TRIM(TO_CHAR(V_IDX_N,'999,999')),V_LEN05) 
		       ||' | '
           );

        --end if;
    end loop;

    close C1;

/*
    DBMS_OUTPUT.PUT_LINE( 
		  ' | '||RPAD('---',V_LEN14)||' | '||RPAD('---',V_LEN30)||' | '||LPAD('---',V_LEN14)
		||' | '||LPAD('---',V_LEN09)||' | '||LPAD('---',V_LEN09)||' | '||LPAD('---',V_LEN05)
		||' | '
		);
*/
    DBMS_OUTPUT.PUT_LINE( RPAD('-',100,'-') );
    --DBMS_OUTPUT.PUT_LINE(RPAD('Total Count',V_LEN30)||'  '||LPAD(TRIM(TO_CHAR(V_CNT_TB_SUM,'999,999,999,999')),V_LEN14));
    --DBMS_OUTPUT.PUT_LINE( V_CNT||' rows selected.' );
end;
/

--GRANT EXECUTE ON SYS.SP_TABLE_CNT TO PUBLIC;
--CREATE OR REPLACE public synonym sp_table_cnt for SYS.sp_table_cnt;

