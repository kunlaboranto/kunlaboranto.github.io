CREATE OR REPLACE PROCEDURE GDR_SP_SAMPLE_MAIN ()
is
	V_SQLCODE				VARCHAR(64);
	V_SQLERRM				VARCHAR(2047);

	V_SAMPLE_ID				VARCHAR(64);
	V_SAMPLE_TIME			DATE;
	V_SAMPLE_INTERVAL		NUMBER(15,6);
	V_PREV_SAMPLE_ID		VARCHAR(64);
	V_PREV_SAMPLE_TIME		DATE;
	V_KEEP_SAMPLE_ID		NUMBER;
	V_KEEP_SAMPLE_NUM		NUMBER;

	V_STM				DATE;
	V_DTM				NUMBER(15,6);	-- MICROSECOND

BEGIN
	V_SQLCODE := 0;
	V_SQLERRM := ' ';
	V_STM := SYSDATE;
	V_DTM := 0;

SYSTEM_.PRINTLN(NULL);
SYSTEM_.PRINTLN(NULL);
SYSTEM_.PRINTLN( RPAD('#',80,'#') );
SYSTEM_.PRINTLN( '# ' || RPAD('APR - Altibase Performance Repository', 77) || '#' );
SYSTEM_.PRINTLN( RPAD('#',80,'#') );
SYSTEM_.PRINTLN(NULL);
SYSTEM_.PRINTLN(NULL);

V_STM := GDR_SF_CHECKTIME( V_STM, V_DTM ); SYSTEM_.PRINTLN('['||TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS.FF6')||'] ['||V_DTM||'] GDR_SP_SAMPLE_MAIN - START !!');

	SELECT SAMPLE_ID, SAMPLE_TIME 
	  INTO V_PREV_SAMPLE_ID, V_PREV_SAMPLE_TIME 
      FROM GDR_HIST_SAMPLESHOT 
     WHERE SAMPLE_ID = ( SELECT MAX(SAMPLE_ID) FROM GDR_HIST_SAMPLESHOT ) ;

	SELECT GDR_SQ_SAMPLE_ID.NEXTVAL, TRUNC(SYSDATE, 'SECOND') INTO V_SAMPLE_ID, V_SAMPLE_TIME FROM DUAL;

	V_SAMPLE_INTERVAL := DATEDIFF( V_PREV_SAMPLE_TIME, V_SAMPLE_TIME, 'MICROSECOND') / 1000000.0;

	INSERT INTO GDR_HIST_SAMPLESHOT ( SAMPLE_ID, SAMPLE_TIME, SAMPLE_INTERVAL ) VALUES ( V_SAMPLE_ID, V_SAMPLE_TIME, V_SAMPLE_INTERVAL  );
V_STM := GDR_SF_CHECKTIME( V_STM, V_DTM ); SYSTEM_.PRINTLN('['||TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS.FF6')||'] ['||V_DTM||'] GDR_SP_SAMPLE_MAIN - (OKT-01) !!');

/*
	TRUNCATE TABLE GDR_TMP_STATEMENT;
	TRUNCATE TABLE GDR_TMP_SESSION	;
	TRUNCATE TABLE GDR_TMP_SYSSTAT	;

	CREATE TABLE GDR_TMP_STATEMENT	TABLESPACE VOL_TS AS SELECT GDR_SQ_SAMPLE_ID.CURRVAL SAMPLE_ID, a.* FROM V$STATEMENT a	WHERE 1=0 ;
	CREATE TABLE GDR_TMP_SESSION	TABLESPACE VOL_TS AS SELECT GDR_SQ_SAMPLE_ID.CURRVAL SAMPLE_ID, a.* FROM V$SESSION a	WHERE 1=0 ;
	CREATE TABLE GDR_TMP_SYSSTAT	TABLESPACE VOL_TS AS SELECT GDR_SQ_SAMPLE_ID.CURRVAL SAMPLE_ID, a.* FROM V$SYSSTAT a	WHERE 1=0 ;
	--CREATE TABLE GDR_TMP_SQLTEXT	TABLESPACE VOL_TS AS SELECT GDR_SQ_SAMPLE_ID.CURRVAL SAMPLE_ID, a.* FROM V$SQLTEXT a	WHERE 1=0 ;
	--CREATE TABLE GDR_TMP_PLANTEXT	TABLESPACE VOL_TS AS SELECT GDR_SQ_SAMPLE_ID.CURRVAL SAMPLE_ID, a.* FROM V$PLANTEXT a	WHERE 1=0 ;

	CREATE UNIQUE INDEX IX_GDR_TMP_STATEMENT_PK ON GDR_TMP_STATEMENT ( SAMPLE_ID, ID ) ;
	CREATE UNIQUE INDEX IX_GDR_TMP_SESSION_PK ON GDR_TMP_SESSION ( SAMPLE_ID, ID ) ;
	CREATE UNIQUE INDEX IX_GDR_TMP_SYSSTAT_PK ON GDR_TMP_SYSSTAT ( SAMPLE_ID, SEQNUM ) ;
*/
	--INSERT INTO GDR_TMP_STATEMENT SELECT V_SAMPLE_ID , a.* FROM V$STATEMENT a WHERE UX2DATE( LAST_QUERY_START_TIME ) > V_PREV_SAMPLE_TIME ;
	INSERT INTO GDR_TMP_STATEMENT SELECT V_SAMPLE_ID , a.* FROM V$STATEMENT a ;
V_STM := GDR_SF_CHECKTIME( V_STM, V_DTM ); SYSTEM_.PRINTLN('['||TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS.FF6')||'] ['||V_DTM||'] GDR_SP_SAMPLE_MAIN - (OKT-02) !!');

	--INSERT INTO GDR_TMP_SESSION SELECT V_SAMPLE_ID , a.* FROM V$SESSION a WHERE 1=1 AND ( 1=0 OR UX2DATE( LOGIN_TIME ) > V_PREV_SAMPLE_TIME OR ID IN ( SELECT SESSION_ID FROM GDR_TMP_STATEMENT WHERE SAMPLE_ID = V_SAMPLE_ID )) ;
	INSERT INTO GDR_TMP_SESSION SELECT V_SAMPLE_ID , a.* FROM V$SESSION a ;
V_STM := GDR_SF_CHECKTIME( V_STM, V_DTM ); SYSTEM_.PRINTLN('['||TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS.FF6')||'] ['||V_DTM||'] GDR_SP_SAMPLE_MAIN - (OKT-03) !!');

	INSERT INTO GDR_TMP_SYSSTAT ( SAMPLE_ID, SEQNUM, NAME, VALUE )
	SELECT V_SAMPLE_ID , a.* FROM V$SYSSTAT a WHERE 1=1 ;
V_STM := GDR_SF_CHECKTIME( V_STM, V_DTM ); SYSTEM_.PRINTLN('['||TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS.FF6')||'] ['||V_DTM||'] GDR_SP_SAMPLE_MAIN - (OKT-04) !!');

	COMMIT;



	-- ########################################
	-- # CALL GDR_SP_SAMPLE_DELTA
	-- 		* UPDATE GDR_TMP_SYSSTAT
	-- ########################################
	GDR_SP_SAMPLE_DELTA( V_SAMPLE_ID );
V_STM := GDR_SF_CHECKTIME( V_STM, V_DTM ); SYSTEM_.PRINTLN('['||TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS.FF6')||'] ['||V_DTM||'] GDR_SP_SAMPLE_MAIN - "GDR_SP_SAMPLE_DELTA" OK !!');


	-- ########################################
	-- # CALL GDR_SP_UPD_SQLAREA
	-- 		* UPDATE GDR_SQLAREA
	-- ########################################
	GDR_SP_UPD_SQLAREA( V_SAMPLE_ID );
V_STM := GDR_SF_CHECKTIME( V_STM, V_DTM ); SYSTEM_.PRINTLN('['||TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS.FF6')||'] ['||V_DTM||'] GDR_SP_SAMPLE_MAIN - "GDR_SP_UPD_SQLAREA" OK !!');




	IF ( 1 = 0 ) AND ( TO_CHAR(V_SAMPLE_TIME, 'HH24:MI') BETWEEN '08:30' AND '18:30' ) THEN
		NULL;
	ELSE
		V_KEEP_SAMPLE_NUM := 1 * 24 * 60;
		V_KEEP_SAMPLE_NUM := 60;
		SELECT MAX(SAMPLE_ID)
		  INTO V_KEEP_SAMPLE_ID
		  FROM GDR_HIST_SAMPLESHOT 
		 WHERE SAMPLE_TIME < TRUNC(SYSDATE) - 8 OR SAMPLE_ID < V_SAMPLE_ID - V_KEEP_SAMPLE_NUM 
		;

		DELETE FROM GDR_TMP_STATEMENT WHERE SAMPLE_ID <= V_KEEP_SAMPLE_ID ;
		DELETE FROM GDR_TMP_SESSION WHERE SAMPLE_ID <= V_KEEP_SAMPLE_ID ;
		DELETE FROM GDR_TMP_SYSSTAT WHERE SAMPLE_ID <= V_KEEP_SAMPLE_ID ;
	END IF;
V_STM := GDR_SF_CHECKTIME( V_STM, V_DTM ); SYSTEM_.PRINTLN('['||TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS.FF6')||'] ['||V_DTM||'] GDR_SP_SAMPLE_MAIN - (OKT-06) !!');


	COMMIT;
V_STM := GDR_SF_CHECKTIME( V_STM, V_DTM ); SYSTEM_.PRINTLN('['||TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS.FF6')||'] ['||V_DTM||'] GDR_SP_SAMPLE_MAIN - END !!');

EXCEPTION
    WHEN OTHERS THEN
		V_SQLCODE := SQLCODE ;
		V_SQLERRM := SQLERRM ;
		IF V_SQLCODE > 990000 THEN
			V_SQLCODE := V_SQLCODE - 990000 ;
		END IF;

		SYSTEM_.PRINTLN('['||TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS.FF6')||'] [ERROR] V_SAMPLE_ID = '||V_SAMPLE_ID );
		SYSTEM_.PRINTLN('['||TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS.FF6')||'] ERR-'||V_SQLCODE||' '||V_SQLERRM );
		ROLLBACK;
		RAISE_APPLICATION_ERROR( 990000 + MOD(V_SQLCODE,1000) , V_SQLERRM );	-- ALTIBASE ( 990000 ~ 991000 )
END;
/
