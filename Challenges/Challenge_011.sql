-- Set the database and schema
use database ff;
use schema ff.public;

-- Create file_format

create or replace file format ff_file_format_csv
    TYPE = 'CSV'
    SKIP_HEADER = 1;

-- Create the stage that points at the data.
create stage ff11_stage
    URL = 's3://frostyfridaychallenges/challenge_11/'
    FILE_FORMAT = ff_file_format_csv;

-- Create the table as a CTAS statement.
create or replace table ff.public.wk11 as
select m.$1 as milking_datetime,
        m.$2 as cow_number,
        m.$3 as fat_percentage,
        m.$4 as farm_code,
        m.$5 as centrifuge_start_time,
        m.$6 as centrifuge_end_time,
        m.$7 as centrifuge_kwph,
        m.$8 as centrifuge_electricity_used,
        m.$9 as centrifuge_processing_time,
        m.$10 as task_used
from @ff11_stage (
    FILE_FORMAT => 'ff_file_format_csv'
    ,PATTERN => '.*milk_data.*[.]csv') m;

SELECT * FROM ff.public.wk11;

-- TASK 1: Remove all the centrifuge dates and centrifuge kwph and replace them with NULLs WHERE fat = 3. 
-- Add note to task_used.
create or replace task whole_milk_updates
    schedule = '1400 minutes'
as
    UPDATE wk11
    SET 
        centrifuge_start_time = NULL
        ,centrifuge_end_time = NULL
        ,centrifuge_kwph = NULL
        ,task_used = SYSTEM$CURRENT_USER_TASK_NAME() || 'at' || current_timestamp
    WHERE fat_percentage = 3;

-- TASK 2: Calculate centrifuge processing time (difference between start and end time) WHERE fat != 3. 
-- Add note to task_used.
create or replace task skim_milk_updates
    after ff.public.whole_milk_updates
as
    UPDATE wk11
    SET 
        centrifuge_electricity_used = DATEDIFF(minute, centrifuge_start_time, centrifuge_end_time)
        ,task_used = SYSTEM$CURRENT_USER_TASK_NAME() || 'at' || current_timestamp
    WHERE fat_percentage != 3;  

-- Resume second task (otherwise it will not be triggered in the second step)

alter task skim_milk_updates
resume;

-- Manually execute the task.

execute task whole_milk_updates;

-- Check that the data looks as it should.
select * from wk11;

-- Check that the numbers are correct.
select task_used, count(*) as row_count 
from wk11 
group by task_used;
