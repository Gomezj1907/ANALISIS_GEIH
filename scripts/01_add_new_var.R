##### Creacion de base de datos a partir de los csv mensuales

# Limpio espacio

rm(list = ls())

# Cargo paquetes

require(pacman)

p_load(tidyverse, rio, readr, tidymodels, 
       stargazer, knitr, kableExtra, 
       readxl, purrr, fastDummies)

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

identificadores <- list()
modulos <- modulos[choose_model]

# Crear lista con identificadores 


if (first_time == TRUE) {
  i <- 0
  for (mes in meses) {
    directory_inicial<- paste0("raw/", "mes_", mes, "/",
                        "Características generales, seguridad social en salud y educación.csv")
    identificador <- import(directory_inicial)
    identificador <- identificador |> select(DIRECTORIO, SECUENCIA_P, ORDEN)
    i <- i + 1
    identificadores[[i]] <- identificador 
  }
  first_time <- FALSE
}

geih2022 <- identificadores[[1]]


for (i in 2:12) {
  geih2022 <- rbind(geih2022,identificadores[[i]])
}

# N = 919459

# Create a list of your Stata global lists
varlist <- list(
  c("p3271", "p6040", "p2057", "p2059", "p2061", "p6080", "p6070", "p6090", "p6100", "p6160
    p6170", "p3042", "p3043", "fex_c18", "MES", "DIRECTORIO", "SECUENCIA_P", "ORDEN"),
  c("p6240", "p6240s2", "p6250", "p6260", "p6260s1", "p6260s2", "p6270", "p6280", 
    "p3362s1", "p3362s2", "p3362s3", "p3362s4", "p3362s5", "p3362s6", "p3362s7", 
    "p3362s8", "p6300", "p6310", "p6320", "p6330", "p6340", 
    "p6351", "DIRECTORIO", "SECUENCIA_P", "ORDEN"),
  c("p3373", "p3373s1", "p3373s2", "p3373s3", "p3373s3a1", "p3373s3a2", "p3374", 
    "p3374s1", "p3374s2", "p3374s3", "p3375", "p3382", "p3386", 
    "DIRECTORIO", "SECUENCIA_P", "ORDEN"),
  c("p7250", "p7280", "p744", "p3074", "p7260", "p1806", "p7440s1", "p7440s2", 
    "p7450", "p7350", "p7360", "p9460", "p1519", "p7422", "DIRECTORIO", "SECUENCIA_P", "ORDEN"),
  c("p6440", "p6450", "p6460", "p6400", "p6410", "p6422", "p6424s1", "p6424s2", 
    "p6424s3", "p6424s5", "p6430", "p3045s1", "p3045s2", "p3045s3", "p3046", 
    "p3363", "p9440", "p6510", "p6640", "p1800", "p1802", "p3047", "p6765", 
    "p3052s1", "p3069", "p6880", "p6915", "p6920", "p6930", "p6940", "p6990", 
    "p9450", "p7020", "p760", "p7026", "p1880", "p7090", "p7110", "p7120", "p7130", 
    "p7140s1", "p7140s2", "p7140s3", "p7140s4", "p7140s5", "p7140s6", "p7140s7", 
    "p7140s8", "p7140s9", "p7150", "p7160", "p7170s1", "p7170s5", "p7170s6", "p7180", 
    "p514", "p515", "p7240", "oficio_c8", "rama2d_r4", "rama4d_r4", "DIRECTORIO", 
    "SECUENCIA_P", "ORDEN")
)

# Capitalize all letters in each element
for (i in 1:length(varlist)) {
  varlist[[i]] <- toupper(varlist[[i]])
}



for (mes in meses) {
  #count the module
  count <- 0
  for (mod in modulos) {
    directory <- paste0("raw/", "mes_", mes, "/", mod, ".csv")
    datos_mod <- import(directory)
    count <- count + 1
    datos_mod <- datos_mod |> 
      select(any_of(varlist[[count]]))
    datos_mod$id_mod <- count
    geih2022 <- merge(geih2022, datos_mod, by = c("DIRECTORIO", 
                                                  "SECUENCIA_P", "ORDEN"),  all = TRUE)
    
  }
  
}



rm(datos_mod, identificador, identificadores)

geih2022 <- as_tibble(geih2022, .name_repair = janitor::make_clean_names)

geih2022 <- geih2022[!duplicated(as.list(geih2022))]

colnames(geih2022)<- gsub(pattern = "\\_x$", replacement = "", x = names(geih2022))
colnames(geih2022)<- gsub(pattern = "\\_y$", replacement = "", x = names(geih2022))
colnames(geih2022)<- gsub(pattern = "\\_y_1$", replacement = "", x = names(geih2022))
colnames(geih2022)<- gsub(pattern = "\\_y_2$", replacement = "", x = names(geih2022))
colnames(geih2022)<- gsub(pattern = "\\_y_3$", replacement = "", x = names(geih2022))
colnames(geih2022)<- gsub(pattern = "\\_y_4$", replacement = "", x = names(geih2022))
colnames(geih2022)<- gsub(pattern = "\\_y_5$", replacement = "", x = names(geih2022))
colnames(geih2022)<- gsub(pattern = "\\_y_6$", replacement = "", x = names(geih2022))

geih2022 <- geih2022[!duplicated(as.list(geih2022))]

for (i in 1:length(varlist)) {
  varlist[[i]] <- tolower(varlist[[i]])
}
combined_vector <- c(varlist[[1]], varlist[[2]], varlist[[3]], varlist[[4]], varlist[[5]])

combined_vector <- append(combined_vector, "id_mod")

geih2022 <- geih2022 |> 
  select(any_of(combined_vector)) 

