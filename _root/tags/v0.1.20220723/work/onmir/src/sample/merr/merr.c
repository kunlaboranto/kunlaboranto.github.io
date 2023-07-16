#include "apue.h"

#define NEVER NULL

typedef struct _dla_err_map
{
    char name[15+1];
    int  no;
    char msg[80+1];
    
} dla_err_map;

dla_err_map err_map[] = {
  {"EPERM          ",   1, "xx"}
, {"ENOENT         ",   2, "xx"}
//({{{
, {"ESRCH          ",   3, "xx"}
, {"EINTR          ",   4, "xx"}
, {"EIO            ",   5, "xx"}
, {"ENXIO          ",   6, "xx"}
, {"E2BIG          ",   7, "xx"}
, {"ENOEXEC        ",   8, "xx"}
, {"EBADF          ",   9, "xx"}
, {"ECHILD         ",  10, "xx"}
, {"EAGAIN         ",  11, "xx"}
, {"ENOMEM         ",  12, "xx"}
, {"EACCES         ",  13, "xx"}
, {"EFAULT         ",  14, "xx"}
, {"ENOTBLK        ",  15, "xx"}
, {"EBUSY          ",  16, "xx"}
, {"EEXIST         ",  17, "xx"}
, {"EXDEV          ",  18, "xx"}
, {"ENODEV         ",  19, "xx"}
, {"ENOTDIR        ",  20, "xx"}
, {"EISDIR         ",  21, "xx"}
, {"EINVAL         ",  22, "xx"}
, {"ENFILE         ",  23, "xx"}
, {"EMFILE         ",  24, "xx"}
, {"ENOTTY         ",  25, "xx"}
, {"ETXTBSY        ",  26, "xx"}
, {"EFBIG          ",  27, "xx"}
, {"ENOSPC         ",  28, "xx"}
, {"ESPIPE         ",  29, "xx"}
, {"EROFS          ",  30, "xx"}
, {"EMLINK         ",  31, "xx"}
, {"EPIPE          ",  32, "xx"}
, {"EDOM           ",  33, "xx"}
, {"ERANGE         ",  34, "xx"}
, {"EDEADLK        ",  35, "xx"}
, {"ENAMETOOLONG   ",  36, "xx"}
, {"ENOLCK         ",  37, "xx"}
, {"ENOSYS         ",  38, "xx"}
, {"ENOTEMPTY      ",  39, "xx"}
, {"ELOOP          ",  40, "xx"}
, {"EWOULDBLOCK    ",  11, "xx"}
, {"ENOMSG         ",  42, "xx"}
, {"EIDRM          ",  43, "xx"}
, {"ECHRNG         ",  44, "xx"}
, {"EL2NSYNC       ",  45, "xx"}
, {"EL3HLT         ",  46, "xx"}
, {"EL3RST         ",  47, "xx"}
, {"ELNRNG         ",  48, "xx"}
, {"EUNATCH        ",  49, "xx"}
, {"ENOCSI         ",  50, "xx"}
, {"EL2HLT         ",  51, "xx"}
, {"EBADE          ",  52, "xx"}
, {"EBADR          ",  53, "xx"}
, {"EXFULL         ",  54, "xx"}
, {"ENOANO         ",  55, "xx"}
, {"EBADRQC        ",  56, "xx"}
, {"EBADSLT        ",  57, "xx"}
, {"EDEADLOCK      ",  35, "xx"}
, {"EBFONT         ",  59, "xx"}
, {"ENOSTR         ",  60, "xx"}
, {"ENODATA        ",  61, "xx"}
, {"ETIME          ",  62, "xx"}
, {"ENOSR          ",  63, "xx"}
, {"ENONET         ",  64, "xx"}
, {"ENOPKG         ",  65, "xx"}
, {"EREMOTE        ",  66, "xx"}
, {"ENOLINK        ",  67, "xx"}
, {"EADV           ",  68, "xx"}
, {"ESRMNT         ",  69, "xx"}
, {"ECOMM          ",  70, "xx"}
, {"EPROTO         ",  71, "xx"}
, {"EMULTIHOP      ",  72, "xx"}
, {"EDOTDOT        ",  73, "xx"}
, {"EBADMSG        ",  74, "xx"}
, {"EOVERFLOW      ",  75, "xx"}
, {"ENOTUNIQ       ",  76, "xx"}
, {"EBADFD         ",  77, "xx"}
, {"EREMCHG        ",  78, "xx"}
, {"ELIBACC        ",  79, "xx"}
, {"ELIBBAD        ",  80, "xx"}
, {"ELIBSCN        ",  81, "xx"}
, {"ELIBMAX        ",  82, "xx"}
, {"ELIBEXEC       ",  83, "xx"}
, {"EILSEQ         ",  84, "xx"}
, {"ERESTART       ",  85, "xx"}
, {"ESTRPIPE       ",  86, "xx"}
, {"EUSERS         ",  87, "xx"}
, {"ENOTSOCK       ",  88, "xx"}
, {"EDESTADDRREQ   ",  89, "xx"}
, {"EMSGSIZE       ",  90, "xx"}
, {"EPROTOTYPE     ",  91, "xx"}
, {"ENOPROTOOPT    ",  92, "xx"}
, {"EPROTONOSUPPORT",  93, "xx"}
, {"ESOCKTNOSUPPORT",  94, "xx"}
, {"EOPNOTSUPP     ",  95, "xx"}
, {"EPFNOSUPPORT   ",  96, "xx"}
, {"EAFNOSUPPORT   ",  97, "xx"}
, {"EADDRINUSE     ",  98, "xx"}
, {"EADDRNOTAVAIL  ",  99, "xx"}
, {"ENETDOWN       ", 100, "xx"}
, {"ENETUNREACH    ", 101, "xx"}
, {"ENETRESET      ", 102, "xx"}
, {"ECONNABORTED   ", 103, "xx"}
, {"ECONNRESET     ", 104, "xx"}
, {"ENOBUFS        ", 105, "xx"}
, {"EISCONN        ", 106, "xx"}
, {"ENOTCONN       ", 107, "xx"}
, {"ESHUTDOWN      ", 108, "xx"}
, {"ETOOMANYREFS   ", 109, "xx"}
, {"ETIMEDOUT      ", 110, "xx"}
, {"ECONNREFUSED   ", 111, "xx"}
, {"EHOSTDOWN      ", 112, "xx"}
, {"EHOSTUNREACH   ", 113, "xx"}
, {"EALREADY       ", 114, "xx"}
, {"EINPROGRESS    ", 115, "xx"}
, {"ESTALE         ", 116, "xx"}
, {"EUCLEAN        ", 117, "xx"}
, {"ENOTNAM        ", 118, "xx"}
, {"ENAVAIL        ", 119, "xx"}
, {"EISNAM         ", 120, "xx"}
, {"EREMOTEIO      ", 121, "xx"}
, {"EDQUOT         ", 122, "xx"}
, {"ENOMEDIUM      ", 123, "xx"}
, {"EMEDIUMTYPE    ", 124, "xx"}
, {"ECANCELED      ", 125, "xx"}
, {"ENOKEY         ", 126, "xx"}
, {"EKEYEXPIRED    ", 127, "xx"}
, {"EKEYREVOKED    ", 128, "xx"}
, {"EKEYREJECTED   ", 129, "xx"}
, {"EOWNERDEAD     ", 130, "xx"}
, {"ENOTRECOVERABLE", 131, "xx"}
//, "xx"}, "xx"}, "xx"})
, {"ERFKILL        ", 132, "xx"}
//For HPUX
, {"ENOTSOCK       ", 216, "Socket operation on non-socket"}
, {"EDESTADDRREQ   ", 217, "Destination address required"}
, {"EMSGSIZE       ", 218, "Message too long"}
, {"EPROTOTYPE     ", 219, "Protocol wrong type for socket"}
, {"ENOPROTOOPT    ", 220, "Protocol not available"}
, {"EPROTONOSUPPORT", 221, "Protocol not supported"}
, {"EOPNOTSUPP     ", 223, "Operation not supported"}
, {"EAFNOSUPPORT   ", 225, "Address family not supported by protocol family"}
, {"EADDRINUSE     ", 226, "Address already in use"}
, {"EADDRNOTAVAIL  ", 227, "Can't assign requested address"}
, {"ENETDOWN       ", 228, "Network is down"}
, {"ENETUNREACH    ", 229, "Network is unreachable"}
, {"ECONNABORTED   ", 231, "Software caused connection abort"}
, {"ECONNRESET     ", 232, "Connection reset by peer"}
, {"ENOBUFS        ", 233, "No buffer space available"}
, {"EISCONN        ", 234, "Socket is already connected"}
, {"ENOTCONN       ", 235, "Socket is not connected"}
, {"ETIMEDOUT      ", 238, "Connection timed out"}
, {"ECONNREFUSED   ", 239, "Connection refused"}
, {"EHOSTUNREACH   ", 242, "No route to host"}
, {"EALREADY       ", 244, "Operation already in progress"}
, {"EINPROGRESS    ", 245, "Operation now in progress"}
, {"EWOULDBLOCK    ", 246, "Operation would block"}
};

char *get_ename(int errno_)
{
    int i;
    for (i=0; ; i++)
    {
        if (err_map[i].no == errno_) {
            return err_map[i].name;
        }
    }

    return NEVER;
}

char *strerror_(int errnum)
{
    int i;
    if ( errnum >= 216 && errnum <= 246 )
    {
        for (i=0; ; i++)
        {
            if (err_map[i].no == errnum) {
                return err_map[i].msg;
            }
        }

    }
    else
    {
        return strerror(errnum);
    }

}

int main( int argc, char *argv[] )
{
    int eno = -1;
    char ch;

    if (argc < 2)
    {
        printf("usage:\t(strerror) \n\t%s <errno> [ascii_char] (argc=%d)\n", argv[0], argc);
        exit(-1);
    }

    eno = atoi(argv[1]);
    printf("## errno ##\n");
    printf("\terrno\t= %d\n", eno);
    printf("\t name\t= %s\n", get_ename(eno));
    printf("\t  msg\t= %s\n", strerror_(eno));
    printf("\n");

    if (argc > 2)
    {
        ch = argv[2][0];
        printf("\n## ASCII ##\n");
        printf("\t'%c' = %d (dec), %#x (hex), %#o (oct)\n", ch, ch, ch, ch);

    }

    return 0;
}
