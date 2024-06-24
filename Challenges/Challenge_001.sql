-- Step 1: create file_format
-- First create file_format that I will add to the stage that will be created in the next step.
-- I've taken a look at the data in Step 

CREATE OR REPLACE FILE FORMAT ff_challenge_01
    TYPE = CSV
    field_delimiter = NONE
    record_delimiter = '\n'
    NULL_IF = ('NULL', 'totally_empty')
    SKIP_HEADER = 1;

-- Step 2: create stage
-- Now I can create the stage and add the file format created in the previous step as the standard file format
    
CREATE OR REPLACE STAGE s_challenge_01 
	URL = 's3://frostyfridaychallenges/challenge_1/' 
	DIRECTORY = ( ENABLE = TRUE )
    FILE_FORMAT = ff_challenge_01;

-- Step 3: investigate data
-- This where I've queries the data thats present in the stage.
-- By querying the metadata filename and row_number I found out that theres a hidden message in the files.
-- When ordered by filename and row_number the message reads: you have gotten it right congratulations!
    
SELECT 
    $1
    ,METADATA$FILENAME
    ,METADATA$FILE_ROW_NUMBER 
FROM 
    @s_challenge_01 
ORDER BY 
    METADATA$FILENAME
    ,METADATA$FILE_ROW_NUMBER;

-- Step 4: create the table
-- Time to create the table to hold the data
    
CREATE OR REPLACE TABLE t_challenge_01 (
    column1 VARCHAR
);

-- Step 5: copy data
-- Now I can copy the data into the table. The FILES = (...) step isnt necessary, but this way I can force the order of loading.

COPY INTO t_challenge_01
FROM @s_challenge_01
FILES = ('1.csv', '2.csv', '3.csv');

-- Step 6: Check the data
-- Since the order was forced the message is displayed in the right order.

SELECT * 
FROM 
    t_challenge_01 
WHERE 
    column1 IS NOT NULL;

