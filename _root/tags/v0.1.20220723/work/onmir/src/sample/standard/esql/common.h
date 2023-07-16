#ifndef COMMON_H_
#define COMMON_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <assert.h>
#include <ctype.h>
#include <dlfcn.h>
#include <stdarg.h>
#include <signal.h>
#include <sys/time.h>

#ifdef __cplusplus
extern "C" {
#endif

/*************************************************************
 * 구조체
*************************************************************/
typedef struct dbmHandle
{
    long   mMark;
    int    mInternalCode;
    void*  mHandle;
} dbmHandle ;

extern char    dst_node[30+1];

/*************************************************************
 * Function
*************************************************************/

extern void _log(char *format, ...);
extern int  getRandomInt(int, int);
extern void showTotal(int, double );
extern double checkTime( struct timeval *, struct timeval *, int);
extern double showElapsed(int count, struct timeval *start_time, struct timeval *end_time);

#define WORKING_DIR "."
#define CHECK_POINT 5000
#define CONN_TCP    1
#define CONN_UNIX   2
#define CONN_IPC    3
#define CONN_DA     4
#define COMMIT_MODE 1	/* 0 : autocommit , 		1 : non_autocommit_mode */

#define CHECKTIME()  \
        if( (loopCnt%CHECK_POINT) == 0 && loopCnt != 0 ) \
        { \
            gettimeofday(&endTime, (void *)NULL);  \
            totalTime += checkTime(&startTime, &endTime, loopCnt); \
            gettimeofday(&startTime, (void *)NULL); \
        }
#ifdef __cplusplus
}
#endif

#endif /* COMMON_H_ */
