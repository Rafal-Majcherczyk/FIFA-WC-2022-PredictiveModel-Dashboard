# FIFA World Cup 2022: Predictive Model and Dashboard Data

## Table of Contents

* [Overview](https://github.com/Rafal-Majcherczyk/FIFA-WC-2022-PredictiveModel-Dashboard#overview)
* [Data Sources and Technology Used](https://github.com/Rafal-Majcherczyk/FIFA-WC-2022-PredictiveModel-Dashboard#data-sources-and-technology-used)
* [Data Preparation](https://github.com/Rafal-Majcherczyk/FIFA-WC-2022-PredictiveModel-Dashboard#data-preparation)
* [Description of Models](https://github.com/Rafal-Majcherczyk/FIFA-WC-2022-PredictiveModel-Dashboard#description-of-models)
* [Setup and Usage](https://github.com/Rafal-Majcherczyk/FIFA-WC-2022-PredictiveModel-Dashboard#setup-and-usage)
* [Demonstration](https://github.com/Rafal-Majcherczyk/FIFA-WC-2022-PredictiveModel-Dashboard#demonstration)
* [Methodology](https://github.com/Rafal-Majcherczyk/FIFA-WC-2022-PredictiveModel-Dashboard#methodology)
* [Summary (TLDR)](https://github.com/Rafal-Majcherczyk/FIFA-WC-2022-PredictiveModel-Dashboard#summary-tldr)
* [Blog posts](https://github.com/Rafal-Majcherczyk/FIFA-WC-2022-PredictiveModel-Dashboard#blog-posts)

<!-- add remaining items to the table of contents -->

## Overview

This repository contains a predictive model built in Python, which uses the Poisson distribution to predict the results of each match during the FIFA World Cup 2022 and determine the medalists. Additionally, a separate model has been prepared to provide detailed analysis of individual matches. The repository also includes SQL code, which processes the source data and returns two tables and Python script responsible for scraping the actual results of the World Cup 2022 tournament. The SQL output is used in conjunction with the scraped results for an associated project - the [FIFA World Cup 2022 Fan Dashboard](https://public.tableau.com/app/profile/rafa.7863/viz/FIFAWorldCup2022FanDashboard/WC_2022_dashboard), which has been prepared in Tableau.


| **Item**                        | **File**                              |
| --------------------------------| --------------------------------------|
| World Cup 2022 Predictive Model | world_cup_2022_predictive_model.ipynb |
| Match Predictive Model          | world_cup_2022_predictive_model.ipynb |
| Data Preparation in SQL         | world_cup_2022_data_preparation.sql   |
| Data Scraping and Transformation in Python | world_cup_2022_results.ipynb |

## Data Sources and Technology Used

Historical data for this project was obtained from Maven Analytics who published it as a part of their challenge ("source_data.zip" in the "input_data" folder), while the World Cup 2022 results were scraped from RSSSF's website. Credit to Maven Analytics, RSSSF, and Roberto Di Maggio for aggregating the information and permiting the free use of their data.

**Data source 1**: https://www.mavenanalytics.io/data-playground (dataset titled "World Cup")  

**Data source 2**: https://www.rsssf.org/tables/2022f.html  

**Technologies used**: Microsoft SQL Server Management Studio 18, Python 3.9  

**Python Packages**: numpy, pandas, requests, BeautifulSoup, re, fnmatch, datetime, scipy, matplotlib, and seaborn

## Data Preparation

1. **Data processing in SQL**

   The data from the source 1 was processed in SQL in order to obtain two data frames:
   1. all_matches_w_winner_col_w_penalties_v1.xls (TABLE 1)
   2. wc_teams_stage_reached_w_stage_numerized.xls (TABLE 2)

   * **TABLE 1**: Table combining international matches with world cup matches (friendly matches, tournaments of all sorts as well as world cup matches gathered in one place as they are originally separated into two tables) with additional column populated.

        >**CHARACTERISTICS:
        Winner column - additional column providing information about the winner of each match (column will be populated with either the name of the national team that won the match or information that the match ended up as a draw).**
    
        Table 1 was used as the input data for the models and charts 1 and 3 in the Tableau dashboard.

   * **TABLE 2**: Table containing information about the stage of tournament that each national team reached in World Cup Finals that they qualified for.

       > **CHARACTERISTICS:
        Stage numerized - additional column quantifying the stage that was reached by the teams for dashboard purposes. Stages will be associated with numbers indicating how far each team managed to advance. The following format will be used:**
        >* **phase where between 17 and 32 teams played will be quantified as 1,**
        >* **phase where between 9 and 16 teams played will be quantified as 2,**
        >* **phase where between 5 and 8 teams played will be quantified as 3,**
        >* **fourth and third place will be quantified as 4,**
        >* **and second as well as first place will be quantified as 5**

        Table 2 was specifically designed for the purpose of chart 2 in the Tableau dashboard.

1. **Web scraping and data transformation in Python**

   Summary of actions taken:
   * data scraped from the website
   * records regarding each match and corresponding penalties combined into single rows
   * transformation of records referring to the World Cup final to be consistent with the remainder of matches
   * irrelevant data filtered out and rest of the data prepared for subsequent data wrangling
   * transformation of dates and adoption of names for stages to be consistent with the convention used in the   rest of the project
   * retrieval of the name of the winner for each match
   * retrieval of information that will be used in the dashboard
   
   Data from the source 2 has been scraped and transformed using Python specifically for the purpose of chart 4 in the dashboard.

## Description of Models

1. **Match Predictive Model**

    In-depth analysis of a single match between selected national teams. Provides statistics, breakdown of potential results based on their probability along with visualization and winning chances for both teams.

    >**NOTE: besides teams you can choose how much data will be utilized for analysis (start_date_wc refers to World Cup Finals and start_date_inter to all other matches).**

1. **World Cup 2022 Predictive Model**

    Returns the most likely outcome of every single match during World Cup 2022 Finals based on historical data (medalists are determined).

    >**NOTE 1: You can choose how much data will be utilized for analysis (start_date_wc refers to World Cup Finals and start_date_inter to all other matches). Default settings are the following: 1) start date for World Cup Finals is set to 1998-01-01 what means that data from six consecutive tournaments that were organized before World Cup Finals from 2022 will be taken into account 2) start date for other international matches is set to 2016-11-20, so all matches that took place during six-year period preceding World Cup Finals in Qatar will be considered. This particular setup was used in my own simulation (results along with three more charts are to be found in my dashboard for football fans that I prepared in Tableau Public).** 
    
    >**NOTE 2: Appearances and results obtained during World Cup Finals indicate how well national teams perform during the most prestigious tournament and what their true capabilities are given that they have to face the best teams from all over the world (among other information). On the other hand, their performance in matches outside of World Cup Finals from the past few years is supposed to provide information about the current form of teams. However, you are encouraged to modify these dates to your liking and see how the change affects results of the simulation.**

## Setup and Usage

All data necessary for performing prediction was provided in the "predictive_model.rar" (input_data folder).

**Instructions:**
   1. Download "world_cup_2022_predictive_model.ipynb" and "predictive_model.rar" and extract data to the location of your preference.
   1. Open "world_cup_2022_predictive_model.ipynb" with editor of your liking (code was originally written in Jupyter Notebook).
   1. Update the "INPUT DATA" section with the current location of the input data
            
      | Data frame         | Filename                                     |
      | --------           | --------------                               |
      | all_matches        | all_matches_w_winner_col_w_penalties_v1.xls  |
      | match_schedule     | 2022_world_cup_matches.csv                   |
      | wc_groups          | 2022_world_cup_groups.csv                    |
   
      ```python
         # INPUT DATA
         all_matches = pd.read_excel(r'YOUR_LOCATION\all_matches_w_winner_col_w_penalties_v1.xls')
         match_schedule = pd.read_csv(r'YOUR_LOCATION\2022_world_cup_matches.csv')
         wc_groups = pd.read_csv(r'YOUR_LOCATION\2022_world_cup_groups.csv')
      ```
   
   1. Type a name of function that you would like to use
      * Match Predictive Model
      ```python
        match_prediction(Team1, Team2, start_date_inter, start_date_wc)
      ```
      * World Cup 2022 Predictive Model
      ```python
         world_cup_prediction(start_date_inter, start_date_wc)
      ```
      >Function parameters: 
         >* Team1, Team2 - teams whose match outcome you would like to predict, 
         >* start_date_wc - start date for World Cup Finals, if no date selected then default setting will be used (1998-01-01)
         >* start_date_inter - start date for other international matches, if no date selected then default setting will be used (2016-11-20) 

## Demonstration

Argentina vs Poland - probability distribution of scoring chances and potential results
![Argentina vs Poland](https://github.com/Rafal-Majcherczyk/FIFA-WC-2022-PredictiveModel-Dashboard/blob/main/assets/goals_prediction_large.png)

Fan Dashboard
![Fan Dashboard](https://github.com/Rafal-Majcherczyk/FIFA-WC-2022-PredictiveModel-Dashboard/blob/main/assets/WC_2022_dashboard_France.png)


## Methodology

1. **Data preparation in SQL**  
   Extensive comments provided in the sql file to help readers to follow along the code with understanding of its purpose. 

2. **Match Predictive Model**  
    Model compares `average numbers of goals scored/lost per match` for each team with `average results obtained by all of the teams in the relevant group` and uses that information to calculate `attack strength and defence strength values`. Then `attack strength` of one team is multiplied by the `defence strength` of their opponent as well as average number of goals scored during World Cup Finals in the selected data scope in order to derive the `number of expected goals` for that particular match. The reason why average number of goals scored during World Cup Finals is also used as a base for calculations of expected goals (and not some kind of a mixture of averages obtained from World Cup Finals and other international matches) is that the purpose of this model is to simulate matches that will take place/could take place specifically during World Cup Finals. Finally, `Poisson distribution` with the number of expected goals used as an expected value is utilized to calculate the probability of different results. For simplicity of calculations assumption is made that quantities of goals scored by each team are independent.  
    It is also important to note that statistics for World Cup matches and other international matches (friendly matches, UEFA Euro, World Cup qualification, and the rest of the tournaments) are calculated separately. Final attack/defense strength is obtained by taking the arithmetic average of both results. Moreover, indicators describing attack and defense capabilities of teams that have not participated in one or more of the World Cup Finals (from the selected scope of data) are negatively affected (logic: number of appearances in World Cup Finals is treated as a measure of how elite the team is so each failure to qualify will increase the severity of penalty).

3. **World Cup 2022 Predictive Model**  
    The same methodology as in the case of 'Match Predictive Model' is utilized. However, `in this model the most probable outcome of each match is used as a result for further simulation`. During the playoffs model does not take into account a draw as a potential result and instead returns the team with higher odds of winning as one would expect. In order to ensure that the model always returns relevant results, the following tiebreakers were implemented:
    1. If two teams or more in a group collected exactly the same number of points then the model would consider a direct match between each pair of these teams and would compare winning chances to establish which team should be placed higher in the group standings. Due to mathematical transitivity (Team1_win_prob > Team2_win_prob and Team2_win_prob > Team3_win_prob then Team1_win_prob > Team3_win_prob) this approach provides final and unambiguous result. In the future model might be extended to keep track of the most likely goal counts or expected goals for each match and use these metrics to determine the group standings but for now the solution outlined above is in use due to its simplicity, low likelihood of situation where two or more teams have the same number of points (mentioned transitivity and the fact that draws are rarely the most probable outcome of matches), and lastly because it provides good estimate of the standings without the necessity of implementing further tiebreakers. For example, if goal differences were used as a tiebreaker then we might end up in a situation where two or even more teams have exactly the same results which would require implementation of additional solutions (in fact, FIFA prepared a list composed of seven tiebreakers starting from goal differences and finishing with drawing of lots to resolve potential ties!).
    2. In case of a match between two teams in a group stage with no explicit favourite (odds of winning for neither of the teams are higher than odds of winning for their opponent as well as odds of a draw) model will return draw as an outcome.
    3. If the model compares the winning chances of two teams in a scenario where draws are not taken into account (e.g. playoffs) and these odds turn out to be equal (an extremely rare situation), then the FIFA ranking will be used as the final decider. For example, if England (ranked 5th in the FIFA ranking) were to play France (ranked 4th) in the quarter-finals and the winning chances of both teams were exactly the same, then France would advance further.

## Summary (TLDR)

* This repository contains a Python predictive model that uses the Poisson distribution to predict the results of each match in the FIFA World Cup 2022 and determine the medalists, as well as a separate model for detailed analysis of individual matches.
* SQL code is included to process the source data and return two tables, and a Python script is provided to scrape the actual results of the World Cup 2022 tournament, which are used in an associated project - the FIFA World Cup 2022 Fan Dashboard, prepared in Tableau.
* Historical data for the project was obtained from Maven Analytics and RSSSF, and Microsoft SQL Server Management Studio 18 and Python 3.9 were used for data processing.
* Python packages used include numpy, pandas, requests, BeautifulSoup, re, fnmatch, datetime, scipy, matplotlib, and seaborn.
* The data processing in SQL resulted in two tables, one combining international and world cup matches with an additional winner column and one containing information about the stage of the tournament each national team reached in World Cup Finals, numerized for dashboard purposes.
* The data scraping and transformation in Python involved combining match records and corresponding penalties into single rows, filtering out irrelevant data, transforming dates and adopting names for stages, and retrieving the name of the winner for each match.
* The Match Predictive Model provides statistics, breakdowns of potential results based on probability, visualizations, and winning chances for both teams in a single match, while the World Cup 2022 Predictive Model returns the most likely outcome of every single match during the tournament.


## Blog posts

The corresponding blog posts for this project can be found here:
* [FIFA World Cup 2022 Fan Dashboard](https://rafal-majcherczyk.github.io/post/project-1/)
* [FIFA World Cup 2022 Predictive Model](https://rafal-majcherczyk.github.io/post/project-2/)
