# TB Small Area Incidence Estimation
This repository contains code and data to recreate the findings from two manuscripts related to small aread TB burden estimation in Brazil: 

Chitwood MH, Pelissari DM, Drummond Marques da Silva G, Bartholomay P, Rocha MS, Sanchez M, Arakaki-Sanchez D, Glaziou P, Cohen T, Castro MC, Menzies NA. Bayesian evidence synthesis to estimate subnational TB incidence: An application in Brazil. Epidemics. 2021 Jun;35:100443. doi: 10.1016/j.epidem.2021.100443. Epub 2021 Feb 20. PMID: 33676092; PMCID: PMC8252152.

Chitwood MH, Alves LC, Bartholomay P, Couto RM, Sanchez M, Castro MC, Cohen T, Menzies NA. A spatial-mechanistic model to estimate subnational tuberculosis burden with routinely collected data: an application in Brazilian municipalities. *Under Review*.

# The Models

Both models produce estimates of TB incidence and fraction of cases treated by geographical area in Brazil using a mechanistic model of TB natural history. The models are implement in the rstan, a package for implementing Bayesian models in R. 

The file #TimeTrendModel# contains input data and R code to run a stan model. This model produces a 10-year time series of estimates at the state level. 

The file #SpatialModel# input data and R code to run a stan model. This model produces estimates at a single timepoint at the municipal level.
