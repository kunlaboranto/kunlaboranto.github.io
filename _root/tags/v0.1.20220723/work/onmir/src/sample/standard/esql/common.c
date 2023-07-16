#include "common.h"

void _log(char *format, ...)
{
    FILE *fp ;
    char ss[255];
    va_list ap;

#if 0
    sprintf(ss, "%s/bmt.log", WORKING_DIR);
    fp = fopen(ss, "a+");
	if (fp == NULL) {
		perror("fopen");
		exit(-1);
	}

    va_start(ap, format);
    //vfprintf (fp, format, ap);
    vfprintf (stdout, format, ap);
    va_end(ap);

    fflush(stdout);
    fclose(fp);
#else
    va_start(ap, format);
    vfprintf (stdout, format, ap);
    va_end(ap);
    fflush(stdout);
#endif
}

/**********************************************************
** show time
**********************************************************/
double  showElapsed(int count, struct timeval *start_time, struct timeval *end_time)
{
    struct timeval v_timeval;
    double elapsedtime ;

    v_timeval.tv_sec  = end_time->tv_sec  - start_time->tv_sec;
    v_timeval.tv_usec = end_time->tv_usec - start_time->tv_usec;

    if (v_timeval.tv_usec < 0)
    {
        v_timeval.tv_sec -= 1;
        v_timeval.tv_usec = 999999 - v_timeval.tv_usec * (-1);
    }

    elapsedtime = v_timeval.tv_sec*1000000+v_timeval.tv_usec;
    _log("[%s] [%9d]", dst_node, count);
    _log(" Elapsed Time ==>       %15.3f seconds (%8.1f tps)\n",
        elapsedtime/1000000.00, (double)( CHECK_POINT/(elapsedtime/1000000.00) ) );
    return elapsedtime ;
}

double checkTime(struct timeval *sTime, struct timeval *eTime, int val)
{
    double elapsedtime;

    elapsedtime = showElapsed(val,sTime, eTime);
    return elapsedtime;
}


void showTotal(int processed, double totalTime )
{   
    _log("[%s] Total Elapsed Time ==> %15.3f seconds \n", dst_node, totalTime/1000000.00);
    _log("[%s] TPS(Transaction per Second) ==> %8.1f TPS \n", dst_node, (double)((processed-1)*1000000.0/totalTime));
}


/**********************************************************
** return random value (from low to high)
**********************************************************/
int getRandomInt(int low, int high)
{
    return (lrand48()%(high-low+1)) + low;
}
