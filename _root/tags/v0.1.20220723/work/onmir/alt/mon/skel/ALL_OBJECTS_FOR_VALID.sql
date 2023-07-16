-- (2) 생성구문
DROP TABLE US_GDMON.ALL_OBJECTS_FOR_VALID ;
CREATE TABLE US_GDMON.ALL_OBJECTS_FOR_VALID -- AS SELECT SYSDATE DT, A.* FROM ALL_OBJECTS A;
(
  DT DATE DEFAULT SYSDATE
, OWNER                                    VARCHAR(40) 
, OBJECT_NAME                              VARCHAR(40) 
, OBJECT_TYPE                              VARCHAR(28) 
, STATUS                                   VARCHAR(11) 
, CREATED                                  DATE        
, LAST_DDL_TIME                            DATE        
, JUSEOK                                   VARCHAR(250)
)
;
CREATE INDEX US_GDMON.IX_ALL_OBJECTS_FOR_VALID_NI01 ON US_GDMON.ALL_OBJECTS_FOR_VALID ( OWNER, OBJECT_NAME, OBJECT_TYPE );

-- (1) 갱신구문 - [주의] 위 쿼리의 문제는 'INVALID' 상태 현행화를 위해서 아래 데이타를 매번 갱신해줘야 한다는 점.
TRUNCATE TABLE US_GDMON.ALL_OBJECTS_FOR_VALID ;
INSERT INTO US_GDMON.ALL_OBJECTS_FOR_VALID SELECT SYSDATE DT, A.* FROM ALL_OBJECTS A;

COMMIT;
