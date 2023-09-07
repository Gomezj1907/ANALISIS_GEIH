##### Creacion de base de datos a partir de los csv mensuales

# Limpio espacio

rm(list = ls())

# Cargo paquetes

require(pacman)

p_load(tidyverse, rio, readr, tidymodels, 
       stargazer, knitr, kableExtra, 
       readxl, purrr)

# Cargar bases mensuales por modulos y limpiar

# Lista meses

meses <- c("enero", "febrero", "marzo", "abril", "mayo", "junio",
           "julio", "agosto", "septiembre", "octubre", "noviembre",
           "diciembre")

modulos <- c("Características generales, seguridad social en salud y educación",
             "Datos del hogar y la vivienda", "Fuerza de trabajo", "Migración", 
             "No ocupados", "Ocupados", "Otras formas de trabajo", 
             "Otros ingresos e impuestos", "Tipo de investigación")

# Prender o apagar los modulos que necesito

first_time <- TRUE


choose_model <- c(TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE)


modulos <- modulos[choose_model]

if (first_time == TRUE) {
  
  for (mes in meses) {
    
    
  }
  
}


for (mes in meses) {
  for (mod in modulos) {
    directory <- paste0("/raw/", "mes_", mes, "/", mod, ".csv")
    read_csv(directory)
  }
  

  
}










