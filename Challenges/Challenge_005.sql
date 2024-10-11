CREATE DATABASE FF;

CREATE OR REPLACE TABLE ff_week_5 (
    start_int NUMBER(38, 0)
);

INSERT INTO FF_week_5
    SELECT UNIFORM(1, 50, RANDOM())
    FROM TABLE(GENERATOR(ROWCOUNT => 15));

CREATE OR REPLACE FUNCTION timesthree(i int) 
    RETURNS int 
    LANGUAGE PYTHON 
    RUNTIME_VERSION = '3.8' 
    HANDLER = 'timesthree' 
AS 
$$ 
def timesthree(i):
    return i*3
$$;

SELECT
    start_int
    ,timesthree(start_int) AS timesthree
FROM
    ff_week_5;