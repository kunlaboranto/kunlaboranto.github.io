#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

#if defined( __hpux )

#include <libgen.h>
#include <sys/pstat.h>

char* getProcName(int pid_ = -1)
{
    struct pst_status sPstStatus;
    int pid ;

    if ( pid_ != -1 )
    {
        pid = pid_ ;
    }
    else
    {
        pid = (int)getpid() ;
    }
    
    pstat_getproc( &sPstStatus, sizeof(sPstStatus), 0, pid );

    printf ( "(D) %s,%s\n", basename( sPstStatus.pst_cmd ), sPstStatus.pst_cmd );
    retune basename( sPstStatus.pst_cmd ) ;
}

#elif defined( __linux__ )

#include <libgen.h>

char* getProcName(int pid_ = -1)
{
	FILE* f;
	char procfile[1024];
	char name[128 + 1];
    int pid ;

    if ( pid_ != -1 )
    {
        pid = pid_ ;
    }
    else
    {
        pid = (int)getpid() ;
    }
    
	sprintf(procfile, "/proc/%d/cmdline", pid );

	f = fopen(procfile, "r");
	if (f)
    {
		size_t size;
		size = fread(name, sizeof(char), sizeof(procfile), f);
		if (size > 0)
        {
			if ('\n' == name[size - 1])
				name[size - 1] = '\0';
		}

		fclose(f);
	}


    printf ( "(D) %s,%s\n", basename( name ), name );
    return basename( name );
}

#elif defined( _AIX )

#include <libgen.h>
#include <procinfo.h>

char* getProcName(int pid_ = -1)
{
    struct procsinfo pinfo[16];
    int numproc;
    int index = 0;
    int pid ;

    if ( pid_ != -1 )
    {
        pid = pid_ ;
    }
    else
    {
        pid = (int)getpid() ;
    }
    
    while((numproc = getprocs(pinfo, sizeof(struct procsinfo), NULL, 0, &index, 16)) > 0)
    {
        for(int i=0; i<numproc; ++i)
        {
            // skip zombies
            if (pinfo[i].pi_state == SZOMB)
                continue;
            if (pid == pinfo[i].pi_pid)
            {
                printf ( "(D) %s,%s\n", basename( pinfo[i].pi_comm ), pinfo[i].pi_comm );
                return basename( pinfo[i].pi_comm );
            }
        }
    }
    return "";
}

#endif

int main(int argc, char** argv)
{
    int i;

    if ( argc > 1 )
    {
        printf ( "pid: %d, name: %s\n", atoi(argv[1]), getProcName( atoi(argv[1]) ) );
    }
    else
    {
        printf ( "pid: %d, name: %s\n", getpid(), getProcName() );
    }

    return 0;
}
