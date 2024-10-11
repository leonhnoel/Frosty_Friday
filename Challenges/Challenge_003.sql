CREATE DATABASE ff3db;
CREATE OR REPLACE STAGE ff3stage 
URL = 's3://frostyfridaychallenges/challenge_3/'
FILE_FORMAT = (
    TYPE = 'CSV'
    ,SKIP_HEADER = 1 
    );

LIST @ff3stage;

-- I first misunderstood the challenge. 
-- I thought I had to query the stage to show the filenames that contains keywords in their name + number of rows in those files. 
-- Below is what I did to achieve that.

SELECT 
    METADATA$FILENAME
    ,MAX(METADATA$FILE_ROW_NUMBER) AS number_of_rows
FROM 
    @ff3stage
-- The WHERE statement is used to filter for filenames that contain keywords. 
-- A subquery is used to find the keywords. 
-- Then those are compared to the filenames with LIKE ANY. 
-- This way the query above only contains results from files that contain keyword.
WHERE 
    METADATA$FILENAME LIKE ANY ( 
        SELECT CONCAT('%',keywords,'%')                 
            FROM (                                      
                SELECT 
                    $1 AS keywords
                FROM 
                    @ff3stage/keywords.csv
                ))
GROUP BY
    METADATA$FILENAME
ORDER BY 
    number_of_rows;

-- I'll start over to actually fill a table with the data of the files containing the keywords in their name.
CREATE OR REPLACE DATABASE ff3db;
CREATE OR REPLACE STAGE ff3db.public.ff3stage 
    URL = 's3://frostyfridaychallenges/challenge_3/'
    FILE_FORMAT = (TYPE = 'CSV');

LIST @ff3stage;

-- First create a table that can contain desired data
-- I'll use infer_schema again like I did in ff2
-- In order to use that I need a file format first

CREATE OR REPLACE FILE FORMAT ff3_ff_csv
  TYPE = CSV
  PARSE_HEADER = true;

-- What were the files to infer schema from again?
SELECT DISTINCT 
    METADATA$FILENAME
FROM 
    @ff3stage
WHERE 
    METADATA$FILENAME LIKE ANY 
        (SELECT 
            CONCAT('%', $1, '%')
        FROM 
            @ff3stage/keywords.csv
        WHERE $1 != 'keyword'
    );
    

-- Create the table with infer_schema
CREATE OR REPLACE TABLE ff3table
    USING TEMPLATE (
        SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
        FROM TABLE(
            INFER_SCHEMA(
                LOCATION => '@ff3stage'
                ,FILE_FORMAT => 'ff3_ff_csv'
                ,FILES => 
                    'week3_data2_stacy_forgot_to_upload.csv'
            )
        )
    );

-- Do a simple COPY INTO that searches for filenames containing the keywords that were found as PATTERN
COPY INTO 
    ff3table
FROM 
    @ff3stage
PATTERN = '.*added.*|.*extra.*|.*stacy_forgot_to_upload.*';

-- Check result
SELECT * FROM ff3table;

