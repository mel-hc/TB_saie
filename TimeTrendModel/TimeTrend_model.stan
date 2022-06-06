data {
int<lower=1>    N_obs;            // Number of observations (rows of data)
int<lower=1>    N_geog;           // Number of geographical units
int<lower=1>    N_time;           // Number of time points
int             x_state[N_obs];   // Vector of geography IDs (indexed from 1)
int             x_year[N_obs];    // Vector of time points (indexed from 1)
int             y_notif[N_obs];   // Vector of notification counts 
int             y_all_mort[N_obs];// Vector of TB death counts 
vector[N_obs]   pop_100k;         // population in 100Ks
vector[N_obs]   p_cov;            // completeness of death register
vector[N_obs]   idc;              // ill/poorly defined cause (fraction of all deaths) 
vector[N_obs]   mort_treat;       // deaths on treatment
vector[N_obs]   aban_treat;       // treatment abandonment
vector[N_obs]   unknown;          // unknown treatment outcomes
vector[N_obs]   fhs;              // FHS teams per 4000 pop, truncated (std)
vector[N_obs]   ln_gdp;           // ln_gdp per capita in 1000s of $R, 2015 (std)
}
/////////////////////////////////////////////////

parameters {

real                        b_inc_00; 
vector[N_geog]              b_inc_i0;  
matrix[N_geog, N_time-1 ]   b_inc_ij; 
real                        b_inc_gdp;
real                        b_inc_fhs; 
real<lower=0>               sigma_inc_i;  
real<lower=0>               sigma_inc_ij; 

real                        b_pn_00; 
vector[N_geog]              b_pn_i0;  
matrix[N_geog, N_time-1 ]   b_pn_ij;
real                        b_pn_fhs; 
real                        b_pn_gdp;
real<lower=0>               sigma_pn_i;
real<lower=0>               sigma_pn_ij;

real                        b_adj_00; 
real                        b_adj_0j; 
vector[N_geog]              b_adj_i0;  
real                        b_adj_3;
real                        y;
real                        z;
real<lower=0>               sigma_adj_i;

real<lower=0, upper=1>      p_surv_no_notif;
real<lower=0, upper=1>      p_mort_abandon;
}
/////////////////////////////////////////////////

transformed parameters {

vector[N_obs]               inc; // incidence 
matrix[N_geog, N_time]      b_inc_tmp; // a temporary container  
matrix[N_geog, N_time]      b_inc;
real                        b_inc_i0_mean; // for the mean   
vector[N_geog]              b_inc_ij_mean; // for the mean 

vector[N_obs]               pn; // probability of notification/fraction treated
matrix[N_geog, N_time]      b_pn_tmp; // a temporary container  
matrix[N_geog, N_time]      b_pn;
real                        b_pn_i0_mean; // for the mean   
vector[N_geog]              b_pn_ij_mean; // for the mean. 

vector[N_obs]               death_adj; 
vector[N_geog]              state_adj; 
vector[N_time]              time_adj; 
real                        mean_adj; 
real<lower=0, upper=1>      a; 
real<lower=0, upper=1>      b;
vector[N_obs]               m_deaths;
vector[N_obs]               p_mort_notif; 

//// INCIDENCE
for(i in 1:N_geog){ 
  b_inc_tmp[i,1] = 0.0; 
  for(j in 2:N_time){ 
     b_inc_tmp[i,j] = 
     b_inc_tmp[i,j-1] + b_inc_ij[i,j-1]; // random walk, started from zero
  } 
} 

b_inc_i0_mean = mean(b_inc_i0); // mean of the state random effects 
for(i in 1:N_geog){ 
  b_inc_ij_mean[i] = 
  mean(b_inc_tmp [i,]); // mean of the state-year random effects (by state)
} 

for(i in 1:N_geog){ 
  for(j in 1:N_time){ 
    b_inc[i,j] = b_inc_00 + b_inc_i0[i] - b_inc_i0_mean + b_inc_tmp[i,j] 
    - b_inc_ij_mean[i]; 
  } 
} 

for(i in 1:N_obs){
inc[i] = exp(b_inc[ x_state[i], x_year[i] ] + b_inc_fhs*fhs[i] 
+ b_inc_gdp*ln_gdp[i]);  
}

//// PR NOTIF
for(i in 1:N_geog){ 
  b_pn_tmp[i,1] = 0.0; 
  for(j in 2:N_time){ 
     b_pn_tmp[i,j] = b_pn_tmp[i,j-1] + b_pn_ij[i,j-1]; // random walk
  }
}

b_pn_i0_mean = mean(b_pn_i0); // mean of the state random effects 
for(i in 1:N_geog){ 
  b_pn_ij_mean[i] = 
  mean(row(b_pn_tmp, i)); // mean of the state-year random effects (by state)
}
for(i in 1:N_geog){ 
  for(j in 1:N_time){ 
    b_pn[i,j] = b_pn_00 + b_pn_i0[i] - b_pn_i0_mean + b_pn_tmp[i,j] 
    - b_pn_ij_mean[i]; 
  }
} 

for(i in 1:N_obs){
pn[i]       = inv_logit((b_pn[ x_state[i], x_year[i] ]) + b_pn_fhs*fhs[i] 
+ b_pn_gdp*ln_gdp[i]); 
}

//// DEATH ADJUSTMENT
for(i in 1:N_time){
  time_adj[i] = b_adj_0j*(x_year[i] - 10); // we asked experts about final year 
  // in time series, intercept is for year 10. 
}
for(i in 1:N_geog){
  state_adj[i] = b_adj_00 + b_adj_i0[i]; 
}
mean_adj = b_adj_00 + mean(b_adj_i0);
// Survey: If the fraction of deaths with poorly defined cuases is 'y', then we expect
// 'a' fraction of TB deaths to be missing from the recrod: 
a   = inv_logit(mean_adj + b_adj_3*y); 
b   = inv_logit(mean_adj + b_adj_3*z); 

for(i in 1:N_obs){
    death_adj[i] = inv_logit(state_adj[ x_state[i] ] + 
    time_adj[ x_year[i] ] + b_adj_3*idc[i]);  
}

//// PR DEATH GIVEN NOTIF
for(i in 1:N_obs){
  p_mort_notif[i] = (mort_treat[i] + p_mort_abandon*aban_treat[i]) 
  / (y_notif[i] - unknown[i]); 
} 

// MODELED DEATHS
for(i in 1:N_obs){
m_deaths[i] = pop_100k[i] * inc[i] * ((pn[i] * p_mort_notif[i]) + ((1-pn[i]) 
* (1-p_surv_no_notif))); 
}

}

/////////////////////////////////////////////////
model {

to_vector(b_inc_ij)     ~ normal(0, sigma_inc_ij);  
b_inc_00                ~ normal(0, 10); 
b_inc_i0                ~ normal(0, sigma_inc_i); 
b_inc_gdp               ~ normal(0, 10);
b_inc_fhs               ~ normal(0, 10); 
sigma_inc_i             ~ cauchy(0, 10); //  
sigma_inc_ij            ~ cauchy(0, 10); //

to_vector(b_pn_ij)      ~ normal(0, sigma_pn_ij);  
b_pn_00                 ~ normal(0, 10); 
b_pn_i0                 ~ normal(0, sigma_pn_i); 
b_pn_fhs                ~ normal(0, 10); 
b_pn_gdp                ~ normal(0, 10);
sigma_pn_i              ~ cauchy(0, 10);  
sigma_pn_ij             ~ cauchy(0, 10);  

b_adj_00                ~ normal(0, 1); 
b_adj_i0                ~ normal(0, sigma_adj_i);
sigma_adj_i             ~ cauchy(0, 10);  
b_adj_0j                ~ normal(0, 0.05); 
b_adj_3                 ~ normal(0, 1); 
y                       ~ normal(0.01, .001); // asked in expert survey
z                       ~ normal(0.15, .001); // asked in expert survey
a                       ~ beta(52.9737, 451.15377); // from expert survey 
b                       ~ beta(97.82789, 285.81089); // from expert survey

p_surv_no_notif         ~ beta(25.65, 33.32); // from expert survey
p_mort_abandon          ~ beta(4.287894, 81.469979); // expert opinion

//// LIKELIHOODS
for(i in 1:N_obs){
 y_notif[i]      ~ poisson(pop_100k[i] * inc[i] * pn[i]); 
}

for(i in 1:N_obs){
y_all_mort[i]   ~ poisson(m_deaths[i] * p_cov[i] * (1-death_adj[i]));
  }
}

generated quantities{
// Generate key outcomes here  
  
vector[N_obs]       missed_cases;
vector[N_obs]       cases;

for(i in 1:N_obs){
  cases[i] = inc[i] * pop_100k[i];
  }
  
for(i in 1:N_obs){ 
    missed_cases[i] = inc[i] * pop_100k[i] * (1 - pn[i]);
}

  
}

