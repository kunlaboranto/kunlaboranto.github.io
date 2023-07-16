# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific aliases and functions

####################
# COMMON
####################

umask 022
set -o vi
#stty erase "^H"

ulimit -c 0
#ulimit -c unlimited
#ulimit -n 4096             # Not on HP-UX

export PATH=$HOME/local/bin:$HOME/bin:$PATH:.

export EDITOR=vi
export HISTSIZE=5000

test "x`uname`" = "xHP-UX" && set +u

if [ "x$LANG" = "x" -a "x`uname`" != "xHP-UX" ]
then
    #export LANG=ko_KR.utf8
    export LANG=en_US.utf8
fi

test "x"$HOSTNAME = "x" && export HOSTNAME=`hostname`

if [ "x$LIBPATH" != "x" ]
then
    export LD_LIBRARY_PATH=$LIBPATH
fi

test "x`uname`" = "xHP-UX" && set -u

#export PS1='['`hostname`':$LOGNAME:$PWD] '
#export PS1='[\u@\h \W]\n\$ '
export PS1="
$LOGNAME@$HOSTNAME: \$PWD
$ "

####################
# JAVA
####################

if [ -d $HOME/java/. ]
then
    export JAVA_HOME=$HOME/java
    export PATH=$JAVA_HOME/bin:$PATH
fi

####################
# ETC
####################

test -f $HOME/.profile.onmir    && . $HOME/.profile.onmir

if [ "x"$HOSTNAME = "xlo" ]
then
    test -f $HOME/.profile.mysql    && . $HOME/.profile.mysql
    test -f $HOME/.profile.oracle   && . $HOME/.profile.oracle
    test -f $HOME/.profile.tibero   && . $HOME/.profile.tibero
    test -f $HOME/.profile.altibase && . $HOME/.profile.altibase
fi

####################
# FINALLY
####################

test -f $HOME/.aliases          && . $HOME/.aliases

export LIBPATH=$LD_LIBRARY_PATH
unset PROMPT_COMMAND

#export JAVA_HOME=""
