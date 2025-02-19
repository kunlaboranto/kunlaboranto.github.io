CREATE OR REPLACE FUNCTION SYS.SF_TABLE_CNT
(
  A_TABLE_NAME IN VARCHAR(60)
)
RETURN BIGINT
AS
    V_SQL VARCHAR(1024);
    V_CNT_TB BIGINT;
BEGIN

    -- # COUNT
    V_SQL := 'SELECT COUNT(*) FROM '||A_TABLE_NAME;
    EXECUTE IMMEDIATE V_SQL INTO V_CNT_TB;

    RETURN V_CNT_TB;

EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END;
/

GRANT EXECUTE ON SYS.SF_TABLE_CNT TO PUBLIC;
