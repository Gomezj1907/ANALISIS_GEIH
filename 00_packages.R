


require(pacman)

## Imprimir version
cat("R version 4.2.2 (2022-10-31 ucrt)")

## requiere pacman
# if(!require(ggsn)){devtools::}
if(!require(pacman)){install.packages("pacman") ; require(pacman)}

## packages
p_load(
  ## Base
  rio, 
  farver,
  readr,
  tidyverse, 
  readxl,
  janitor, 
  dtplyr, 
  RColorBrewer, 
  data.table,
  corrplot,
  ggthemes,
  lubridate,
  readxl,
  fastDummies,
  
  ## Machine Learning
  caret,
  fixest,
  factoextra,
  mfx,
  tidymodels,
  rattle,
  recipes,
  workflows,
  rpart.plot, 
  parsnip,
  rpart, 
  randomForest,
  ranger, 
  viridis,
  xgboost,
  keras,
  vip,
  
  ## Tablas de regresion
  stargazer,
  kableExtra)

##  opciones
options(scipen = 999)
select <- dplyr::select
`%no%`<- negate(`%in%`)

