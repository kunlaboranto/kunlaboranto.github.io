#include $(ALTIBASE_HOME)/install/altibase_env.mk
include ./altibase_env.mk

SRCS=gdmon4alt.cpp
OBJS=$(SRCS:$(DEV_DIR)/%.cpp=$(TARGET_DIR)/%.$(OBJEXT))
BINS=gdmon4alt

COMPILE.cc += -g
COMPILE.c += -g

all: $(BINS)

gdmon4alt: gdmon4alt.$(OBJEXT)
	$(LD) $(LFLAGS) $(LDOUT)gdmon4alt$(BINEXT) gdmon4alt.$(OBJEXT) $(LIBOPT)odbccli$(LIBAFT) $(LIBS)

clean:
	$(RM) $(BINS) *.$(OBJEXT) core

