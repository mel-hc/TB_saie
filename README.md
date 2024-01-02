# TB Small Area Incidence Estimation
This repository contains code and data to recreate the findings from two manuscripts related to small area TB burden estimation in Brazil: 

  Chitwood MH, Pelissari DM, Drummond Marques da Silva G, Bartholomay P, Rocha MS, Sanchez M, Arakaki-Sanchez D, Glaziou P, Cohen T, Castro MC, Menzies NA. **Bayesian evidence synthesis to estimate subnational TB incidence: An application in Brazil.** Epidemics. 2021 Jun;35:100443. doi: 10.1016/j.epidem.2021.100443. Epub 2021 Feb 20. [PMID: 33676092](https://pubmed.ncbi.nlm.nih.gov/33676092/).

  Chitwood MH, Alves LC, Bartholomay P, Couto RM, Sanchez M, Castro MC, Cohen T, Menzies NA. **A spatial-mechanistic model to estimate subnational tuberculosis burden with routinely collected data: an application in Brazilian municipalities.** PLOS Global Public Health 2022; 2(9): e0000725. https://doi.org/10.1371/journal.pgph.0000725 [PMID: 36962578](https://pubmed.ncbi.nlm.nih.gov/36962578/)

## The Models
Both models produce estimates of TB incidence and fraction of cases treated by geographical area in Brazil using a mechanistic model of TB natural history. The models are implemented in rstan, a package for fitting Bayesian models in R. 

The folder [TimeTrendModel](https://github.com/mel-hc/TB_saie/tree/main/TimeTrendModel) contains a model that produces a time series of estimates. This model is intended for a smaller number of geographies. 

The folder [SpatialModel](https://github.com/mel-hc/TB_saie/tree/main/SpatialModel) contains a model that produces spatially-explicit estimates for a single timepoint and can accomodate a large number of geographies.

## The Folder Structure
The file **xx_input_data** contains data aggregated from various governmental sources in Brazil. TB case notification and treatment outcome data come from SINAN. Mortality data come from SIM. Demographic data come from IBGE. See full citation list below. 

The file **xx_model_run.R** contains code to initiate a model run. Please note that running rstan is computationally intensive; model runs may take multiple hours.

The file **xx_model.stan** contains the code for the statistical model. 

## Additional Model Code
The stan code in "SpatialModel" was adapted from example [Besag-York-Mollié 2 model](https://pubmed.ncbi.nlm.nih.gov/31677766/) [code](https://github.com/stan-dev/example-models/blob/885bd18e93fd4b7b19290d8967064174bbe45156/knitr/car-iar-poisson/bym2.stan) written by the stan development team.

I do not include code to convert a neighbors matrix to a list of nodes and edges (to input into rstan), nor do I include the code to calculate the scaling factor. To perform these functions, I used code from the file ["nb_data_funs.R"](https://github.com/stan-dev/example-models/blob/885bd18e93fd4b7b19290d8967064174bbe45156/knitr/car-iar-poisson/nb_data_funs.R). 

## Pacakges
The model was fit with the package 'rstan' (version 2.21.3) in R (version 4.1.2). 

## Data Sources
Brasil Ministério da Saúde. Secretaria de Vigilância em Saúde. Departamento de Vigilância Epidemiológica. Sistema de Informação de Agravos de Notificação – Sinan. Available from: http://tabnet.datasus.gov.br/cgi/menu_tabnet_php.htm 

Brasil Ministério da Saúde. Secretaria de Vigilância em Saúde. Eventos Vitais – Sistema de Informação sobre Mortalidade (SIM). Available from: http://tabnet.datasus.gov.br/cgi/deftohtm.exe?sim/cnv/obt10uf.def 

Sistema Ibge de Recuperação Automática – SIDRA. Instituto Brasileiro de Geografia e Estatística. Available from: https://sidra.ibge.gov.br/home/pimpfbr/brasil 

Atlas of Human Development in Brazil. United Nations Development Programme. Available from: http://www.atlasbrasil.org.br/. 
	
Ministério da Justiça e Segurança Pública. Departamento Nacional Penitenciário. Levantamento Nacional de Informações Penitenciárias: INFOPEN. Available from: https://dados.mj.gov.br/dataset/infopen-levantamento-nacional-de-informacoes-penitenciarias.

Brasil, Ministério da Saúde. Banco de dados do Sistema Unico de Saúde-DATASUS Available from: http://www.datasus.gov.br. 

Shapefiles were acccessed from: Pereira, R.H.M.; Gonçalves, C.N.; et. all (2019) geobr: Loads Shapefiles of Official Spatial Data Sets of Brazil. GitHub repository - https://github.com/ipeaGIT/geobr.

### The Fine Print
This repository is meant to reduce friction in sharing information about the models described in the two publications listed above. This repository assumes a working knowledge of rstan, and the code is not intended to be applied to other datasets 'off the shelf'. Please refer to the publications for more information about model assumptions and limitations. 
