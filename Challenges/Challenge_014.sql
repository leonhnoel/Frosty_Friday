-- set context
USE DATABASE FF;
USE SCHEMA FF.PUBLIC;

-- create table for raw data
CREATE OR REPLACE TABLE wk_14 (
    superhero_name varchar(50),
    country_of_residence varchar(50),
    notable_exploits varchar(150),
    superpower varchar(100),
    second_superpower varchar(100),
    third_superpower varchar(100)
);

-- insert values
INSERT INTO wk_14 VALUES 
    ('Superpig', 'Ireland', 'Saved head of Irish Farmer\'s Association from terrorist cell', 'Super-Oinks', NULL, NULL)
    ,('Señor Mediocre', 'Mexico', 'Defeated corrupt convention of fruit lobbyists by telling anecdote that lasted 33 hours, with 16 tangents that lead to 17 resignations from the board', 'Public speaking', 'Stamp collecting', 'Laser vision')
    ,('The CLAW', 'USA', 'Horrifically violent duel to the death with mass murdering super villain accidentally created art installation last valued at $14,450,000 by Sotheby\'s', 'Back scratching', 'Extendable arms', NULL) 
    ,('Il Segreto', 'Italy', NULL, NULL, NULL, NULL)
    ,('Frosty Man', 'UK', 'Rescued a delegation of data engineers from a DevOps conference', 'Knows, by memory, 15 definitions of an obscure codex known as "the data mesh"', 'can copy and paste from StackOverflow with the blink of an eye', NULL);

-- check values
SELECT * FROM wk_14;

-- create table for JSON output
CREATE OR REPLACE TABLE wk_14_json AS
SELECT 
    to_json(
        object_construct(
            'country_of_residence', country_of_residence
            ,'superhero_name', superhero_name
            ,'superpowers', CASE WHEN array_size(array_construct_compact(superpower, second_superpower, third_superpower)) = 0
                                 THEN array_construct('undefined')
                                 ELSE array_construct_compact(superpower, second_superpower, third_superpower)
                            END
       )
    ) AS superhero_json
FROM wk_14;

-- check JSON table
SELECT * FROM wk_14_json; 

