###############################
# BRAZIL SMALL AREA INCIDENCE #
# Time Series Model ###########
###############################
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

library(readxl)
m_state <- read.csv("state_data.csv")

#Model Inputs
datalist <- list()
datalist[["N_obs"]]       <-  nrow(m_state)
datalist[["N_geog"]]      <-  length(unique(m_state$sg_uf)) 
datalist[["N_time"]]      <-  length(unique(m_state$YEAR)) 
datalist[["y_notif"]]     <-  as.numeric(m_state$cases)   
datalist[["y_all_mort"]]  <-  m_state$sim_death
datalist[["x_year"]]      <-  as.numeric(as.factor(m_state$YEAR))
datalist[["x_state"]]     <-  as.numeric(as.factor(m_state$sg_uf))
datalist[["pop_100k"]]    <-  m_state$pop_100k
datalist[["fhs"]]         <-  as.numeric(m_state$fhs_sc) # FHS coverage (teams per 4000 pop); values > 1 truncated
datalist[["ln_gdp"]]      <-  as.numeric(m_state$gdp_sc) # gdp per capita in 1000s of $R, 2015
datalist[["idc"]]         <-  as.numeric(m_state$pct_idc) # percent of total deaths with poorly defined cause
datalist[["p_cov"]]       <-  as.numeric(m_state$k50) #as.numeric(coverage_uf$k50) # coverage estimates by state
datalist[["mort_treat"]]  <-  as.numeric(m_state$sinan_death) # deaths on treatment
datalist[["aban_treat"]]  <-  as.numeric(m_state$abandon) # loss to follow-up
datalist[["unknown"]]     <-  as.numeric(m_state$other) # unknown outcomes

# Model Run
start <- Sys.time()
fit_stan <-  stan(file    = "TimeTrend_model.stan",
                   data    = datalist,
                   seed    = 123, 
                   chains  = 4, 
                   iter    = 4000, # total iterations
                   warmup  = 3000, # burn-in 
                   verbose = FALSE,
                   control = list(adapt_delta=.9,max_treedepth = 14))   
stop <- Sys.time()

#############################
