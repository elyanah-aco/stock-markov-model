# Markov Chain Model for Stock Trends
MATH 102.1 (Operations Research) project. Contains R code for Markov models to predict stock trends, as inspired by a similar analysis by Huang and Lu (2016, doi: 10.1080/03610926.2017.1300281) for Taiwan Stock Exchange Capitalization Weighted Stock Index (TAIEX) Futures.

## Background
In the Markov model, each trading day can fall under one of eight possible states:
| State  | Price between two days ago and yesterday | Price between yesterday and today | Volume between yesterday and today | 
| ------ | --------------- | ----------- | ---------------------------------- |
| 1 | Increased | Increased | Incresed  | 
| 2 | Increased | Increased | Decreased |
| 3 | Decreased | Increased | Increased |
| 4 | Decreased | Increased | Decreased |
| 5 | Increased | Decreased | Increased |
| 6 | Increased | Decreased | Decreased |
| 7 | Decreased | Decreased | Increased | 
| 8 | Decreased | Decreased | Increased | 

By obtaining the transition matrix, it is possible to determine the steady-state probabilities that a trading day falls under each state.

Short-term investors may also be interested to know how many days it usually takes before the stock price starts falling for two consecutive days, so that they can sell before this occurs. By setting States 7 and 8 as absorbing states, it is also possible to determine (a) how many days on average it takes until the stock price falls for two consecutive days for each non-absorbing state, and (b) the probability that volume either increases or decreases when the stock price falls two days in a row for each non-absorbing state.

## Prerequisites
Run the following code to download the libraries used in the repo.
```
install.packages('glue') 
install.packages('dplyr')
install.packages('janitor')
install.packages('quantmod')
```
## Upcoming revisions
Future versions will contain an RShiny version of the analysis.
