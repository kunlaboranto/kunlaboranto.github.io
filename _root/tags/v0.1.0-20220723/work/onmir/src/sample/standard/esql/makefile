# Makefile for SCI

# generic settings
SHELL = /bin/sh

# Targets
MYBINS		= bmt.gd
MYBINS2		= bmt.gd bmt.ora bmt.alti

COMMON_OBJS = common.o

# Building binaries

CC			= gcc
CXX			= g++
#LD          = gcc
LD          = g++

#ESQL		= gpec
ESQL		= proc
#ESQL		= sesc

ifeq ($(MAKECMDGOALS),)
ESQL		= gpec
endif

ifeq ($(MAKECMDGOALS),bmt.gd)
ESQL		= gpec
endif
ifeq ($(MAKECMDGOALS),bmt.ora)
ESQL		= proc
endif
ifeq ($(MAKECMDGOALS),bmt.alti)
ESQL		= sesc
endif


CFLAGS		= -Wall
CFLAGS     += -g -O3
CFLAGS	   += -Wno-unused-variable -Wno-unused-parameter -Wno-unused -Wno-variadic-macros
CFLAGS	   += -Wno-implicit-int
#CFLAGS	   += -D_POSIX_PTHREAD_SEMANTICS -D_POSIX_THREADS -D_POSIX_THREAD_SAFE_FUNCTIONS \
              -D_THREAD_SAFE -D_GNU_SOURCE 
LDFLAGS		= -lpthread -ldl -lm -lrt
#SH_LIBS 	= -fPIC


INCS		= -I./include
LIBS		= -L./lib
LIBS	   += $(LDFLAGS)

ifeq ($(ESQL),gpec)
ESQLEXT		= gc
ESQLOPT		= --include-path=.,./include
INCS	   += -I$(GOLDILOCKS_HOME)/include
LIBS	   += -L$(GOLDILOCKS_HOME)/lib
LIBS	   += -lgoldilocksesqls
LIBS	   += -lgoldilockss
endif

ifeq ($(ESQL),proc)
ESQLEXT		= pc
ESQLOPT		= lines=yes
ESQLOPT	   += parse=partial release_cursor=yes mode=ansi
ESQLOPT	   += include=$(ORACLE_HOME)/precomp/public include=$(ORACLE_HOME)/rdbms/dem/ include=$(ORACLE_HOME)/rdbms/publi/ include=$(ORACLE_HOME)/network/public
INCS	   += -I$(ORACLE_HOME)/precomp/public -I$(ORACLE_HOME)/rdbms/demo -I$(ORACLE_HOME)/rdbms/public -I$(ORACLE_HOME)/network/public
LIBS	   += -L$(ORACLE_HOME)/lib
LIBS	   += -lclntsh
endif

ifeq ($(ESQL),sesc)
ESQLEXT		= sc
ESQLOPT		= 
INCS	   += -I$(ALTIBASE_HOME)/include
LIBS	   += -L$(ALTIBASE_HOME)/lib
LIBS	   += -lsesc
LIBS	   += -lodbccli
#LIBS	   += -ldl -lpthread -lcrypt -lrt -lstdc++
endif

ESQL_GARBAGE= *.dcl *.cod *.cud *.lis
ESQL_SRCS	= bmt.$(ESQLEXT)
AUTO_SRCS	= $(ESQL_SRCS:.$(ESQLEXT)=.c)
SRCS		= $(AUTO_SRCS)
OBJS		= $(SRCS:.c=.o)


#================================================================
# Actions
#================================================================

.SUFFIXES : .$(ESQLEXT) .c .cc

.$(ESQLEXT).c :
	$(ESQL) $*.$(ESQLEXT) $(ESQLOPT)
.c.o :
	$(CC) $(CFLAGS) $(SOFLAGS) -c $*.c $(INCS)
.cc.o :
	$(CXX) $(CFLAGS) $(SOFLAGS) -c $*.cc $(INCS)

all : $(MYBINS)

#all2 : $(MYBINS2)
all2 :
	make bmt.gd   && echo "-" && sleep 1
	make bmt.ora  && echo "-" && sleep 1
	make bmt.alti && echo "-" && sleep 1

clean :
	-rm -f $(MYBINS) $(OBJS) $(AUTO_SRCS) $(ESQL_GARBAGE) *~ *.o

echo :
	echo $(OBJS)

.PHONY : all all2 clean echo

#================================================================
# Building binaries
#================================================================

bmt : bmt.o $(COMMON_OBJS)
	$(LD) -o $@ $< $(COMMON_OBJS) $(LIBS)

bmt.gd : bmt
	-mv bmt bmt.gd && rm -f *.o

bmt.ora : bmt
	-mv bmt bmt.ora && rm -f *.o

bmt.alti : bmt
	-mv bmt bmt.alti && rm -f *.o

libtest.so : test.o $(COMMON_OBJS)
	$(LD) -shared -Wl,-soname=$(MYBINS).xx.1 -o $@ $< $(COMMON_OBJS) $(SH_LIBS)

# END OF FILE
