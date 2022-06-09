###############################
# BRAZIL SMALL AREA INCIDENCE #
# BYM2 Spatial Model ##########
###############################
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

cov_in <- as.matrix(read.csv("input_data/cov_in.csv"))
cov_ft <- as.matrix(read.csv("input_data/cov_ft.csv"))
data <- read.csv("input_data/all_data.csv")
load("input_data/nbs_scaling.RData")

data.list <- list(
  N_obs        = nrow(data), # number of observations in input data
  N_cov_in     = ncol(cov_in), # number of regression covariates for incidence
  N_cov_ft     = ncol(cov_ft), # number of regression covariates for fraction treated
  y_notif      = data$cases, # vector of TB cases, by location 
  y_all_mort   = data$sim_death, # vector of TB deaths, by location
  x_id         = as.numeric(as.factor(data$ID)), # vector location ids, indexed from 1 
  pop_100k     = data$pop_100k, # vector of population estimates, by location
  idc          = as.numeric(data$pct_idc), # percent of total deaths with poorly defined cause
  p_cov        = as.numeric(data$k50), # coverage estimates by state
  pri_mort_t   = data$frac_mort, # treatment cfr: pr(mort | notif)
  pri_aban_t   = data$frac_aban, # pr(loss to follow-up | notif)
  cov_in       = cov_in, # incidence covariates (N_obs by N_cov_in matrix)
  cov_ft       = cov_ft, # fraction treated covariates (N_obs by N_cov_ft matrix)
  scale_factor = scaling_factor, # BYM2 scaling factor
  N_edges      = nbs$N_edges, # number of edges
  index_i      = nbs$node1,  # to index from 1 instead of zero
  index_j      = nbs$node2  # to index from 1 instead of zero
)

fit_stan <- stan(file       = "Spatial_model.stan",
                 data       = data.list,
                 fit 	    = NA,
		 seed       = 1152, 
                 chains     = 4, 
                 iter       = 6000, 
                 warmup     = 5500,
                 thin       = 2,
                 cores      = 4,
                 control    = list(adapt_delta=.9,max_treedepth = 12))
 
