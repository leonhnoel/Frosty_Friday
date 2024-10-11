-- Frosty Friday Challenge 2

-- Create external stage
CREATE OR REPLACE STAGE frosty2stage
URL = 's3://frostyfridaychallenges/challenge_2/';

-- Create file_format
CREATE FILE FORMAT frosty2ff
    TYPE = PARQUET;

-- Create table with infer_schema. This way I do not have to define the structure of the table (column names, data types etc) as this will be inferred from files in the external stage
CREATE OR REPLACE TABLE frosty2table
    USING TEMPLATE (
        SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
            FROM TABLE(
                INFER_SCHEMA(
                    LOCATION=>'@frosty2stage',
                    FILE_FORMAT=>'frosty2ff',
                    IGNORE_CASE=> TRUE
                )
            )
    );

-- Check structure of newly created table
DESCRIBE TABLE frosty2table;

-- Check the filename to be copied into the new table
LIST @frosty2stage;

-- Copy the data into the table. Use MATCH_BY_COLUMN_NAME to load into separate columns.
COPY INTO frosty2table
    FROM @frosty2stage
    FILES = ('employees.parquet')
    FILE_FORMAT = frosty2ff
    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

-- In order to only see changes made to the columns dept and job_title I created a view with only these columns in it, plus the employee_id. 
CREATE OR REPLACE VIEW frosty2view (
    employee_id, 
    dept, 
    job_title
    )
AS 
SELECT 
    employee_id, 
    dept, 
    job_title 
FROM 
    frosty2table;

-- Then create the stream to keep an eye on the newly created view
CREATE OR REPLACE STREAM frosty2stream ON VIEW frosty2view;

-- Do the requested updates
UPDATE frosty2table SET COUNTRY = 'Japan' WHERE EMPLOYEE_ID = 8;
UPDATE frosty2table SET LAST_NAME = 'Forester' WHERE EMPLOYEE_ID = 22;
UPDATE frosty2table SET DEPT = 'Marketing' WHERE EMPLOYEE_ID = 25;
UPDATE frosty2table SET TITLE = 'Ms' WHERE EMPLOYEE_ID = 32;
UPDATE frosty2table SET JOB_TITLE = 'Senior Financial Analyst' WHERE EMPLOYEE_ID = 68;

-- Query the stream to see if displays the correct updates
SELECT * FROM frosty2stream;