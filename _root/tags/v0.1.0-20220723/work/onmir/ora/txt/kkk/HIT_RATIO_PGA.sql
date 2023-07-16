SELECT SYSDATE
     , VALUE
     , 'PGA_HIT_RATIO' AS pga_hit_ratio
FROM v$pgastat
WHERE name = 'cache hit percentage';
