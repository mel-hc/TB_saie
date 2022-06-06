///INPUTS//
//////////
data {
int<lower=1>  N_obs;            // Number of observations (rows of data)
int<lower=0>  N_cov_in;         // Number of regression covariates, incidence
int<lower=0>  N_cov_ft;         // Number of regression covariates, frac. treat.

int           y_notif[N_obs];   // Vector of notification counts by location
int           y_all_mort[N_obs];// Vector of death counts by location
int           x_id[N_obs];      // municipality or state ID (as intergers)

vector[N_obs] pop_100k;         // population by location, in 100Ks 
vector[N_obs] p_cov;            // mortality system coverage estimate
vector[N_obs] idc;              // fraction of deaths with "ill defined causes"
vector[N_obs] pri_mort_t;       // frac. of treatment death by location
vector[N_obs] pri_aban_t;       // frac. of treatment abandonment by location

// covariates

matrix[N_obs, N_cov_in]  cov_in;   // covariate matrix for incidence 
matrix[N_obs, N_cov_ft]  cov_ft;   // covariate matrix for frac. treat
 
// spatial 
real<lower=0>             scale_factor;     // 's' scaling factor

int<lower=0>              N_edges;          // number of neighbors (edges)
int<lower=1, upper=N_obs> index_i[N_edges]; // neighbors (nodes)
int<lower=1, upper=N_obs> index_j[N_edges]; // neighbors (nodes)
}

///PARAMETERS//
//////////////
parameters {
// terms to estimate incidence(in) and fraction treated(ft)  
vector[N_obs]          theta_in; // non-spatial effects
vector[N_obs]          theta_ft;

vector[N_obs]          phi_in; // spatial effects
vector[N_obs]          phi_ft;

real<lower=0>          sigma_in; // standard deviation for incidence
real<lower=0>          sigma_ft; // standard deviation for fract. treat
real<lower=0>          sigma_d; // standard deviation for death adj

real<lower=0, upper=1> rho_in; // fraction of variation attrib. spatial effects
real<lower=0, upper=1> rho_ft;

real                   beta_inc_0; // intercept for incidence regression 
real                   beta_ft_0; // intercept for frac. treated regression 
vector[N_cov_in]       betas_cov_inc; // incidence regression coeffecients
vector[N_cov_ft]       betas_cov_ft; // frac. treated regression coeffecients
 
 // terms for death adjustment
real                   beta_0; // intercept
real                   beta_1; // regression coeffecient for idx
vector[N_obs]          theta_d; // random effects

// terms to estimate probability of death given notification
vector<lower=0,upper=1>[N_obs]  mort_treat; // pr outcome is death
real<lower=0,upper=1>           p_mort_mort; // pr death if outcome is death
vector<lower=0,upper=1>[N_obs]  aban_treat;  // pr outcome is loss to follow-up
real<lower=0,upper=1>           p_mort_abandon; // pr death if outcome is LTF

real<lower=0,upper=1>  p_surv_no_notif; // pr survival with out notification 
}

///TRANSFORMED PARAMETERS//
//////////////////////////
transformed parameters {
vector[N_obs]           beta_in; // spatial and random effects
vector[N_obs]           beta_ft;

vector[N_obs]           inc; // incidence 
vector[N_obs]           ft; // fraction treated 
vector[N_obs]           p_mort_notif; // probability a death is notified

vector[N_obs]           death_adj; // death adjustment
real<lower=0, upper=1>  a; // rate miss classified TB w/ 1% IDC
real<lower=0, upper=1>  b; // rate miss classified TB w/ 15% IDC

vector[N_obs]           m_deaths; // deaths

/// SPATIAL/RANDOM EFFECTS
// Variance of each component should be approximately equal to 1
beta_in  =  sqrt(1 - rho_in) * theta_in + sqrt(rho_in / scale_factor) * phi_in;
beta_ft  =  sqrt(1 - rho_ft) * theta_ft + sqrt(rho_ft / scale_factor) * phi_ft;

/// INCIDENCE
inc = exp(beta_inc_0 + beta_in*sigma_in + cov_in*betas_cov_inc);  

/// FRACTION TREATED
ft = inv_logit(beta_ft_0 + beta_ft*sigma_ft + cov_ft*betas_cov_ft); 

/// DEATH UNDERREPORTING ADJUSTMENT 
death_adj = inv_logit(beta_0 + idc*beta_1 + theta_d*sigma_d); 

a     = inv_logit(beta_0 + beta_1*0.01 + mean(theta_d*sigma_d));
b     = inv_logit(beta_0 + beta_1*0.15 + mean(theta_d*sigma_d));

/// DEATHS AFTER NOTIFICATION
p_mort_notif = p_mort_mort*mort_treat + p_mort_abandon*aban_treat;

/// MODELED DEATHS
for (i in 1:N_obs){
  m_deaths[i] = pop_100k[i] * inc[i] * ( (ft[i] * p_mort_notif[i]) + 
  ((1-ft[i]) * (1 - p_surv_no_notif)) );
  }
  
}

///MODEL//
//////////
model {
// Prior on theta is (0,n) where n is number of subragphs 
theta_in                ~ normal(0, 1); 
theta_ft                ~ normal(0, 1); 

rho_in                  ~ beta(1.5, 1.5); // weakly informative
rho_ft                  ~ beta(1.5, 1.5); // weakly informative

sigma_in                ~ cauchy(0, 2);
sigma_ft                ~ cauchy(0, 2);

// pairwise difference formulation 
target += -0.5 * dot_self(phi_in[index_i] - phi_in[index_j]);  
target += -0.5 * dot_self(phi_ft[index_i] - phi_ft[index_j]);  
// soft sum-to-zero constraint on phi
mean(phi_in)            ~ normal(0,0.001);
mean(phi_ft)            ~ normal(0,0.001);

beta_inc_0              ~ normal(0, 10); 
beta_ft_0               ~ normal(0, 10); 

betas_cov_inc           ~ normal(0, 10);
betas_cov_ft            ~ normal(0, 10);

mort_treat              ~ beta(10*pri_mort_t, 10*(1-pri_mort_t));
p_mort_mort		          ~ beta(28.4, 11.6); 
aban_treat              ~ beta(10*pri_aban_t, 10*(1-pri_aban_t)); 
p_mort_abandon          ~ beta(2.14, 40.7);  
p_surv_no_notif         ~ normal(0.3, 0.001); // based on expert opinion

beta_0                  ~ normal(0, 1);
beta_1                  ~ normal(0, 1);
theta_d                 ~ normal(0, 1);
sigma_d                 ~ cauchy(0, 2);  

a                       ~ beta(52.97, 451.15); // from expert opinion 
b                       ~ beta(97.83, 285.81); // from expert opinion

/// LIKELIHOODS
for(i in 1:N_obs){
y_notif[i]      ~ poisson(pop_100k[i] * inc[i] * ft[i]); 
 }
 
for(i in 1:N_obs){
y_all_mort[i]  ~ poisson(m_deaths[i] * p_cov[i] * (1 - death_adj[i]));
 }
}
