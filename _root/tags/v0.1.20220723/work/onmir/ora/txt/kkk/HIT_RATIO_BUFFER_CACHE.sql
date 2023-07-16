
SELECT DISTINCT SYSDATE
     , 'BUFFER_CACHE_HIT_RATIO' AS buffer_cache_hit_ratio
     , 100 * ROUND(1 -((MAX(decode(name, 'physical reads cache', VALUE))) /(MAX(decode(name, 'db block gets from cache', VALUE)) + MAX(decode(name, 'consistent gets from cache', VALUE)))), 4) AS VALUE
     , MAX(decode(name, 'physical reads cache', VALUE)), MAX(decode(name, 'db block gets from cache', VALUE)), MAX(decode(name, 'consistent gets from cache', VALUE))
FROM v$sysstat;

/* BAD

Buffer Cache Hit Ratio                    SUM(DECODE(NAME,'PHYSICALREADS',VALUE,0)) SUM(DECODE(NAME,'DBBLOCKGETS',VALUE,0)) SUM(DECODE(NAME,'CONSISTENTGETS',VALUE,0))
----------------------------------------- ----------------------------------------- --------------------------------------- ------------------------------------------
-113428485001921%                                                        1.8447E+19                                 2114369                                   14148516

SYSDATE            BUFFER_CACHE_HIT_RATIO      VALUE MAX(DECODE(NAME,'PHYSICALREADSCACHE',VALUE)) MAX(DECODE(NAME,'DBBLOCKGETSFROMCACHE',VALUE)) MAX(DECODE(NAME,'CONSISTENTGETSFROMCACHE',VALUE))
------------------ ---------------------- ---------- -------------------------------------------- ---------------------------------------------- -------------------------------------------------
18-JUL-19          BUFFER_CACHE_HIT_RATIO      88.76                                      1680776                                        2039191                                          12914625


SELECT
       ROUND((
       (1 -
       (
       SUM(DECODE(name, 'physical reads', value, 0))
       / ( SUM(DECODE(name, 'db block gets', value, 0)) + SUM(DECODE(name, 'consistent gets', value, 0)) )
       )
       )
       * 100), 2) || '%' "Buffer Cache Hit Ratio"
     , SUM(DECODE(name, 'physical reads', value, 0)) , SUM(DECODE(name, 'db block gets', value, 0)) , SUM(DECODE(name, 'consistent gets', value, 0))
  FROM V$SYSSTAT
;
*/
