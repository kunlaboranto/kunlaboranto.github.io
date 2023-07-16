# page|elapsed|rows|LIMIT|FULL|HASH|STORE|PROJECT|UNION|TABLE:|ACCESS: [0-9][0-9][0-9]+
# page\|elapsed\|rows\|LIMIT\|FULL\|HASH\|STORE\|PROJECT\|UNION\|TABLE:\|ACCESS: [0-9][0-9][0-9]+

alias grep='grep --color=auto'

set -x
grep -E 'page|elapsed|rows|LIMIT|FULL|HASH|STORE|PROJECT|UNION|TABLE:|ACCESS: [0-9][0-9][0-9]+' aa

echo ""
echo ""

grep -E 'page|elapsed|rows|LIMIT|FULL|HASH|STORE|PROJECT|UNION|TABLE:|ACCESS: [0-9][0-9][0-9]+' bb

echo ""
echo ""

grep -E 'page|elapsed|rows|LIMIT|FULL|HASH|STORE|PROJECT|UNION|TABLE:|ACCESS: [0-9][0-9][0-9]+' cc
set +x
