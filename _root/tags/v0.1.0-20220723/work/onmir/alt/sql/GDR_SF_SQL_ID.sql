CREATE OR REPLACE FUNCTION US_GDMON.GDR_SF_SQL_ID( INPUT_STRING IN VARCHAR(32000) )
RETURN VARCHAR(40)
AS
    V_INSTR VARCHAR(32000);
    V_OUTSTR VARCHAR(32000);
    V_KEYSTR VARCHAR(32000);
BEGIN

    IF INPUT_STRING IS NULL THEN
        RETURN 0;
    END IF;

    V_INSTR := LOWER( DIGEST( TRIM( INPUT_STRING ), 'SHA-1' ) );

    V_KEYSTR := '0123456789abcdfghjkmnpqrstuvwxyz' ;
    V_KEYSTR := V_KEYSTR || '+-*/()'    ;
    V_KEYSTR := V_KEYSTR || '%|<>=_.,'  ;
    V_KEYSTR := V_KEYSTR || '[]:;'      ;
    V_KEYSTR := V_KEYSTR || CHR(20)     ;   -- space
    V_KEYSTR := V_KEYSTR || CHR(9)      ;   -- tab
    V_KEYSTR := V_KEYSTR || CHR(39)     ;   -- '
    V_KEYSTR := V_KEYSTR || CHR(34)     ;   -- "

    SELECT  TRUNC(
                MOD(
                    SUM(
                        --(INSTR('0123456789abcdfghjkmnpqrstuvwxyz', SUBSTR( V_INSTR, LEVEL, 1) )-1) * POWER(32, LENGTHB( V_INSTR ) - LEVEL)
                        MOD(
                            (INSTR( V_KEYSTR, SUBSTR( V_INSTR, LEVEL, 1) )-0) * POWER(32, LENGTHB( V_INSTR ) - LEVEL)
                            , POWER(2,32) )
                    )
                    , POWER(2,32)
                )
            ) HASH_VALUE
            INTO V_OUTSTR
    FROM    DUAL
    CONNECT BY LEVEL <= LENGTHB( V_INSTR )
    ;

    RETURN V_OUTSTR;
END;
/
