#!/bin/sh

while test $# -gt 2; do shift; done

#vimdiff -R -u /scratch/home/infra/isuha85/suha/.vimrc '+set diffopt+=iwhite' $2 $1
#vimdiff -R -u /scratch/home/infra/isuha85/suha/.vimrc $2 $1
#vimdiff -u /scratch/home/infra/isuha85/suha/.vimrc $2 $1
vimdiff "+:1" -u $_C_HOME/.vimrc $2 $1

#tkdiff $2 $1
