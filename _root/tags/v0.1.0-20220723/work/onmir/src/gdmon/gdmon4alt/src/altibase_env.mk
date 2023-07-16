###############################################################################
#  Copyright 1999-2006, AltiBase Corporation or its subsidiaries.
#  All rights reserved.
###############################################################################

###############################################################################
# $Id: altibase_env_head.mk 15752 2006-05-16 00:23:46Z sjkim $
###############################################################################
Q=@
NM=/usr/bin/nm
NMFLAGS=-t x
OS_TARGET=XEON_LINUX
OS_MAJORVER=0
OS_MINORVER=0
OS_LINUX_PACKAGE=redhat_Enterprise
OS_LINUX_VERSION=release5
OS_LINUX_KERNEL=1
compile64=1
compat5=1
CXX=g++
CC=gcc
AR=ar
COMPILE.cc=g++ -D_GNU_SOURCE -W -Wall -pipe -D_POSIX_PTHREAD_SEMANTICS -D_POSIX_THREADS -D_POSIX_THREAD_SAFE_FUNCTIONS -D_REENTRANT -DPDL_HAS_AIO_CALLS -O0 -funroll-loops -fno-strict-aliasing -DPDL_NDEBUG -fno-implicit-templates -Wno-deprecated -fno-exceptions -fcheck-new -D__PDL_INLINE__ -DPDL_LACKS_PDL_TOKEN -DPDL_LACKS_PDL_OTHER -c
COMPILE.c=gcc -W -Wall -pipe -D_POSIX_PTHREAD_SEMANTICS -D_POSIX_THREADS -D_POSIX_THREAD_SAFE_FUNCTIONS -D_REENTRANT -DPDL_HAS_AIO_CALLS -O0 -funroll-loops -fno-strict-aliasing -DPDL_NDEBUG -c
DEFOPT=-D
IDROPT=-I
LDROPT=-L
LIBOPT=-l
LIBAFT=
AROUT=
LDOUT=-o
SOOUT=-o
CCOUT=-o
ARFLAGS=-ruv
DEFINES=-D_REENTRANT
CCFLAGS=-D_GNU_SOURCE -W -Wall -pipe -D_POSIX_PTHREAD_SEMANTICS -D_POSIX_THREADS -D_POSIX_THREAD_SAFE_FUNCTIONS -D_REENTRANT -DPDL_HAS_AIO_CALLS -O0 -funroll-loops -fno-strict-aliasing -DPDL_NDEBUG -fno-implicit-templates -Wno-deprecated -fno-exceptions -fcheck-new -D__PDL_INLINE__ -DPDL_LACKS_PDL_TOKEN -DPDL_LACKS_PDL_OTHER
CFLAGS=-W -Wall -pipe -D_POSIX_PTHREAD_SEMANTICS -D_POSIX_THREADS -D_POSIX_THREAD_SAFE_FUNCTIONS -D_REENTRANT -DPDL_HAS_AIO_CALLS -O0 -funroll-loops -fno-strict-aliasing -DPDL_NDEBUG
DCFLAGS=-g -DDEBUG
DCCFLAGS=
OCFLAGS=-O0 -funroll-loops -fno-strict-aliasing
OCCFLAGS=
EFLAGS=-E -D_POSIX_PTHREAD_SEMANTICS -D__ACE_INLINE__ -DACE_LACKS_ACE_TOKEN -DACE_LACKS_ACE_OTHER -O0
SFLAGS=-S -D_POSIX_PTHREAD_SEMANTICS -D__ACE_INLINE__ -DACE_LACKS_ACE_TOKEN -DACE_LACKS_ACE_OTHER -O0
LD=g++
LFLAGS=-Wl,-relax -L. -O0
OBJEXT=o
SOEXT=so
BINEXT=
LIBEXT=a
LIBPRE=lib
COPY=cp
RM=rm -rf
ODBC_INCLUDES=-I/usr/local/odbcDriverManager64/include
ODBC_LIBDIRS=-L/usr/local/odbcDriverManager64/lib
ODBC_LIBS=-lodbc
LIBS= -ldl -lpthread -lcrypt -lrt
SH_LIBS= -ldl -lpthread -lcrypt -lrt
RTL_FLAG=
LDOUT +=  # intentionally put this 
SOOUT +=  # intentionally put this 
CCOUT +=  # intentionally put this 
SOLINK.cc= g++ -shared
SOFLAGS= -shared
PIC=-fPIC
INCLUDES = $(IDROPT)$(ALTIBASE_HOME)/include $(IDROPT).
LIBDIRS = $(LDROPT)$(ALTIBASE_HOME)/lib
LFLAGS += $(LIBDIRS)

########################
#### common rules
########################
%.$(OBJEXT): %.cpp
	$(COMPILE.cc) $(INCLUDES) $(CCOUT)$@ $<

%.p: %.cpp
	$(CXX) $(EFLAGS) $(DEFINES) $(INCLUDES) $< > $@

%.s: %.cpp
	$(CXX) $(SFLAGS) $(DEFINES) $(INCLUDES) $< > $@

%.$(OBJEXT): %.c
	$(COMPILE.c) $(INCLUDES) $(CCOUT)$@ $<

