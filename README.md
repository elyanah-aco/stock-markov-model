# Markov Chain Model for Stock Trends
MATH 102.1 (Operations Research) project. Contains R code for Markov models to predict stock trends, as inspired by a similar analysis by Huang and Lu (2016, doi: 10.1080/03610926.2017.1300281) for Taiwan Stock Exchange Capitalization Weighted Stock Index (TAIEX) Futures.

## Background
In the Markov model, each trading day can fall under one of eight possible states:
| State  | Price yesterday |
| ------ | --------------- |
| 1 | Increased |
| 2 | Increased |


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
