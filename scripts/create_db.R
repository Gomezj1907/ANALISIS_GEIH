##### Creacion de base de datos a partir de los csv mensuales


#Empieza script
# Limpio espacio

rm(list = ls())
cat("\f")
# Cargo paquetes
source("00_packages.R")

files <- list.files("raw", recursive = T, full.names = T)

modulos <- c("Carac", "Fuerza de", "Ocupados", "No ocupados", "Migra")

importar <- function(module){
  
  data <- import_list(str_subset(files, module)) %>% 
    rbindlist(., fill = T) %>% 
    clean_names() %>% data.table()
  
  return(data)
}

modules <- lapply(X = modulos, FUN = importar)

car_gen <- modules[[1]]
fdt <- modules[[2]] %>% .[,pea := 1]
ocu <-  modules[[3]] %>% .[,ocu := 1]
desocu <- modules[[4]] %>% .[,desocu := 1]
migracion <- modules[[5]]

rm(modules)

# Id unico

car_gen[,c( "directorio", "secuencia_p", "orden")] %>% duplicated() %>% tabyl()

# Pegue
geih_2022 <-  merge(car_gen, fdt, by = c("directorio", "secuencia_p", "orden"), all.x = TRUE, suffixes = c("","fdt")) %>% 
  merge(., ocu, by = c("directorio", "secuencia_p", "orden"), all.x = TRUE, suffixes = c("","ocup")) %>% 
  merge(.,desocu, by = c("directorio", "secuencia_p", "orden"), all.x = T, suffixes = c("","uemp")) %>% 
  merge(., migracion, by = c("directorio", "secuencia_p", "orden"), all.x = T, suffixes = c("","mig"))

cols <- grep("uemp|mig|ocup|fdt", names(geih_2022))
geih_2022 <- geih_2022[,-..cols]

geih_2022 <- geih_2022[is.na(pet), pet:= 0]
geih_2022 <- geih_2022[is.na(pea), pea:= 0]
geih_2022 <- geih_2022[is.na(ocu), ocu:= 0]
geih_2022 <- geih_2022[is.na(desocu), desocu:= 0]

geih_2022 <- geih_2022[, fex_c18:= fex_c18/12]

fwrite(geih_2022, file = "output/geih.csv", sep = '|')

