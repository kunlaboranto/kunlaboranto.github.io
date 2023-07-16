CREATE OR REPLACE FUNCTION SF_BITAND_NAEWON_IL
(
  V_BIT_A VARCHAR(4000)
, V_BIT_B VARCHAR(4000)
)
RETURN NUMBER           -- 0: NOT FOUND, N(POS): MATCHED POSITION
AS 
    V_EPOS  NUMBER;
BEGIN
    V_EPOS := LEAST( LENGTHB(V_BIT_A), LENGTHB(V_BIT_B) );

    FOR POS IN 1 .. V_EPOS
    LOOP
        IF ( 1=1
            AND SUBSTRB( V_BIT_A, POS, 1 ) != '0'
            AND SUBSTRB( V_BIT_B, POS, 1 ) != '0'
            --AND SUBSTRB( V_BIT_A, POS, 1 ) = SUBSTRB( V_BIT_B, POS, 1 )
        )
        THEN
            RETURN POS;
        ELSE
            NULL;
            --DBMS_OUTPUT.PUT_LINE('>> ' || POS);
            --PRINTLN('>> ' || POS);
        END IF;
    END LOOP;

   RETURN 0;    -- 0: NOT FOUND

EXCEPTION
   WHEN OTHERS THEN
   RAISE;
   RETURN -1;   -- -1: ERROR
END;
/
