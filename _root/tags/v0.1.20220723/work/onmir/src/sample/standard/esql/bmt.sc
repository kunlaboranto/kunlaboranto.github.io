#include "common.h"

EXEC SQL INCLUDE SQLCA;

EXEC SQL BEGIN DECLARE SECTION;
#define __GPEC__
EXEC SQL END   DECLARE SECTION;


#ifdef SQL_NO_DATA
#	define _SQL_NO_DATA		SQL_NO_DATA
#else
#	define _SQL_NO_DATA		(1403)
#endif

#define ARRAY_SIZE      	1000

EXEC SQL BEGIN DECLARE SECTION;
    int	 loopCnt	;

    struct node {
        int		c1;
        char	c2[10+1];
        int		c3;
        char	c4[10+1];
        char	c5[10+1];
        char	c6[10+1];
        char	c7[10+1];
        char	c8[10+1];
        int		c9;
    } rec;

    struct a_node {
        int		c1;
        char	c2[10+1];
        int		c3;
        char	c4[10+1];
        char	c5[10+1];
        char	c6[10+1];
        char	c7[10+1];
        char	c8[10+1];
        int		c9;
    } a_rec[ARRAY_SIZE];

    struct rnode {
        int		c1;
        char	c2[10+1];
        int		c3;
        char	c4[10+1];
        char	c5[10+1];
        char	c6[10+1];
        char	c7[10+1];
        char	c8[10+1];
        int		c9;
        char	c10[26+1];
    } s_rec;

#ifdef __GPEC__
    char	dst_node[30+1] = "GOLDILOCKS";
#else
    char	dst_node[30+1] = "OTHER";
#endif
    int		a_up[ARRAY_SIZE];
    int		a_del[ARRAY_SIZE];
    int     xx;
EXEC SQL END DECLARE SECTION;

int  startNum;
int  endNum;
char work;
int  random_tag;
int  commit_cnt;

static void dbConn() ;
static void dbDisconn() ;
static void insertDB() ;
static void updateDB() ;
static void deleteDB() ;
static void selectDB() ;
static void arrayInsertDB() ;
static void arrayUpdateDB() ;
static void arrayDeleteDB() ;

static void Usage(int argc, char **argv)
{
    printf("============================================\n");
    printf("Standard BMT Program \n");
    printf("============================================\n");
    printf("usage: ./%s [work] [startNum] [endNum] [random_tag] [commit_cnt]\n", argv[0] );
    printf(" \t[work] i : insert\n");
    printf(" \t       u : update\n");
    printf(" \t       s : select\n");
    printf(" \t       d : delete\n");
    printf(" \t       a : array insert\n");
    printf(" \t       b : array update\n");
    printf(" \t       c : array delete\n");
    printf(" \t[loop] startNum ~ endNum\n");
    printf(" \t[random_tag] 1] random  , others] sequencial\n");

    exit(-1);
}

static void parseEnv(char **env)
{
    work     = (char)toupper(env[1][0]);
    startNum = (int)atoi(env[2]);
    endNum   = (int)atoi(env[3]);
    random_tag = (int)atoi(env[4]);
    commit_cnt = (int)atoi(env[5]);
}

static void Error(char *where)
{
    if (sqlca.sqlcode == _SQL_NO_DATA && work == 'S')
        return ;

    if (sqlca.sqlcode != 0) {
        if (work == 'I' || work == 'A') {
            _log("NOW LoopCount is  [%d], JOB ended at [%d] \n", loopCnt, (loopCnt-1));
        }

        _log("SQLERR [%s] : %d %s\n", where, sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc);
        exit(-1);
    }
}

/*
 * MAIN
 */
int main(int argc, char **argv)
{
    if (argc < 6) Usage( argc, argv );
    parseEnv(argv);
    dbConn();

    switch (work) {
        case 'I':
            insertDB();
            break;
        case 'U':
            updateDB();
            break;
        case 'D':
            deleteDB();
            break;
        case 'S':
            selectDB();
            break;
        case 'A':
            arrayInsertDB();
            break;
        case 'B':
            arrayUpdateDB();
            break;
        case 'C':
            arrayDeleteDB();
            break;
        default :
            _log("Unsupported Operation\n");
    }

    dbDisconn();

    exit(0);
}

void dbConn()
{
    EXEC SQL BEGIN DECLARE SECTION;
    char usr	[30];
    char pass	[30];
    char opt	[100];
    EXEC SQL END DECLARE SECTION;

    strcpy(usr ,	"test");
    strcpy(pass,    "test");
    //sprintf(opt,  "DSN=GOLDILOCKS");
    //sprintf(opt,  "ORCL");
    //sprintf(opt,  "DSN=127.0.0.1;PORT_NO=60000;CONNTYPE=1");

#ifdef __GPEC__
    if ( getenv("_DST_NODE") != NULL ) {
        strcpy( dst_node, getenv("_DST_NODE") );
    }

    sprintf(opt, "DSN=%s", dst_node );
    EXEC SQL CONNECT :usr IDENTIFIED BY :pass USING :opt;
#else
    EXEC SQL CONNECT :usr IDENTIFIED BY :pass ;
#endif
    Error("CONNECT");

    //EXEC SQL ALTER SESSION SET AUTOCOMMIT = FALSE;
    //Error("COMMIT_MODE_CHANGE");
}

void dbDisconn()
{
    //EXEC SQL DISCONNECT;
    EXEC SQL ROLLBACK WORK RELEASE;
    Error("DISCONNECT");

    _log("\n[SUCCESS] Disconnect Finished\n");
    _log("============================\n\n");
}

void insertDB()
{
    double totalTime = 0.0;
    struct timeval startTime;
    struct timeval endTime;

    _log("============================\n");
    _log("[INSERT] start [%d ~ %d] \n", startNum, endNum);

    gettimeofday(&startTime, (void *)NULL);

    memset(&rec, 0x00, sizeof(rec));

    sprintf(rec.c2, "%010d", loopCnt);
    sprintf(rec.c4, "%010d", loopCnt);
    sprintf(rec.c5, "%010d", loopCnt);
    sprintf(rec.c6, "%010d", loopCnt);
    sprintf(rec.c7, "%010d", loopCnt);
    sprintf(rec.c8, "%010d", loopCnt);

    for (loopCnt = startNum ; loopCnt <= endNum ; loopCnt++) {
        rec.c1 = loopCnt;
        rec.c3 = 0;
        rec.c9 = 0;

#ifndef __GPEC__
        EXEC SQL INSERT INTO TB_TEST1 ( C1, C2, C3, C4, C5, C6, C7, C8, C9, C10 )
                 VALUES ( :rec, systimestamp );
#else
        EXEC SQL INSERT INTO TB_TEST1 ( node, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10 )
                 VALUES ( :dst_node, :rec, systimestamp );
#endif
        Error("INSERT");

        if ( loopCnt !=0 && ((loopCnt % commit_cnt) == 0) )
            EXEC SQL COMMIT;
        
        CHECKTIME() ;
    }

    EXEC SQL COMMIT;
    showTotal( endNum-startNum+1, totalTime );
}

void updateDB()
{
    double totalTime = 0.0;
    struct timeval startTime;
    struct timeval endTime;

    _log("============================\n");
    _log("[UPDATE] start [%d ~ %d] \n", startNum, endNum);

    gettimeofday(&startTime, (void *)NULL);

    srand48(getpid());
    for (loopCnt = startNum ; loopCnt <= endNum ; loopCnt++) {
        xx = loopCnt;
#ifndef __GPEC__
        EXEC SQL UPDATE TB_TEST1
                    SET	C3 = C3 + 1
                      , C9 = C9 + 1
                      , C10 = SYSTIMESTAMP
                  WHERE	C1 = :xx
                  ;
#else
        EXEC SQL UPDATE TB_TEST1
                    SET	C3 = C3 + 1
                      , C9 = C9 + 1
                      , C10 = SYSTIMESTAMP
                  WHERE	C1 = :xx
                    AND NODE = :dst_node
                  ;
#endif
        if (sqlca.sqlcode != 0) {
           printf("ERR-%d, %s (%d,%s)\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc, xx, dst_node);
           break;
        }

        if ( loopCnt !=0 && ((loopCnt % commit_cnt) == 0) )
            EXEC SQL COMMIT;

        CHECKTIME() ;
    }

    EXEC SQL COMMIT;
    showTotal( endNum-startNum+1, totalTime );
}

void deleteDB()
{
    double totalTime = 0.0;
    struct timeval startTime;
    struct timeval endTime;

    _log("============================\n");
    _log("[DELETE] start [%d ~ %d] \n", startNum, endNum);

    gettimeofday(&startTime, (void *)NULL);

    for (loopCnt = startNum ; loopCnt <= endNum ; loopCnt++) {
        EXEC SQL DELETE FROM TB_TEST1 WHERE   C1 = :loopCnt;
        Error("DELETE");

        if ( loopCnt !=0 && ((loopCnt % commit_cnt) == 0) )
            EXEC SQL COMMIT;

        CHECKTIME() ;
    }

    EXEC SQL COMMIT;
    showTotal( endNum-startNum+1, totalTime );
}

void selectDB()
{
    double totalTime = 0.0;
    struct timeval startTime;
    struct timeval endTime;

    _log("============================\n");
    _log("[SELECT] start [%d ~ %d] \n", startNum, endNum);

    gettimeofday(&startTime, (void *)NULL);

    srand48(getpid());
    for (loopCnt = startNum ; loopCnt <= endNum ; loopCnt++) {
        memset(&s_rec,	0x00,	sizeof(s_rec));
        if (random_tag == 1)
            xx = getRandomInt(startNum, endNum);
        else
            xx = loopCnt;

#ifndef __GPEC__
        EXEC SQL SELECT C1, C2, C3, C4, C5, C6, C7, C8, C9, to_char(C10, 'YYYYMMDD HH:MI:SS')
                   INTO :s_rec 
                   FROM TB_TEST1 
                  WHERE	C1 = :xx 
                    --AND ROWNUM = 1
                  ;
#else
    if (0x01)
    {
        EXEC SQL SELECT C1, C2, C3, C4, C5, C6, C7, C8, C9, to_char(C10, 'YYYYMMDD HH:MI:SS')
                   INTO :s_rec 
                   FROM TB_TEST1 
                  WHERE	C1 = :xx 
                    AND NODE = :dst_node
                    --AND ROWNUM = 1
                  ;
    }
    else
    {
        // [G1N2] TPS(Transaction per Second) ==>  20018.3 TPS 
        // [G1N1] TPS(Transaction per Second) ==>  16568.6 TPS 
        EXEC SQL SELECT 1 INTO :xx FROM DUAL ;
    }
#endif
        //if (sqlca.sqlcode != 0)
        if (sqlca.sqlcode != 0 && sqlca.sqlcode != 100)
        {
           printf("ERR-%d, %s (%d,%s)\n", sqlca.sqlcode, sqlca.sqlerrm.sqlerrmc, xx, dst_node);
           break;
        }
        //Error("SELECT");

        CHECKTIME() ;
    }

    showTotal( endNum-startNum+1, totalTime );
}

void arrayInsertDB()
{
    int		i=0;
    double 	totalTime = 0.0;
    struct 	timeval startTime;
    struct 	timeval endTime;

    _log("============================\n");
    _log("[ARRAY-INSERT] start [%d ~ %d] \n", startNum, endNum);

    gettimeofday(&startTime, (void *)NULL);

    for (loopCnt = startNum ; loopCnt <= endNum ; loopCnt++) {
        memset(&a_rec, 0x00, sizeof(a_rec));
        a_rec[i].c1 = loopCnt;
        a_rec[i].c3 = loopCnt;
        a_rec[i].c9 = loopCnt;

        sprintf(a_rec[i].c2, "%010d", loopCnt);
        sprintf(a_rec[i].c4, "%010d", loopCnt);
        sprintf(a_rec[i].c5, "%010d", loopCnt);
        sprintf(a_rec[i].c6, "%010d", loopCnt);
        sprintf(a_rec[i].c7, "%010d", loopCnt);
        sprintf(a_rec[i].c8, "%010d", loopCnt);

        i++;
        if((i % ARRAY_SIZE) == 0) {
            EXEC SQL INSERT INTO TB_TEST1 (C1, C2, C3, C4, C5, C6, C7, C8, C9)
                            VALUES ( :a_rec );
            Error("ARRAY INSERT");

            EXEC SQL COMMIT;
            i = 0;
        }
        
        CHECKTIME() ;
    }

    EXEC SQL COMMIT;
    showTotal( endNum-startNum+1, totalTime );
}

void arrayUpdateDB()
{
    int		i=0;
    double 	totalTime = 0.0;
    struct 	timeval startTime;
    struct 	timeval endTime;

    _log("============================\n");
    _log("[ARRAY-UPDATE] start [%d ~ %d] \n", startNum, endNum);

    gettimeofday(&startTime, (void *)NULL);

    for (loopCnt = startNum ; loopCnt <= endNum ; loopCnt++) {
        a_up[i] = loopCnt;
        i++;
        if((i % ARRAY_SIZE) == 0) {
            EXEC SQL
                    UPDATE TB_TEST1
                        SET	C3 = C3 + 1,
                            C9 = C9 + 1
                    WHERE	C1 = :a_up;
            if (sqlca.sqlcode != 0) {
                printf("%s\n", sqlca.sqlerrm.sqlerrmc);
                break;
            }
            EXEC SQL COMMIT;
            i = 0;
        }

        CHECKTIME() ;
    }

    EXEC SQL COMMIT;
    showTotal( endNum-startNum+1, totalTime );
}

void arrayDeleteDB()
{
    int		i=0;
    double 	totalTime = 0.0;
    struct 	timeval startTime;
    struct 	timeval endTime;

    _log("============================\n");
    _log("[ARRAY-DELETE] start [%d ~ %d] \n", startNum, endNum);

    gettimeofday(&startTime, (void *)NULL);

    for (loopCnt = startNum ; loopCnt <= endNum ; loopCnt++) {
        a_del[i] = loopCnt;
        i++;
        if((i % ARRAY_SIZE) == 0) {
            EXEC SQL DELETE FROM TB_TEST1 WHERE C1 = :a_del;
            if (sqlca.sqlcode != 0) {
                printf("%s\n", sqlca.sqlerrm.sqlerrmc);
                break;
            }
            EXEC SQL COMMIT;
            i = 0;
        }

        CHECKTIME() ;
    }

    EXEC SQL COMMIT;
    showTotal( endNum-startNum+1, totalTime );
}
