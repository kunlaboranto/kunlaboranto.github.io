/*@****************************************************************************/
/* 1. 프로그램 ID: GDMON_delta.sc ()                                        */
/* 2. 유       형: Monitoring                                                 */
/*--------------------------------------------------------------------------- */
/* Version  작성자   소  속      일  자      내  용                    요청자 */
/*--------  -------  ----------  ----------  ------------------------  ------ */
/* 1.0      임세환   ALTIBASE    2008.04.28  신규(최초작성)                   */
/*@****************************************************************************/

#include <stdarg.h>
#include <stdio.h>
#include <pthread.h>
#include <string.h>
#include <sqlcli.h>
#include <stdlib.h>
#include <stdarg.h>
#include <time.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/stat.h>

#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define QUERY_LEN   4096
#define BIG_SIZE    32000
#define ALLOC_SIZE  128000

static int  dbConnect();
static int  saveDB(char *logType, char *tagName, char *value);
static void dbErrMsg();
static void dbErrMsg3();
static void dbFree();
static void getData(int index);
static void getQuery(char *tagName, int index);
static void getSimpleParam(const char *mainTag, const char *paramName, char paramValue[], int trim_tag = 1);
static void getSubTag(char *realTag, char *subtagName, char *TMP_VALUE);
static void _log(const char *format, ...);
static void Ltrim(char s[]);
static void makeQuerySet();
static void runCommand(char *s, char *t);

/***************************************
 ODBC연결을 위해 설정.
 ***************************************/
SQLHDBC dbc = SQL_NULL_HDBC;
SQLHDBC repdbc = SQL_NULL_HDBC;
SQLHENV env = SQL_NULL_HENV;
SQLHENV repenv = SQL_NULL_HENV;
SQLHSTMT stmt = SQL_NULL_HSTMT;
SQLHSTMT stmt2 = SQL_NULL_HSTMT;

/***************************************
 전역변수용으로 설정.
 ***************************************/
char configFile[1024];
char LOG_FILE[255];
char SLEEP_TIME[255];
char UNAME[255];
char DB_SAVE[10];
int  OLD_DAY = 0;
int  OLD_MON = 0;

char gUNAME[255];
int  BATCH_EXEC = 0;
int  g_interval = 0;

/***************************************
 XML타입으로 만든 conf를 읽어들이기 위해.
 ***************************************/
typedef struct
{
	char tagName[255];				// tagName
	char query[QUERY_LEN];			// query
	char interval[255];				// interval
	char display[1];				// 쓸지말지
	char enable[10];				// eanble , disable
	double old_value;
	int inc_count;
} QUERYSET;

QUERYSET xquery[100];
int  QUERYSET_COUNT = 0;

/***************************************
 결과를 로깅하는 부분.
 ***************************************/
void _log(const char *format, ...)
{
	FILE *fp;
	va_list ap;
	struct tm t;
	time_t now;
	char comm[1024];

	/***************************************
	 날마다 logChange를 하기 위해서
	 ***************************************/
	time(&now);
	t = *localtime(&now);

	if (OLD_DAY != 0)
	{
		if (OLD_DAY != t.tm_mday)
		{
			sprintf(comm, "cp %s %s_%02d%02d 2>/dev/null", LOG_FILE, LOG_FILE, OLD_MON, OLD_DAY);
			system(comm);
			fp = fopen(LOG_FILE, "w+");
			fclose(fp);

			/******************************************
			 ** 날자가 변경되면 배치를 하나 돌려야 한다.
			 ** DB저장모드만 해당된다.
			 ******************************************/
			if (memcmp(DB_SAVE, "ON", 2) == 0)
			{
				BATCH_EXEC = 1;
			}
		}
	}

	/***************************************
	 실제 파일에 로그를 남긴다.
	 ***************************************/
	fp = fopen(LOG_FILE, "a+");
	if (fp == NULL)
	{
		fprintf(stdout, "_LOG fopen error . [%s]\n", LOG_FILE);
		exit(-1);
	}

	/***************************************
	 사용자가 지정한 날자포맷에 따라서.
	 ***************************************/
	fprintf(fp, "[%04d/%02d/%02d %02d:%02d:%02d] ", t.tm_year + 1900, t.tm_mon + 1, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec);

	va_start(ap, format);
	vfprintf(fp, format, ap);
	va_end(ap);

	fflush(fp);
	fclose(fp);

	OLD_MON = t.tm_mon + 1;
	OLD_DAY = t.tm_mday;
} // void _log(const char *format, ...)

/***************************************
 OS command를 할 필요가 있을때 쓰라.
 결과를 2번 인자에 담아줄테다..
 ***************************************/
void runCommand(char *s, char *t)
{
	FILE *fp;
	char *ret;
	char tmp[1024];

	ret = (char*) malloc(sizeof(char) * ALLOC_SIZE);
	if (!ret)
	{
		_log("malloc Error\n");
		exit(-1);
	}

	fp = popen(s, "r");
	if (fp == NULL)
	{
		_log("22 system call ERROR [%s]!!\n", s);
		exit(-1);
	}

	memset(ret, 0x00, ALLOC_SIZE);
	memset(tmp, 0x00, sizeof(tmp));

	while (!feof(fp))
	{
		if (fgets(tmp, sizeof(tmp), fp) == NULL)
			break;
		strcat(ret, tmp);
	}
	pclose(fp);

	ret[(int) strlen(ret) - 1] = 0x00;
	memcpy(t, ret, (int) strlen(ret));

	free(ret);

} //void runCommand(char *s, char *t)

/***************************************
 DB 연결하기.
 ***************************************/
int  dbConnect()
{
	char connStr[1024];
	char dbIP[20];
	char portNo[20];
	char connType[2];
	char passWd[100];
	char nlsUse[100];
	char user[100];

	if (SQLAllocEnv(&env) != SQL_SUCCESS)
	{
		_log("dbConnect.SQLAllocEnv error!!\n");
		return -1;
	}

	if (SQLAllocConnect(env, &dbc) != SQL_SUCCESS)
	{
		_log("dbConnect.SQLAllocConnect error!!\n");
		return -1;
	}

	/*********************************************
	 configFile에서 DB_IP, PORT_NO, SYS_PASSWD, NLS_USE등을 읽어온다.
	 *********************************************/
	getSimpleParam("CONNECTION_INFO", "DB_IP", dbIP);
	getSimpleParam("CONNECTION_INFO", "PORT_NO", portNo);
	getSimpleParam("CONNECTION_INFO", "USER", user);
	getSimpleParam("CONNECTION_INFO", "PASSWD", passWd);
	getSimpleParam("CONNECTION_INFO", "NLS_USE", nlsUse);
	getSimpleParam("CONNECTION_INFO", "CONNTYPE", connType);

	/********************************************
	 연결하기
	 ********************************************/
	sprintf(connStr, "DSN=%s;PORT_NO=%s;UID=%s;PWD=%s;CONNTYPE=%s;NLS_USE=%s", dbIP, portNo, user, passWd, connType, nlsUse); 
	if (SQLDriverConnect(dbc, NULL, (SQLCHAR *) connStr, SQL_NTS, NULL, 0, NULL, SQL_DRIVER_NOPROMPT) != SQL_SUCCESS)
	{
		dbErrMsg();
		return -1;
	}

    if (SQLSetConnectAttr(dbc, SQL_ATTR_AUTOCOMMIT,
                          (void*)SQL_AUTOCOMMIT_ON, 0) != SQL_SUCCESS)
    {
		dbErrMsg();
		return -1;
    }

	if (SQLAllocStmt(dbc, &stmt) != SQL_SUCCESS)
	{
		_log("dbConnect.SQLAllocStmt Error\n");
		return -1;
	}

	/*********************************************
	 ** 저장소 정보 얻어내기
	 **********************************************/
	if (memcmp(DB_SAVE, "ON", 2) == 0)
	{
		if (SQLAllocEnv(&repenv) != SQL_SUCCESS)
		{
			_log("rep_dbConnect.SQLAllocEnv error!!\n");
			return -1;
		}

		if (SQLAllocConnect(repenv, &repdbc) != SQL_SUCCESS)
		{
			_log("rep_dbConnect.SQLAllocConnect error!!\n");
			return -1;
		}

		getSimpleParam("REPOSITORY_INFO", "DB_IP", dbIP);
		getSimpleParam("REPOSITORY_INFO", "PORT_NO", portNo);
		getSimpleParam("REPOSITORY_INFO", "USER", user);
		getSimpleParam("REPOSITORY_INFO", "PASSWD", passWd);
		getSimpleParam("REPOSITORY_INFO", "NLS_USE", nlsUse);
		getSimpleParam("REPOSITORY_INFO", "CONNTYPE", connType);

		sprintf(connStr, "DSN=%s;PORT_NO=%s;UID=%s;PWD=%s;CONNTYPE=1;NLS_USE=%s", dbIP, portNo, user, passWd, nlsUse);
		if (SQLDriverConnect(repdbc, NULL, (SQLCHAR *) connStr, SQL_NTS, NULL, 0, NULL, SQL_DRIVER_NOPROMPT) != SQL_SUCCESS)
		{
			dbErrMsg();
			return -1;
		}

		if (SQLAllocStmt(repdbc, &stmt2) != SQL_SUCCESS)
		{
			_log("rep_dbConnect.SQLAllocStmt2 Error\n");
			return -1;
		}
	}

	return 0;
} //int  dbConnect()

/***************************************
 DB 연결 해제하기
 ***************************************/
void dbFree()
{
	if (stmt != NULL)
		SQLFreeStmt(stmt, SQL_DROP);

	if (stmt2 != NULL)
		SQLFreeStmt(stmt2, SQL_DROP);

	SQLDisconnect(dbc);
	SQLDisconnect(repdbc);

	if (dbc != NULL)
	{
		SQLFreeConnect(dbc);
	}
	if (repdbc != NULL)
	{
		SQLFreeConnect(repdbc);
	}
	if (env != NULL)
	{
		SQLFreeEnv(env);
	}
	if (repenv != NULL)
	{
		SQLFreeEnv(repenv);
	}

	stmt = NULL;
	stmt2 = NULL;
	dbc = NULL;
	env = NULL;
	repdbc = NULL;
	repenv = NULL;
} //void dbFree()

/***************************************
 DB Error발생시 에러 메시지를 남긴다.
 ***************************************/
void dbErrMsg3()
{
	SQLINTEGER errNo;
	SQLSMALLINT msgLength;
	SQLCHAR errMsg[1024];

	if (SQLError(repenv, repdbc, stmt2, NULL, &errNo, errMsg, 1024, &msgLength) == SQL_SUCCESS)
	{
		_log("DB_STMT2_Error:# %ld, %s\n", errNo, errMsg);
	}

	SQLFreeStmt(stmt2, SQL_DROP);
	SQLAllocStmt(repdbc, &stmt2);
} // void dbErrMsg3()

/***************************************
 DB Error발생시 에러 메시지를 남긴다.
 ***************************************/
void dbErrMsg()
{
	SQLINTEGER errNo;
	SQLSMALLINT msgLength;
	SQLCHAR errMsg[1024];

	if (SQLError(env, dbc, stmt, NULL, &errNo, errMsg, 1024, &msgLength) == SQL_SUCCESS)
	{
		_log("DB_STMT1_Error:# %ld, %s\n", errNo, errMsg);
	}

	SQLFreeStmt(stmt, SQL_DROP);
	SQLAllocStmt(dbc, &stmt);
} // void dbErrMsg()




/****************************************
 앞뒤 공백 제거 시키기.
 ****************************************/
void Ltrim(char s[])
{
	char tmp[1024];
	int  i, j;
	int  len = strlen(s);

	/*************************************
	 첫번째 문자가 나오는 위치
	 **************************************/
	for (i = 0; i < len; i++)
	{
		if (s[i] != 32 && s[i] != 9 && s[i] != 10)
			break;
	}

	/*************************************
	 문자열 이후에 첫번째 공백이 나오는 위치
	 **************************************/
#if 0
	for (j = i; j < len; j++)
	{
		if (s[j] == 32 || s[j] == 9 || s[j] == 10)
			break;
	}
#else
	for (j = len-1; j >= 0; j--)
	{
		if (s[j] != 32 && s[j] != 9 && s[j] != 10)
			break;
	}
	j++;
#endif

	/*************************************
	 j ~ i 사이꺼만 복사를 한다.
	 **************************************/
	memset(tmp, 0x00, sizeof(tmp));
	memcpy(tmp, s + i, j - i);
	memset(s, 0x00, len);
	memcpy(s, tmp, (int) strlen(tmp));
} // void Ltrim(char s[])




/***************************************
 필요한 옵션의 항목, 값을 알아낸다.
 ***************************************/
void getSimpleParam( const char *mainTag, const char *paramName, char paramValue[], int trim_tag )
{
	char TMP_VALUE[255];
	char name123[255];
	char name321[255];
	char buff[BIG_SIZE];
	char subuff[BIG_SIZE];
	FILE *fp;
	int len;
	int i;
	int start = -1, end = -1;

	/***************************************
	 configFile을 읽는다.
	 ***************************************/
	memset(buff, 0x00, sizeof(buff));
	memset(subuff, 0x00, sizeof(subuff));

	fp = fopen(configFile, "r");
	if (fp == NULL)
	{
		printf("%s file not found !!\n", configFile);
		exit(-1);
	}
	fread(buff, sizeof(buff) - 1, 1, fp);
	fclose(fp);

	sprintf(name123, "<%s>", mainTag);
	sprintf(name321, "</%s>", mainTag);

	/***************************************
	 mainTag의 그룹문자열을 찾아낸다.
	 ***************************************/
	start = -1;
	end = -1;
	len = strlen(buff);
	for (i = 0; i < len; i++)
	{
		if (memcmp(buff + i, name123, (int) strlen(name123)) == 0)
			start = i + (int) strlen(name123);

		if (memcmp(buff + i, name321, (int) strlen(name321)) == 0)
			end = i - 1;
	}
	memcpy(subuff, buff + start, (end - start) + 1);

	if (start == -1 || end == -1)
	{
		printf((char*) "Not Found [%s]\n", mainTag);
		exit(-1);
	}

	/***************************************
	 ParamNameTag의 그룹문자열을 찾아낸다.
	 ***************************************/
	sprintf(name123, "<%s>", paramName);
	sprintf(name321, "</%s>", paramName);
	len = strlen(subuff);
	start = -1;
	end = -1;

	for (i = 0; i < len; i++)
	{
		if (memcmp(subuff + i, name123, (int) strlen(name123)) == 0)
			start = i + (int) strlen(name123);

		if (memcmp(subuff + i, name321, (int) strlen(name321)) == 0)
			end = i - 1;
	}

	if (start == -1 || end == -1)
		return;
	if ((end - start) <= 0)
		return;

	memcpy(TMP_VALUE, subuff + start, (end - start) + 1);
	TMP_VALUE[ (end - start) + 1 ] = 0;

	/********************************
	 space 제거 여부
	 ********************************/
	if (trim_tag)
		Ltrim(TMP_VALUE);

	memcpy(paramValue, TMP_VALUE, strlen(TMP_VALUE) + 1);
} //void getSimpleParam( const char *mainTag, const char *paramName, char paramValue[], int trim_tag )




/***************************************
 XML형태를 파싱할때 부분부분을 알아낸다.
 ***************************************/
void getSubTag(char *realTag, char *subtagName, char *TMP_VALUE)
{
	char name123[255];
	char name321[255];
	int i, k;
	int start = -1, end = -1;

	sprintf(name123, "<%s>", subtagName);
	sprintf(name321, "</%s>", subtagName);

	/*****************************************************
	 일단, 전체를 뒤져서 tagName을 찾아내면
	 그 tag의 시작, 끝부분의 위치를 알아내서
	 그 부분만큼만 value에 담아 리턴한다.
	 *****************************************************/
	k = (int) strlen(realTag);
	start = -1;
	for (i = 0; i < k; i++)
	{
		if (memcmp(realTag + i, name123, (int) strlen(name123)) == 0)
		{
			start = i + (int) strlen(subtagName) + 2;
		}
		if (memcmp(realTag + i, name321, (int) strlen(name321)) == 0)
		{
			end = i - 1;
		}
	}

	/* tag가 없으면 그냥 리턴한다. */
	if (start == -1 || end == -1)
	{
		TMP_VALUE[0] = 0x00;
		return;
	}
	else if ((end - start) >= QUERY_LEN)
	{
		_log("[ERROR] MAX_QUERY_LEN Limited (%d)  !!\n", QUERY_LEN);
		exit(-1);
		//return;
	}

	memcpy(TMP_VALUE, realTag + start, end - start + 1);
	TMP_VALUE[end - start + 1] = 0;

	Ltrim(TMP_VALUE);	// by OKT
} // void getSubTag(char *realTag, char *subtagName, char *TMP_VALUE)


/***************************************
 모니터링을 할 쿼리에 대해 쫘악 파싱한다.
 ***************************************/
void getQuery(char *tagName, int index)
{
	char name123[255];
	char name321[255];
	char buff[BIG_SIZE];
	char realTag[BIG_SIZE];
	char display[255];
	char enable[30];
	char query[QUERY_LEN];
	char interval[255];
	FILE *fp;
	int i, k;
	int start = -1, end = -1;

	/*****************************************************
	 일단, 파일을 통째로 읽어버린다.
	 *****************************************************/
	fp = fopen(configFile, "r");
	if (fp == NULL)
	{
		printf("%s file not found !!\n", configFile);
		exit(-1);
	}

	memset(buff, 0x00, sizeof(buff));
	fread(buff, sizeof(buff) - 1, 1, fp);
	fclose(fp);

	sprintf(name123, "<%s>", tagName);
	sprintf(name321, "</%s>", tagName);

	/*****************************************************
	 Input으로 받은 tagName에 대한 start, end위치를 알아낸다.
	 *****************************************************/
	k = (int) strlen(buff);
	start = -1;
	end = -1;
	for (i = 0; i < k; i++)
	{
		if (memcmp(buff + i, name123, (int) strlen(name123)) == 0)
		{
			start = i + (int) strlen(tagName) + 2;
		}
		if (memcmp(buff + i, name321, (int) strlen(name321)) == 0)
		{
			end = i - 1;
		}
	}

	/*****************************************************
	 validation check
	 *****************************************************/
	if (end == -1 && start == -1)
	{
		_log("NotFound !!\n");
		exit(-1);
	}

	/*****************************************************
	 실제 태그의 값부분을 별도 변수에 Copy한다.
	 *****************************************************/
	memset(realTag, 0x00, sizeof(realTag));
	memcpy(realTag, buff + start, end - start);

	/*****************************************************
	 이제 필요한 항목들을 읽어온다.
	 *****************************************************/
	getSubTag(realTag, (char*) "QUERY", query);
	getSubTag(realTag, (char*) "INTERVAL", interval);
	if (interval[0] == 0x00)
	{
		interval[0] = '1';
		interval[1] = 0x00;
	}
	getSubTag(realTag, (char*) "DISPLAY", display);
	if (display[0] == 0x00)
	{
		display[0] = '0';
		display[1] = 0x00;
	}
	getSubTag(realTag, (char*) "ENABLE", enable);
	if (enable[0] == 0x00)
	{
		enable[0] = 'O';
		enable[1] = 'N';
		enable[2] = 0x00;
	}

	/*****************************************************
	 구조체에 저장해 둔다.
	 *****************************************************/
	memcpy(xquery[index].tagName, tagName, strlen(tagName));
	memcpy(xquery[index].query, query, strlen(query));
	memcpy(xquery[index].interval, interval, strlen(interval));
	memcpy(xquery[index].enable, enable, strlen(enable));

	xquery[index].inc_count = 0;
	xquery[index].old_value = 0;
	xquery[index].display[0] = display[0];
} // void getQuery(char *tagName, int index)




/***************************************
 실제 쿼리를 날려서 읽어온다.
 ***************************************/
void getData(int index)
{
	SQLSMALLINT columnCount = 0, nullable, dataType, scale, columnNameLength;
	SQLINTEGER *columnInd;
	SQLUINTEGER columnSize;
	SQLCHAR columnName[255];
	char **columnPtr;
	int rc;
	int i, rcount;
	char dData[8192];

	if ( xquery[index].interval[0] == 0x00
			|| g_interval % atoi(xquery[index].interval) != 0 )
	{
		return;
	}

	/***************************************
	 SQL 수행
	 ***************************************/
	if (SQLExecDirect(stmt, (SQLCHAR*) xquery[index].query, SQL_NTS) != SQL_SUCCESS)
	{
		dbErrMsg();
		return;
	}

	// if INSERT / UPDATE
	if (xquery[index].display[0] != '1')
		return;

	/***************************************
	 컬럼 갯수를 얻어온다.
	 ***************************************/
	SQLNumResultCols(stmt, &columnCount);

	/***************************************
	 이제 바인딩을 해야 함으로 필요한 메모리를 할당한다.
	 컬럼수만큼.
	 ***************************************/
	columnPtr = (char**) malloc(sizeof(char*) * columnCount);
	columnInd = (SQLINTEGER*) malloc(sizeof(SQLINTEGER) * columnCount);
	if (columnPtr == NULL)
	{
		_log("getData.malloc Error\n");
		free(columnInd);
		return;
	}

	/***************************************
	 바인딩한다.
	 ***************************************/
	for (i = 0; i < columnCount; i++)
	{
		memset(columnName, 0x00, sizeof(columnName));
		SQLDescribeCol(stmt, i + 1, columnName, sizeof(columnName),
				&columnNameLength, &dataType, &columnSize, &scale, &nullable);

		/******************************************
		 숫자형인경우 자릿수가 너무 작을수 있어
		 15자리이하면 그냥 255자리로 할당한다.
		 ******************************************/
		if (columnSize <= 15)
			columnSize = 255;

		columnPtr[i] = (char*) malloc(columnSize + 1);
		SQLBindCol(stmt, i + 1, SQL_C_CHAR, columnPtr[i], columnSize + 1, &columnInd[i]);
	}

	/***************************************
	 무슨항목을 찍는 태그를 출력한다.
	 ***************************************/
	_log("[%s]\n", xquery[index].tagName);

	/***************************************
	 fetch 하면서 출력한다.
	 ***************************************/
	rcount = 0;
	while (1)
	{
		rc = SQLFetch(stmt);
		if (rc == SQL_NO_DATA)
		{
			break;
		}
		else if (rc != SQL_SUCCESS)
		{
			dbErrMsg();
			/***********************************
			 return하기전에 메모리 해제.
			 ***********************************/
			for (i = 0; i < columnCount; i++)
			{
				free(columnPtr[i]);
			}
			free(columnPtr);
			free(columnInd);

			return;
		}

		/***************************************
		 컬러명 = 실제값 형태로 찍는다. 한줄에 찍기 위해 변수에 담고
		 해당 변수를 찍는다. 쿼리 자체에 Alias를 쓰면 이쁘게 될듯.
		 ***************************************/
		memset(dData, 0x00, sizeof(dData));

		for (i = 0; i < columnCount; i++)
		{
			memset(columnName, 0x00, sizeof(columnName));
			SQLDescribeCol(stmt, (i + 1), columnName, sizeof(columnName),
					&columnNameLength, &dataType, &columnSize, &scale, &nullable);

			/********************************************************
			 출력할 값을 변수로 만든다.
			 ********************************************************/
			strcat(dData, (char*) columnName);
			strcat(dData, "= [");
			strcat(dData, columnPtr[i]);
			strcat(dData, "]  ");
		}

		// TODO: saveDB((char*)"0",  xquery[index].tagName,  dData);
		/********************************************
		 DISPLAY 옵션에 따라 로깅여부 판단.
		 ********************************************/
		if (xquery[index].display[0] == '1')
			_log("%s\n", dData);

		rcount++;
	}

	SQLFreeStmt(stmt, SQL_CLOSE);

	/***************************************
	 아무것도 한게 없으면 없다 출력한다.
	 ***************************************/
	if (xquery[index].display[0] == '1')
	{
		if (rcount == 0)
			_log("[NO_DATA]\n");
	}

	/***************************************
	 메모리 해제하시라..
	 ***************************************/
	for (i = 0; i < columnCount; i++)
	{
		free(columnPtr[i]);
	}

	free(columnPtr);
	free(columnInd);
} // void getData(int index)


/***************************************
 configFile을 읽어서 모니터링 그룹셋에 대한 
 구조체를 생성시킨다.
 ***************************************/
void makeQuerySet()
{
	char realTag[65536];
	char buff[65536];
	char beginTag[255];
	char endTag[255];
	char tmp[8192];
	char name123[255];
	char name321[255];
	FILE *fp;
	int i, k, count;
	int start = -1, end = -1;
	int flagStart = 0;

	/**********************************************
	 파일을 통째로 읽는다. 64K 이내에서.
	 **********************************************/
	fp = fopen(configFile, "r");
	if (fp == NULL)
	{
		_log("makeQuerySet.fopen\n");
		exit(-1);
	}

	//TODO: [OKT] add COMMENT Ignore Code..
	memset(buff, 0x00, sizeof(buff));
	fread(buff, sizeof(buff) - 1, 1, fp);
	fclose(fp);

	/**********************************************
	 전체를 통괄하는 MONITOR_QUERY_GROUP_SET
	 **********************************************/
	sprintf(name123, "<%s>", "MONITOR_QUERY_GROUP_SET");
	sprintf(name321, "</%s>", "MONITOR_QUERY_GROUP_SET");
	k = (int) strlen(buff);
	start = -1;
	end = -1;

	/**********************************************
	 전체 태그의 시작, 끝이 어딘지 알아야 한다.
	 **********************************************/
	for (i = 0; i < k; i++)
	{
		if (memcmp(buff + i, name123, (int) strlen(name123)) == 0)
			start = i + (int) strlen(name123);

		if (memcmp(buff + i, name321, (int) strlen(name321)) == 0)
			end = i - 2;
	}

	/**********************************************
	 잘못된거면 그냥 죽으시라.
	 **********************************************/
	if (start == -1 || end == -1)
	{
		_log("Not Found %s!!!!\n", name123);
		exit(-1);
	}

	memset(realTag, 0x00, sizeof(realTag));
	memcpy(realTag, buff + start, end - start + 1);

	memset(&xquery, 0x00, sizeof(xquery));
	memset(beginTag, 0x00, sizeof(beginTag));
	memset(endTag, 0x00, sizeof(endTag));
	memset(tmp, 0x00, sizeof(tmp));
	count = 0;
	QUERYSET_COUNT = 0;
	k = (int) strlen(realTag);

	/**********************************************
	 일단, 약속하기를 아래와 같은 형태임으로
	 <MainTAG>
	 <QUERY> </QUERY>
	 <DISPLAY> </DISPLAY>
	 </MainTAG>

	 실제 여기서는 MainTAG명만 알아내기 위해 처리한다.
	 상세 값들은 getQuery함수를 쓰신다.
	 **********************************************/
	for (i = 0; i < k; i++)
	{
		if (realTag[i] == '<')
		{
			memset(tmp, 0x00, sizeof(tmp));
			count = 0;
			flagStart = 1;
			continue;
		}

		if (flagStart == 1 && realTag[i] == '>')
		{
			/************************************************
			 아래 단어들이면 무시하시라. tag를 추가할때마다 수정하셔야 한다.
			 ************************************************/
			//TODO: [OKT] Tag 이름이 오타이거나, 없다면, 오류표시도 없이 무시된다. (BUGBUG)
			if ( memcmp(tmp, "QUERY", 5) == 0 || memcmp(tmp, "/QUERY", 6) == 0
					|| memcmp(tmp, "INTERVAL", 7) == 0 || memcmp(tmp, "/INTERVAL", 8) == 0
					|| memcmp(tmp, "DISPLAY", 7) == 0 || memcmp(tmp, "/DISPLAY", 8) == 0
					|| memcmp(tmp, "ENABLE", 6) == 0 || memcmp(tmp, "/ENABLE", 7) == 0
					)
			{
				flagStart = 0;
				continue;
			}

			/************************************************
			 BeginTag, endTag를 짝으로 비교해서 맞는지를 체크한다.
			 ************************************************/
			if (beginTag[0] == 0x00)
			{
				memcpy(beginTag, tmp, strlen(tmp));
				//_log((char*)"beginTag = [%s]\n", beginTag);
			}
			else if (endTag[0] == 0x00)
			{
				memcpy(endTag, tmp + 1, strlen(tmp) - 1);
				//_log((char*)"endTag = [%s]\n", endTag);
			}

			if (beginTag[0] != 0x00 && endTag[0] != 0x00)
			{
				/************************************************
				 MainTag가 발견되었다면.. 상세항목을 저장해둔다.
				 ************************************************/
				if (memcmp(beginTag, endTag, strlen(beginTag)) == 0)
				{
					_log("mainTag= [%s]\n", beginTag);
					getQuery(beginTag, QUERYSET_COUNT);
					QUERYSET_COUNT++;
					if (QUERYSET_COUNT >= 100)
						break;
				}

				memset(beginTag, 0x00, sizeof(beginTag));
				memset(endTag, 0x00, sizeof(endTag));
			}
			flagStart = 0;
			continue;
		}

		tmp[count] = realTag[i];
		count++;
		if (count >= 1024)
		{
			memset(tmp, 0x00, sizeof(tmp));
			count = 0;
		}
	} // for

	_log("Total TagCount= [%d]\n", QUERYSET_COUNT);
} // void makeQuerySet()




// TODO: DB저장옵션을 활성화하면 directExec방법으로 처리를 수행한다.
int  saveDB(char *logType, char *tagName, char *value)
{
	return -1;

	char query[65536];

	sprintf(query,
			"insert into gdmon4alt_log (sitename, intime, logType, tagName, tagValue) "
					"values ('%s', to_char(sysdate, 'YYYYMMDDHHMISS'), '%s', '%s', trim('%s')) ",
			"siteName", logType, tagName, value);
	if (SQLExecDirect(stmt2, (SQLCHAR*) query, SQL_NTS) != SQL_SUCCESS)
	{
		dbErrMsg3();
		SQLFreeStmt(stmt2, SQL_CLOSE);
		return -1;
	}

	SQLFreeStmt(stmt2, SQL_CLOSE);

	return 1;
} // int  saveDB(char *logType, char *tagName, char *value)




/**********************************************
 MAIN FUNCTION
 *********************************************/
int  main(int argc, char *argv[])
{
	char TEMP[1024];
	char _PCOM[1024];
	int i;

	/*************************************
	 환경변수 적용여부 확인.
	 *************************************/
	if (getenv("ALTIBASE_HOME") == NULL)
	{
		printf("Please, Set environmentVariable ALTIBASE_HOME \n");
		exit(-1);
	}

	/*************************************
	 ProcessChk에서 필요하기 때문에..
	 *************************************/
	if (getenv("UNIX95") == NULL)
	{
		(void) setenv("UNIX95", "1", 0);
	}

	/*************************************
	 configFile은 어디에??
	 *************************************/
	//sprintf(configFile, "%s/conf/gdmon4alt.conf", getenv("ALTIBASE_HOME"));
	sprintf(configFile, "./gdmon4alt.conf");

	/*************************************
	 start , stop 처리
	 *************************************/
	if (argc < 2)
	{
		printf("Usage] gdmon4alt [start | stop]\n");
		exit(-1);
	}

	if (memcmp(argv[1], "stop", 4) == 0)
	{
		memset(TEMP, 0x00, sizeof(TEMP));
		sprintf(_PCOM, "kill -9 `ps -ef|grep gdmon4alt|grep -v tail|grep -v gdb|grep -v dbx|grep -v vi|grep -v grep|grep -v %d|awk '{print $2}'` > /dev/null 2>&1", getpid());
		runCommand(_PCOM, TEMP);
		exit(-1);
	}

	//start를 수행시 이미 떠 있는지를 체크한다.
	if (memcmp(argv[1], "start", 5) == 0)
	{
		sprintf(_PCOM, "ps -ef|grep gdmon4alt|grep -v tail|grep -v gdb|grep -v dbx|grep -v vi|grep -v grep | grep -v %d | wc -l", getpid());
		runCommand(_PCOM, TEMP);
		if ( atoi(TEMP) > 0 )
		{
			printf("gdmon4alt already started.!!\n");
			exit(-1);
		}
	}
	else
	{
		printf("Usage] gdmon4alt [start | stop]\n");
		exit(-1);
	}

	/*************************************
	 make daemon
	 *************************************/
//	if (fork() > 0) exit(0);
//	setsid();
//	umask(0);

	/*************************************
	 일단, 필요한 항목을 얻어오자.
	 *************************************/
	memset(LOG_FILE, 0x00, sizeof(LOG_FILE));
	memset(SLEEP_TIME, 0x00, sizeof(SLEEP_TIME));
//	memset(DB_SAVE, 0x00, sizeof(DB_SAVE));

	getSimpleParam("GDMON_PROPERTY", "LOG_FILE", LOG_FILE);
	getSimpleParam("GDMON_PROPERTY", "SLEEP_TIME", SLEEP_TIME);
	getSimpleParam("GDMON_PROPERTY", "DB_SAVE", DB_SAVE);

	/*************************************
	 일단, 필요한 OS정보들..
	 *************************************/
	runCommand((char*) "uname", UNAME);
	memcpy(gUNAME, UNAME, strlen(UNAME));
	_log("UNAME= [%s]\n", UNAME);

	/*************************************
	 DB연결해보고 필요정보들 가져오기
	 *************************************/
	if (dbConnect() != 0)
	{
		printf("Can't Connect DB , check errorLog [%s]\n", LOG_FILE);
		exit(-1);
	}
	dbFree();

	/*************************************
	 모니터링을 위해 필요한것들을 셋팅한다.
	 *************************************/
	makeQuerySet();

	int  sSleepTime = 1;
	if ( atoi(SLEEP_TIME) - 1 > 1 )
	{
		sSleepTime = atoi(SLEEP_TIME) - 1 ;
	}

	/*************************************
	 Main Start
	 *************************************/
	while (1)
	{
		if (dbConnect() != 0)
		{
			dbFree();
			sleep( sSleepTime );
			continue;
		}

		_log( "================================= GDMON CHECK START ======================================\n");
		g_interval ++ ;

		/*******************************************
		 읽어들인 MainTag들에 대한 수행을 처리한다.
		 *******************************************/
		for (i = 0; i < QUERYSET_COUNT; i++)
		{
			if (memcmp(xquery[i].enable, "OFF", 3) == 0)
				continue;

			// DO SOMETHING..
			getData(i);

			if (xquery[i].display[0] == '1')
				_log("\n");
		}

		_log( "================================= GDMON CHECK ENDED ======================================\n\n");

		/*******************************************
		 사용자가 지정한 지정한 시간만큼 Sleep
		 *******************************************/
		dbFree();

		if ( g_interval == 3 ) exit(0);
		sleep( sSleepTime );
	}
} // main

