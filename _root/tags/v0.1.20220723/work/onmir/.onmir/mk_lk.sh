#!/bin/sh

# 미리 링크를 만들어서 커밋하지 않는 이유는 혹시 OS 깔린것과 쫑날까봐.

cd bin
ln -s ../local/bin/htop
ln -s ../local/bin/sfnt-pingpong
ln -s ../local/bin/ioping
cd - > /dev/null

cd lib
ln -s ../local/lib/libtinfo.so.5
cd - > /dev/null
