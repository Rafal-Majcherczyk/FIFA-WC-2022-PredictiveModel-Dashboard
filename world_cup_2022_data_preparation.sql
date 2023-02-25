USE world_cup_2022;

-------------------------------------------------------------
---- DATA CLEANING
-------------------------------------------------------------

---- ACTION 1
-- Changes applied to table names/columns for convinience purposes
-- A) each column name composed of more than two words was connected
-- using underscore sign during the process of data loading (import wizard)
-- e.g. 'Home Team' -> 'Home_Team', 'FIFA Ranking' -> 'FIFA_Ranking' and so on
-- plus one more change applied - 'Runners-Up' -> 'Runners_Up'

-- B) Some of the table names changes in the following fashion
-- (2022_table_name -> table_name_2022)
EXEC sp_rename '2022_world_cup_groups','world_cup_groups_2022';
EXEC sp_rename '2022_world_cup_matches','world_cup_matches_2022';
EXEC sp_rename '2022_world_cup_squads','world_cup_squads_2022';

-- C) One more column name changed to avoid potential confusion
-- when refering to column using keyword as a name ('Group')
EXEC sp_rename 'world_cup_groups_2022.Group','WC_group','COLUMN'; 

-- ACTION 2
-- Error identified in the world_cup_matches table. Record associated
-- with ID = 75 shows Uruguay as a Host Team whereas in fact
-- it was Brazil that hosted World Cup in 1950
-- Correction has been perfomed.

SELECT * FROM world_cup_matches
WHERE ID = 75;

-- change applied to testing table

SELECT * 
INTO #world_cup_matches_testing_table
FROM world_cup_matches;

UPDATE #world_cup_matches_testing_table
SET 
	Home_Team = 'Brazil',
	Home_Goals = 1,
	Away_Goals = 2,
	Away_Team = 'Uruguay'
WHERE ID = 75;

SELECT * FROM #world_cup_matches_testing_table
WHERE ID = 75;

-- changed applied to the source table
UPDATE world_cup_matches
SET 
	Home_Team = 'Brazil',
	Home_Goals = 1,
	Away_Goals = 2,
	Away_Team = 'Uruguay'
WHERE ID = 75;

-- QA check 1
SELECT * FROM world_cup_matches
WHERE ID = 75;
-- QA check 2
-- Correct: more than one country hosted World Cup Finals only in 2002

SELECT Year, Home_Team FROM world_cup_matches
WHERE Host_Team = 1
GROUP BY Year, Home_Team;

-- ACTION 3
-- 'South Korea' naming is used across all of the tables except for
-- world_cups where 'Korea Republic' naming is utilized. The latter
-- will be updated to be consistent with the rest of the tables


SELECT Fourth FROM world_cups
WHERE Year = '2002';

-- changed applied to testing table

SELECT *
INTO #world_cups_testing_table
FROM world_cups;

SELECT *
FROM #world_cups_testing_table

UPDATE #world_cups_testing_table
SET Fourth = 'South Korea'
WHERE Year = '2002';

-- changed applied to the source update

UPDATE world_cups
SET Fourth = 'South Korea'
WHERE Year = '2002';

-- QA

SELECT Fourth FROM world_cups
WHERE Year = '2002';



-- ACTION 4
-- 'United States' naming is used across all of the tables except for
-- world_cups where 'USA' naming is utilized. The latter
-- will be updated to be consistent with the rest of the tables

SELECT * FROM world_cups
WHERE 
	Host_Country LIKE '%usa%'
	OR
	Winner LIKE '%usa%'
	OR
	Runners_Up LIKE '%usa%'
	OR
	Third LIKE '%usa%'
	OR
	Fourth LIKE '%usa%';

-- updating testing table

SELECT * 
INTO #world_cups_testing_table_2
FROM world_cups

SELECT * FROM #world_cups_testing_table_2
WHERE 
	Host_Country LIKE '%usa%' OR Third LIKE '%usa%';

SELECT Third FROM #world_cups_testing_table_2
WHERE Year = '1930';

SELECT Host_Country FROM #world_cups_testing_table_2
WHERE Year = '1994';

UPDATE #world_cups_testing_table_2
SET Third = 'United States'
WHERE Year = '1930';

UPDATE #world_cups_testing_table_2
SET Host_Country = 'United States'
WHERE Year = '1994';

SELECT * FROM #world_cups_testing_table_2
WHERE Year IN ('1930','1994');

-- updating source table

UPDATE world_cups
SET Third = 'United States'
WHERE Year = '1930';

UPDATE world_cups
SET Host_Country = 'United States'
WHERE Year = '1994';

-- QA
SELECT * FROM world_cups
WHERE Year IN ('1930','1994');


------ TABLES DESIGNATED FOR FINAL PRODUCT (DASHBOARD IN TABLEAU)


-------------------------------------------------------------
---- TABLE 1: Table combining international matches with world
-- cup matches (friendly matches, tournaments of all sorts as
-- well as world cup matches gathered in one place as they are
-- originally separated into two tables) with additional column
-- populated

-- CHARACTERISTICS:
	--1) Winner column - additional column providing information 
	--about the winner of each match (column will be populated with either 
	--the name of the national team that won the match or 
	--information that the match ended up as a draw). 

	--NOTE: In case of matches in a home-and-away system that ended
	--as a draw (after two matches) information about tie-breaker
	--solution (like penalties) and winner is recorded in the Win_Conditions 
	--column in the record concerning the 2nd of the two matches)
	--NEW column does NOT take into consideration penalties which took 
	--place as a conclusion of a scenario described above (two matches 
	--conducted in the home-and-away system where team1 hosts the first match 
	--and team2 the second one final result is a draw -team1 scored the same number of goals
	--as team2 throughout 2 matches) UNLESS both matches ended as draws. 
	--Also, penalties ARE taken into account when it was an individual match 
	--that ended as a draw and tie-breaker was necessary

	-- LOGIC: we have two types of matches
	-- in our table that can end with a draw. 1) individual matches that
	-- required penalties to establish who advances further 
	-- (for instance playoffs in World Cup Finals) or
	-- 2) matches played in a home-and-away system where we have
	-- home team and away team and then hosting conditions are reversed.
	-- In case of the latter we might have a draw after two matches
	-- and then penalties to determine which team goes further. Let's
	-- consider the following example -  Team A won 1st match,
	-- Team B won 2nd match and in consequence of a draw penalties
	-- determined that Team A advances. 2nd match will be recorded
	-- as lost for Team B even though they actually won that match in a 
	-- regular time. In that case Team A is recorded as a winner
	-- in 1st and 2nd match which doesn't seem to fairly represent
	-- the rivalry. Especially as in the case of reversed situation 
	-- (Team B wins first match, loses second match and eventually 
	-- loses in penalties) both teams would be recorded as winners in one match 
	-- and losers in another one (Team B won 1st match and Team A won the 2nd one
	-- and then penalties). If penalties are not taken into account
	-- in such a scenario then results recorded in our database
	-- are symetrical regardless of the order of the matches that 
	-- took place. IMPORTANT: in case of matches in the home-and-away
	-- system that ended with two draws penalties will be taken into
	-- consideration (change in order of the matches does not impact
	-- final results - draw and win for one team as well as draw and
	-- lose for the second team)
	-- I arbitrally made a decision that the methodology described above
	-- will be more appropriate for results presented in final dashboard
 -------------------------------------------------------------

-- STEP 1: Combining two tables (international_matches and 
-- world_cup_matches)
	-- a) updating ID columns to distinguish between tables (both)
	-- tables are using the same key)
	-- b) preparing tables for unification 

-- international_matches table preparation
SELECT 
	'IN'+ CONVERT(VARCHAR(10),ID) AS ID,
	Tournament,
	Date,
	NULL AS Stage,
	Home_Team,
	Home_Goals,
	Away_Goals,
	Away_Team,
	Win_Conditions,
	Home_Stadium
FROM international_matches;
-- world_cup matches table preparation
SELECT 
	'WC'+ CONVERT(VARCHAR(10),ID) AS ID,
	'FIFA World Cup Finals' AS Tournament,
	Date,
	Stage,
	Home_Team,
	Home_Goals,
	Away_Goals,
	Away_Team,
	Win_Conditions,
	Host_Team AS Home_Stadium
FROM world_cup_matches;
-- unification of tables
SELECT *
INTO #all_matches
FROM
	(SELECT 
		'IN'+ CONVERT(VARCHAR(10),ID) AS ID,
		Tournament,
		Date,
		NULL AS Stage,
		Home_Team,
		Home_Goals,
		Away_Goals,
		Away_Team,
		Win_Conditions,
		Home_Stadium
	FROM international_matches) inter
UNION ALL 
SELECT *
FROM
	(SELECT 
		'WC'+ CONVERT(VARCHAR(10),ID) AS ID,
		'FIFA World Cup Finals' AS Tournament,
		Date,
		Stage,
		Home_Team,
		Home_Goals,
		Away_Goals,
		Away_Team,
		Win_Conditions,
		Host_Team AS Home_Stadium
	FROM world_cup_matches)	wc;

SELECT * FROM #all_matches;

-- QA check
SELECT 
	COUNT(*) AS inter_matches_row_count,
	(SELECT COUNT(*) FROM world_cup_matches) AS wc_matches_row_count,
	COUNT(*) + (SELECT COUNT(*) FROM world_cup_matches) AS inter_wc_row_count_total,
	(SELECT COUNT(*) FROM #all_matches) AS unified_table_row_count
FROM international_matches;

-- STEP 2: addition of new column that provides explicit
-- information about the result of a match with treatment of penalties
-- as described earlier

-- STEP 2A: Data exploration
-- Win_Conditions - possible options

WITH CTE_win_cond_check AS
(
	SELECT 
		CASE
			WHEN Win_Conditions LIKE '%win on penalties%' THEN 'win on penalties'
			ELSE Win_Conditions
		END Win_Conditions_upd
	FROM #all_matches
	WHERE Win_Conditions is NOT NULL)
SELECT * FROM CTE_win_cond_check 
GROUP BY Win_Conditions_upd;

-- matches that were resolved either in Extra time or through
-- Golden goal rule

SELECT * FROM #all_matches
WHERE Win_Conditions IN ('Extra time', 'Golden goal');

-- Conclusion: only world_cup_matches table specifies which
-- games ended in Extra time or through Golden goal rule.
-- it does NOT affect our further analysis (there are no
-- matches in the home-and-away system which could be
-- affected by extra conditions)

-- STEP 2B: new column which extracts the name of the team
-- that won match through penalties from Win_Conditions column
-- (we take advantage of consistency in format where name of the
-- team that won in penalties is provided at the beginning of string)

SELECT 
	*,
	CASE
		WHEN Win_Conditions LIKE '%win on penalties%' THEN SUBSTRING(Win_Conditions,1,CHARINDEX(' win',Win_conditions)-1)
	END Winner
FROM #all_matches
WHERE Win_Conditions IS NOT NULL;

-- QA check to ensure that country names retrieved from 
-- Win_Conditions column equals those from Home_Team/Away_Team
-- columns (we want country naming to be consistent)

WITH CTE_QA AS
(
	SELECT 
		*,
		CASE
			WHEN Win_Conditions LIKE '%win on penalties%' THEN SUBSTRING(Win_Conditions,1,CHARINDEX(' win',Win_conditions)-1)
		END Winner,
		CASE
			WHEN Win_Conditions IN ('Extra time', 'Golden goal') THEN 'Extra time or golden goal'
			WHEN Home_Team = SUBSTRING(Win_Conditions,1,CHARINDEX(' win',Win_conditions)-1) THEN 'Equals Home Team'
			WHEN Away_Team = SUBSTRING(Win_Conditions,1,CHARINDEX(' win',Win_conditions)-1) THEN 'Equals Away Team'
			ELSE 'Error'
		END QA_field
	FROM world_cup_matches
	WHERE Win_Conditions IS NOT NULL)
SELECT QA_field FROM CTE_QA
GROUP BY QA_field;

-- Conclusion: team names retrieved from Win_conditions column
-- are consistent with those utilized in columns Home Team/Away Team

-- STEP 2C - addition of new column containing information
-- about match result (either name of the winner or information
-- that match ended as a draw) covering instances in which
-- match was concluded before penalties as well as the ones
-- where penalties decided the match 

SELECT 
	*,
	CASE
		WHEN Home_Goals > Away_Goals THEN Home_Team
		WHEN Home_Goals < Away_Goals THEN Away_Team
		WHEN Home_Goals = Away_Goals AND Win_Conditions LIKE '%win on penalties%' THEN SUBSTRING(Win_Conditions,1,CHARINDEX(' win',Win_conditions)-1)
		WHEN Home_Goals = Away_Goals THEN 'Draw'
		ELSE 'Error'
	END Winner
INTO #all_matches_w_winner_col_w_penalties_v1
FROM #all_matches;

SELECT * FROM #all_matches_w_winner_col_w_penalties_v1;


-- QA check

SELECT * FROM #all_matches_w_winner_col_w_penalties_v1
WHERE Winner LIKE '%Error%' OR Winner is NULL;

-- QA check 2

WITH CTE_QA AS
(SELECT
	CASE
		WHEN Home_Goals > Away_Goals AND Home_Team = Winner THEN 'CORRECT'
		WHEN Home_Goals < Away_Goals AND Away_Team = Winner THEN 'CORRECT'
		WHEN Home_Goals = Away_Goals AND Win_Conditions LIKE '%penalties%'  AND Winner IS NOT NULL AND Winner <> 'Draw' THEN 'CORRECT'
		WHEN Home_Goals = Away_Goals AND (Win_Conditions IS NULL OR Win_Conditions NOT LIKE '%penalties%') AND Winner = 'Draw' THEN 'CORRECT'
		ELSE 'ERROR!'
	END QA_field
FROM #all_matches_w_winner_col_w_penalties_v1)
SELECT * FROM CTE_QA 
WHERE QA_field <> 'CORRECT';


-- TABLE 1 (FINAL VERSION)
SELECT * FROM #all_matches_w_winner_col_w_penalties_v1
ORDER BY Date;

-------------------------------------------------------------
---- TABLE 2: Table containing information about the stage of
-- tournament that each national team reached in World Cup Finals
-- that they qualified for.

-- CHARACTERISTICS:
	-- Stage numerized - additional column quantifying the stage that
	-- was reached by the teams for dashboard purposes
	-- METHODOLOGY: stages will be associated with numbers
	-- indicating how far each team managed to advance 
	-- The following format will be used:
	-- phase where between 17 and 32 teams played will be quantified as 1,
	-- phase where between 9 and 16 teams played will be quantified as 2,
	-- phase where between 5 and 8 teams played will be quantified as 3,
	-- fourth and third place will be quantified as 4,
	-- and second as well as first place will be quantified as 5
-------------------------------------------------------------


-- STEP 1: retrieval of information about the date of the last game
-- that each participant played during each World Cup Finals

-- STEP 1A: retrieval of above information for teams populated
-- in home team column

SELECT *
FROM
	(SELECT Year, Home_Team, MAX(Date) Last_Match 
	FROM world_cup_matches
	GROUP BY Year, Home_Team) home;

-- STEP 1B: retrieval of above information for teams populated
-- in away team column

SELECT * 
FROM
	(SELECT Year, Away_Team, MAX(Date) Last_Match 
	FROM world_cup_matches
	GROUP BY Year, Away_Team) away;

-- STEP 1C: unification of tables and retrieval of the date of
-- the last match

WITH CTE_wc_last_match_date_by_team AS
(
	SELECT *
	FROM
		(SELECT Year, Home_Team AS Team, MAX(Date) Last_Match 
		FROM world_cup_matches
		GROUP BY Year, Home_Team) home
	UNION 
	SELECT * 
	FROM
		(SELECT Year, Away_Team AS Team, MAX(Date) Last_Match 
		FROM world_cup_matches
		GROUP BY Year, Away_Team) away)
SELECT Year, Team, MAX(Last_Match) Last_Match 
INTO #wc_teams_last_match_dates
FROM CTE_wc_last_match_date_by_team
GROUP BY Year, Team
ORDER BY Year, Team;

SELECT * FROM #wc_teams_last_match_dates;

-- STEP 2: addition of column containing information about
-- the stage of World Cup Finals associated with the team 
-- and the date (final stage that team managed to reach)

SELECT tmp.Year, tmp.Team, tmp.Last_Match, wcm.Stage
INTO #wc_teams_last_match_dates_w_stages
FROM #wc_teams_last_match_dates tmp
LEFT JOIN world_cup_matches wcm 
	ON tmp.Last_Match = wcm.Date
	AND (tmp.Team = wcm.Home_Team OR tmp.Team = wcm.Away_Team);

SELECT * FROM #wc_teams_last_match_dates_w_stages;

-- STEP 3: adding additional details about the exact places 
-- that finalists achieved (world_cup_matches table specifies only
-- which teams played for either 1st or 3rd place and does
-- not provide the final result of these matches)

SELECT 
	tmp.Year AS Yr, 
	tmp.Team, 
	tmp.Last_Match,
	tmp.Stage,
	CASE
		WHEN tmp.Stage = 'Final' THEN 
			(CASE
				WHEN tmp.Team = wcs.Winner THEN 'Champions'
				WHEN tmp.Team = wcs.Runners_Up THEN 'Runners-up'
				ELSE 'Error'
			END)
		WHEN tmp.Stage = 'Third place' THEN 
			(CASE
				WHEN tmp.Team = wcs.Third THEN 'Third place'
				WHEN tmp.Team = wcs.Fourth THEN 'Fourth place'
				ELSE 'Error'
			END)
		ELSE tmp.Stage
	END Stage_updated,
	wcs.*
INTO #wc_teams_last_match_dates_w_stages_updated
FROM #wc_teams_last_match_dates_w_stages tmp
JOIN world_cups wcs 
	ON tmp.Year = wcs.Year;

SELECT * FROM #wc_teams_last_match_dates_w_stages_updated;

-- QA check (reviewing records where Stage column does NOT equal
-- Stage_updated column)

WITH CTE_QA_check AS
(
	SELECT
		CASE
			WHEN Stage = Stage_updated THEN 'CORRECT'
			ELSE 'DOUBLE CHECK'
		END QA_field,
		*
	FROM
		#wc_teams_last_match_dates_w_stages_updated base)
SELECT 
	*
INTO #QA_check_stage_updated
FROM CTE_QA_check
WHERE QA_field <> 'CORRECT';

SELECT * FROM #QA_check_stage_updated;

-- Troubleshooting (errors identified)

SELECT * FROM #QA_check_stage_updated
WHERE Stage_updated 
	NOT IN ('Champions','Runners-up', 'Third place', 'Fourth place');
	

-- CONCLUSION: Germany, Russia, and South Korea are named
-- differently in some of the records in world_cups table
-- A) Germany FR refers to Federal Republic of Germany which
-- alongside Germany DR existed between circa 1949 and 1990
-- B) Another naming discrepancy is Soviet Union and Russia used
-- interchangeably. 
-- C) Last error stems from the fact that 
-- Korea Republic is an official name for South Korea so
-- error is just a consequence of using different
-- naming conventions

-- SOLUTION: Both Germany and Russia will be treated as succesors
-- of Germany FR/Germany DR and Soviet Union respectively
-- and exceptions will be included in the query accordingly (in case
-- of future analysis concerning Germany FR/DR or Soviet Union themselves
-- original records will not be updated) 
-- However, 'Korea Republic' entry will be replaced with 
-- 'South Korea' to be consistent with the rest of the tables
-- (only world_cups table uses 'Korea Republic' naming)
-- NOTE: script updating records related to 'Korea Republic' is
-- available in the data cleaning section

-- Implementation of solution outlined above (with regards to
-- Germany and Russia)

DROP TABLE IF EXISTS #wc_teams_last_match_dates_w_stages_updated;
SELECT 
	tmp.Year AS Yr, 
	tmp.Team, 
	tmp.Last_Match,
	tmp.Stage,
	CASE
		WHEN tmp.Stage = 'Final' THEN 
			(CASE
				WHEN tmp.Team = wcs.Winner THEN 'Champions'
				WHEN tmp.Team = wcs.Runners_Up THEN 'Runners-up'
				WHEN tmp.Team = 'Germany' AND wcs.Winner = 'Germany FR' THEN 'Champions'
				WHEN tmp.Team = 'Germany' AND wcs.Runners_Up = 'Germany FR' THEN 'Runners-up'
				WHEN tmp.Team = 'Russia' AND wcs.Winner = 'Soviet Union' THEN 'Champions'
				WHEN tmp.Team = 'Russia' AND wcs.Runners_Up = 'Soviet Union' THEN 'Runners-up'
				ELSE 'Error'
			END)
		WHEN tmp.Stage = 'Third place' THEN 
			(CASE
				WHEN tmp.Team = wcs.Third THEN 'Third place'
				WHEN tmp.Team = wcs.Fourth THEN 'Fourth place'
				WHEN tmp.Team = 'Germany' AND wcs.Third = 'Germany FR' THEN 'Third place'
				WHEN tmp.Team = 'Germany' AND wcs.Fourth = 'Germany FR' THEN 'Fourth place'
				WHEN tmp.Team = 'Russia' AND wcs.Third = 'Soviet Union' THEN 'Third place'
				WHEN tmp.Team = 'Russia' AND wcs.Fourth = 'Soviet Union' THEN 'Fourth place'
				ELSE 'Error'
			END)
		ELSE tmp.Stage
	END Stage_updated,
	wcs.*
INTO #wc_teams_last_match_dates_w_stages_updated
FROM #wc_teams_last_match_dates_w_stages tmp
JOIN world_cups wcs ON tmp.Year = wcs.Year;

SELECT * FROM #wc_teams_last_match_dates_w_stages_updated;

-- QA check

SELECT * FROM #wc_teams_last_match_dates_w_stages_updated
WHERE Stage_updated LIKE '%Error%';


-- QA check 2 - additional check to determine if our table does
-- contain information about all of the finalists (winner, runner-up, 
-- third, fourth) for each World Cup Finals

WITH CTE_QA AS
(
	SELECT
		Year, 
		CASE
			WHEN Stage_updated = 'Champions' THEN 1000 
			WHEN Stage_updated = 'Runners-up' THEN 100
			WHEN Stage_updated = 'Third place' THEN 10
			WHEN Stage_updated = 'Fourth place' THEN 1 
			ELSE 0
		END QA_field
	FROM #wc_teams_last_match_dates_w_stages_updated)
SELECT Year, SUM(QA_field) Finalists FROM CTE_QA
GROUP BY Year;

SELECT * FROM #wc_teams_last_match_dates_w_stages_updated
WHERE Year IN ('1930', '1950');

-- Conclusions: 
-- A) issue with regards to the naming discrepancies resolved
-- B) new issue identified - finalists are not specified for 1950
	-- World Cup Finals in world_cup_matches table
	-- (tournament format differed from previous
	-- and next championships and involved group matches called 
	-- First round and Final round played in round-robin format 
	-- NO official matches for third place and first place) 
	-- appropriate correction involving this exception will be applied
-- C) In 1930 no match for third place was organized 
	-- and in consequence last match recorded for United States 
	-- and Yugoslavia is semi-final (officially match for 
	-- third place was introduced in 1934, however some records suggest 
	-- that game actually took place). Nevertheless, based on goal differences
	-- it was USA who was officially awarded third place by FIFA later 
	-- appropriate correction involving this exception will be performed
-- D) 'USA' naming used in world_cups table whereas all other tables
	-- use 'United States' naming convention. Source table to be updated
	-- (appropriate script performed in data cleaning section)

-- STEP 4: Table containing information about each team that
-- took part in World Cup Finals along with the stage that they
-- reached (correction involving 1930 and 1950 World Cup Finals
-- has been applied)

DROP TABLE IF EXISTS #wc_teams_stage_reached;
SELECT 
	tmp.Year AS Yr, 
	tmp.Team, 
	tmp.Last_Match,
	CASE
		WHEN tmp.Stage = 'Final' THEN 
			(CASE
				WHEN tmp.Team = wcs.Winner THEN 'Champions'
				WHEN tmp.Team = wcs.Runners_Up THEN 'Runners-up'
				WHEN tmp.Team = 'Germany' AND wcs.Winner = 'Germany FR' THEN 'Champions'
				WHEN tmp.Team = 'Germany' AND wcs.Runners_Up = 'Germany FR' THEN 'Runners-up'
				WHEN tmp.Team = 'Russia' AND wcs.Winner = 'Soviet Union' THEN 'Champions'
				WHEN tmp.Team = 'Russia' AND wcs.Runners_Up = 'Soviet Union' THEN 'Runners-up'
				ELSE 'Error'
			END)
		WHEN tmp.Stage = 'Third place' THEN 
			(CASE
				WHEN tmp.Team = wcs.Third THEN 'Third place'
				WHEN tmp.Team = wcs.Fourth THEN 'Fourth place'
				WHEN tmp.Team = 'Germany' AND wcs.Third = 'Germany FR' THEN 'Third place'
				WHEN tmp.Team = 'Germany' AND wcs.Fourth = 'Germany FR' THEN 'Fourth place'
				WHEN tmp.Team = 'Russia' AND wcs.Third = 'Soviet Union' THEN 'Third place'
				WHEN tmp.Team = 'Russia' AND wcs.Fourth = 'Soviet Union' THEN 'Fourth place'
				ELSE 'Error'
			END)
		WHEN tmp.Stage IN ('Final round', 'Semi-finals') THEN
			(CASE
				WHEN tmp.Team = wcs.Third THEN 'Third place'
				WHEN tmp.Team = wcs.Fourth THEN 'Fourth place'
				WHEN tmp.Team = wcs.Winner THEN 'Champions'
				WHEN tmp.Team = wcs.Runners_Up THEN 'Runners-up'
			END)
		ELSE tmp.Stage
	END Stage_reached,
	wcs.Qualified_Teams
INTO #wc_teams_stage_reached
FROM #wc_teams_last_match_dates_w_stages tmp
JOIN world_cups wcs ON tmp.Year = wcs.Year;

SELECT * FROM #wc_teams_stage_reached;

-- QA (we check one more time if our corrections resolved the
-- problem with World Cup Finals in 1930 and 1950)

WITH CTE_QA AS
(
	SELECT
		Yr, 
		CASE
			WHEN Stage_reached = 'Champions' THEN 1000 
			WHEN Stage_reached = 'Runners-up' THEN 100
			WHEN Stage_reached = 'Third place' THEN 10
			WHEN Stage_reached = 'Fourth place' THEN 1 
			ELSE 0
		END QA_field
	FROM #wc_teams_stage_reached)
SELECT Yr, SUM(QA_field) Finalists FROM CTE_QA
GROUP BY Yr;

-- FINAL TABLE
-- STEP 5: stage numerization - all teams that participated in World
-- Cup Finals along with information about the stage they reached
-- as well as numerical representation of that stage for Tableau purposes
-- (as clarified earlier)
-- NOTE: Stage_num column will be derived from
-- information about the type of stage that teams reached
-- as well as the number of teams that qualified to World Cup Finals
-- (accordingly to the methodology described earlier)

DROP TABLE IF EXISTS #wc_teams_stage_reached_w_stage_numerized;
SELECT 
	Yr,
	Team,
	Last_Match,
	Stage_reached,
	CASE
		WHEN Stage_reached IN ('Group stage', 'First group stage') AND (Qualified_Teams BETWEEN 17 AND 32) THEN 1
		WHEN (Stage_reached IN ('Round of 16', 'First round')) OR (Stage_reached IN ('Group stage', 'First group stage') AND Qualified_Teams <= 16) OR (Stage_reached = 'Second group stage' AND Qualified_Teams BETWEEN 17 AND 32)  THEN 2
		WHEN Stage_reached = 'Quarter-finals' OR (Stage_reached = 'Second group stage' AND Qualified_Teams <= 16) THEN 3
		WHEN Stage_reached IN ('Third place', 'Fourth place') THEN 4
		WHEN Stage_reached IN ('Champions', 'Runners-up') THEN 5
		ELSE -100
	END Stage_num
INTO #wc_teams_stage_reached_w_stage_numerized
FROM #wc_teams_stage_reached;

SELECT * FROM #wc_teams_stage_reached_w_stage_numerized;

-- QA CHECK

SELECT * FROM #wc_teams_stage_reached_w_stage_numerized
WHERE (Stage_num NOT BETWEEN 1 AND 5) OR Stage_num is NULL ;


