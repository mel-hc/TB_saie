# TB Small Area Incidence Estimation
This repository contains code and data to recreate the findings from two manuscripts related to small area TB burden estimation in Brazil: 

  Chitwood MH, Pelissari DM, Drummond Marques da Silva G, Bartholomay P, Rocha MS, Sanchez M, Arakaki-Sanchez D, Glaziou P, Cohen T, Castro MC, Menzies NA. **Bayesian evidence synthesis to estimate subnational TB incidence: An application in Brazil.** Epidemics. 2021 Jun;35:100443. doi: 10.1016/j.epidem.2021.100443. Epub 2021 Feb 20. PMID: 33676092; PMCID: PMC8252152.

  Chitwood MH, Alves LC, Bartholomay P, Couto RM, Sanchez M, Castro MC, Cohen T, Menzies NA. **A spatial-mechanistic model to estimate subnational tuberculosis burden with routinely collected data: an application in Brazilian municipalities.** *Under Review*.

## The Models
Both models produce estimates of TB incidence and fraction of cases treated by geographical area in Brazil using a mechanistic model of TB natural history. The models are implemented in the rstan, a package for fitting Bayesian models in R. 

The folder **TimeTrend** contains a model that produces a 10-year time series of estimates. This model is intended to be run with state-level data. 

The folder **Spatial** contains a model that produces spatially-explicit estimates for a single timepoint. 

## The Folder Structure
The file **xx_input_data** contains data aggregated from various governmental sources in Brazil. TB case notification and treatment outcome data come from SINAN. Mortality data come from SIM. Demographic data come from IBGE. See citation list below. 

The file **xx_model_run.R** contains code to initiate a model run. Please note that running rstan is computationally intensive; model runs may take multiple hours.

The file **xx_model.stan** contains the code for the statistical model. 

## Additional Model Code
The stan code in "SpatialModel" was adapted from existing code: https://github.com/stan-dev/example-models/tree/885bd18e93fd4b7b19290d8967064174bbe45156/knitr/car-iar-poisson 

I do not include code to convert a neighbors matrix to the list of nodes and edges that rstan requires, nor do I include code to calculate the scaling factor; I made use of the funcitons included in the file "nb_data_funs.R" (in the stan-dev repository, above). 

## The Data Sources
Brasil Ministério da Saúde. Secretaria de Vigilância em Saúde. Departamento de Vigilância Epidemiológica. Sistema de Informação de Agravos de Notificação – Sinan. Available from: http://tabnet.datasus.gov.br/cgi/menu_tabnet_php.htm 

Brasil Ministério da Saúde. Secretaria de Vigilância em Saúde. Eventos Vitais – Sistema de Informação sobre Mortalidade (SIM). Available from: http://tabnet.datasus.gov.br/cgi/deftohtm.exe?sim/cnv/obt10uf.def 

Sistema Ibge de Recuperação Automática – SIDRA [Internet]. Instituto Brasileiro de Geografia e Estatística. Available from: https://sidra.ibge.gov.br/home/pimpfbr/brasil 

Atlas of Human Development in Brazil [Internet]. United Nations Development Programme. Available from: http://www.atlasbrasil.org.br/. 
	
Ministério da Justiça e Segurança Pública. Departamento Nacional Penitenciário. Levantamento Nacional de Informações Penitenciárias: INFOPEN. Available from: https://dados.mj.gov.br/dataset/infopen-levantamento-nacional-de-informacoes-penitenciarias.

Brasil, Ministério da Saúde. Banco de dados do Sistema Unico de Saúde-DATASUS Available from: http://www.datasus.gov.br. 

Shapefiles were acccessed from: Pereira, R.H.M.; Gonçalves, C.N.; et. all (2019) geobr: Loads Shapefiles of Official Spatial Data Sets of Brazil. GitHub repository - https://github.com/ipeaGIT/geobr.

### The Fine Print
This repository is meant to reduce friction in sharing information about the models described in the two publications listed above. This repository assumes a working knowledge of rstan, and the code is not intended to be applied to other datasets 'off the shelf'. Please refer to the publications for more information about model assumptions and limitations. 
