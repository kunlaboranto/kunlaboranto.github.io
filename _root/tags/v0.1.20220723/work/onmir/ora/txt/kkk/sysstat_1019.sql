SELECT TO_CHAR( DV1/DTM , '999,999,999,999' ) TPS2
     , X.*
  FROM (SELECT ( B.TM - A.TM ) * 3600 * 24 DTM
             , ( B.VALUE - A.VALUE ) DV1
             , B.*
          FROM OKT_SYSSTAT_0 A
             , OKT_SYSSTAT_2 B
         WHERE 1=1
           AND A.NAME = B.NAME
           AND (1=0
                    OR UPPER(A.NAME) LIKE '%COMMIT%'
                    OR UPPER(A.NAME) LIKE '%EXEC%' ) ) X
 ORDER BY X.DV1 DESC 
;
