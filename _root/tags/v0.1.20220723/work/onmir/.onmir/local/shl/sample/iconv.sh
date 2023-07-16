#!/bin/sh

src=$1

FCODE="euc-kr"
TCODE="UTF8"

chk=`echo $src |grep -e "\.svn" -e "\.so" -e "\.a" -e "\.tar" -e "\.gz" -e "\.xl" |wc -l`
if [ "x"$chk != "x0" ]
then
    exit 0
fi

if [ "x"$src != "x" ]
then
    mv $src $src.orig
    iconv -c -f ${FCODE} -t ${TCODE} $src.orig > $src
    iconv -c -f ${TCODE} -t ${FCODE} $src > $src.iconv.chksum
    chk=`cmp $src.iconv.chksum $src.orig |wc -l`
    if [ "x"$chk != "x0" ]
    then
        mv $src.orig $src
        echo "(E) iconv -c -f ${FCODE} -t ${TCODE} $src.orig > $src"
        echo "(E) iconv conversion fail ($src)"
        echo ""
        sleep 2
        exit 1
    else
        echo "(I) iconv conversion done ($src)"
        rm -f $src.iconv.chksum
        exit 0
    fi
fi

exit

for i in `ls *.*`
do
    if [ -f $i.orig ]
    then
        echo "already exist. skip ($i.orig)"
    fi
    mv $i $i.orig
    iconv -c -f ${FCODE} -t ${TCODE} $i.orig > $i
done

# find . -type f -exec file --mime-encoding  {} \; |grep 8859
# find . -type f -exec iconv.sh {} \;

