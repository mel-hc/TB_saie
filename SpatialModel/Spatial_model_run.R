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
  N_obs        = nrow(data),
  N_cov_in     = ncol(cov_in),
  N_cov_ft     = ncol(cov_ft),
  y_notif      = data$cases,   
  y_all_mort   = data$sim_death,
  x_id         = as.numeric(as.factor(data$ID)),  
  pop_100k     = data$pop_100k,
  idc          = as.numeric(data$pct_idc), # percent of total deaths with poorly defined cause
  p_cov        = as.numeric(data$k50), # coverage estimates by state
  pri_mort_t   = data$frac_mort, #municipal$mort_treat # treatment cfr (pr(mort | notif))
  pri_aban_t   = data$frac_aban, # treatment cfr (pr(mort | notif))
  cov_in       = cov_in, # incidence covariates
  cov_ft       = cov_ft, # fraction treated covariates
  scale_factor = scaling_factor, 
  N_edges      = nbs$N_edges, # number of edges
  index_i      = nbs$node1,  # to index from 1 instead of zero
  index_j      = nbs$node2  # to index from 1 instead of zero
)

fit_stan <- stan(file       = "spatial_model.stan",
                 data       = data.list,
                 fit 	      = NA,
		             seed       = 1152, 
                 chains     = 4, 
                 iter       = 6000, 
                 warmup     = 5500,
                 thin       = 2,
                 cores      = 4,
                 control    = list(adapt_delta=.9,max_treedepth = 12))
 
