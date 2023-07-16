CREATE OR REPLACE PROCEDURE US_GDMON.SHOWPROCBODY
(
  P1 IN VARCHAR(40)
, P2 IN VARCHAR(40) DEFAULT NULL
)
AS

CURSOR C1 IS
SELECT PARSE
  FROM SYSTEM_.SYS_PROC_PARSE_
 WHERE PROC_OID =
       (SELECT P.PROC_OID
          FROM SYSTEM_.SYS_PROCEDURES_ P
               INNER JOIN SYSTEM_.SYS_USERS_ U
                       ON U.USER_ID = P.USER_ID
                      AND U.USER_NAME LIKE NVL2(P2,'%'||P2||'%','%OWN')
         WHERE P.PROC_NAME = UPPER(P1)
         LIMIT 1
       )
 ORDER BY SYSTEM_.SYS_PROC_PARSE_.SEQ_NO
;

V1          VARCHAR(32000);
V_LOOPCNT   INTEGER;
BEGIN
    OPEN C1;

    FETCH C1 INTO V1;
    --IF SQL%NOTFOUND THEN      -- BUGBUG ?
    IF V1 IS NULL THEN
        V_LOOPCNT := 0;
        --SYSTEM_.PRINTLN('-- OKT_01');
        NULL;
    ELSE
        V_LOOPCNT := 1;
        --SYSTEM_.PRINTLN('-- OKT_02');
        SYSTEM_.PRINTLN('---------------------------------');
        SYSTEM_.PRINTLN('-- PROCEDURE: '||P1);
        SYSTEM_.PRINTLN('---------------------------------');
        SYSTEM_.PRINTLN('');

        LOOP
            SYSTEM_.PRINT(V1);
            FETCH C1 INTO V1;
            EXIT WHEN C1%NOTFOUND;
            V_LOOPCNT := V_LOOPCNT + 1 ;
        END LOOP;

    END IF;

    CLOSE C1;

    IF V_LOOPCNT != 0 THEN
        --SYSTEM_.PRINTLN('-- OKT_03');
        SYSTEM_.PRINTLN('');
        SYSTEM_.PRINTLN('/');
        SYSTEM_.PRINTLN('---------------------------------');
    END IF;
END;
/

--CREATE PUBLIC SYNONYM SHOWPROCBODY FOR US_GDMON.SHOWPROCBODY ;
GRANT EXECUTE ON US_GDMON.SHOWPROCBODY TO PUBLIC;
