##################
## Load libraries
##################
library(dplyr)
library(glue)
library(janitor)
library(quantmod)

#######################################################################
## Upload and clean data
#######################################################################
ticker <- 'QQQ'
start_date <- '2018-01-01'
end_date <- '2018-12-31'

## Load data
stock_data <- getSymbols(ticker, from = start_date, to = end_date, src = 'yahoo',
                         auto.assign = FALSE)

## Clean data
names(stock_data) <- gsub('.*?\\.', '', names(stock_data))
stock_data <- data.frame(date = index(stock_data), coredata(stock_data))
stock_data <- stock_data %>% 
  clean_names() %>%
  select(date, close, volume) %>%
  mutate(date = as.Date(date, '%Y-%m-%d')) %>%
  arrange(date) %>% 
  mutate(close_two_days_ago = lag(close, 2), close_yesterday = lag(close), volume_yesterday = lag(volume)) %>%
  relocate(close, .after = close_yesterday) %>% 
  relocate(volume, .after = volume_yesterday)

#####################################################
## Determine movement of prices/volumes
#####################################################
## 0 means that prices/volumes of more recent day is lower than previous day, 1 means higher
stock_data <- stock_data %>%
  mutate(p_yest = if_else(close_two_days_ago > close_yesterday, 0, 1),
         p_today = if_else(close_yesterday > close, 0, 1),
         v_today = if_else(volume_yesterday > volume, 0, 1))

######################
## Assign states
######################
stock_data <- stock_data %>% mutate(
  state_today = if_else(p_yest == 1 & p_today == 1 & v_today == 1, 'I',
                  if_else(p_yest == 1 & p_today == 1 & v_today == 0, 'II',
                          if_else(p_yest == 0 & p_today == 1 & v_today == 1, 'III',
                                  if_else(p_yest == 0 & p_today == 1 & v_today == 0, 'IV',
                                          if_else(p_yest == 1 & p_today == 0 & v_today == 1, 'V',
                                                  if_else(p_yest == 1 & p_today == 0 & v_today == 0, 'VI',
                                                          if_else(p_yest == 0 & p_today == 0 & v_today == 1, 'VII',
                                                                  'VIII'))))))),
  state_tomorrow = lead(state_today))

#############################################
## Create frequency and transition matrices
#############################################
freq_matrix <- table(stock_data$state_today, stock_data$state_tomorrow)

## Convert frequency table to transition matrix
trans_matrix <- matrix(, nrow = 8, ncol = 8)
for (i in 1:8){
  for (j in 1:8){
    rowsum <- sum(freq_matrix[i,1:8])
    trans_matrix[i,j] <- freq_matrix[i,j] / rowsum
  }
}


##########################################
## Determine steady state probabilities
##########################################
ss_coeff <- t(trans_matrix)
for (i in 1:8){
  ss_coeff[i,i] <- ss_coeff[i,i] - 1
}
ss_coeff <- ss_coeff[-2,] ## Remove a row (choice is arbitrary)
ss_coeff <- rbind(ss_coeff, rep(1,8)) ## Add new row for identity property
ss_sol <- c(rep(0,7),1)
ss_prob <- solve(ss_coeff, ss_sol)

## Print steady-state probabilities
for(i in 1:length(ss_prob)){
  print(glue('The steady state probability of State {i} is {round(ss_prob[i],2)}.'))
}
                  
###############################
## Create absorbing matrix
###############################
absorbing_matrix <- trans_matrix
absorbing_matrix[7,7] = 1
absorbing_matrix[8,8] = 1
absorbing_matrix[7,c(1:6,8)] = 0
absorbing_matrix[8,1:7] = 0

## Determine how many days before process is absorbed for each state
Q = absorbing_matrix[1:6,1:6]
S = absorbing_matrix[1:6,7:8]
period_absorb_matrix = solve(diag(6)-Q)

for(i in 1: nrow(period_absorb_matrix)){
  print(glue('It will take {round(sum(period_absorb_matrix[i,]),2)} days before prices fall two days in a row for State {i}.'))
}

## Determine probability that volume increases or decreases when absorbed
prob_absorb_matrix = period_absorb_matrix %*% S