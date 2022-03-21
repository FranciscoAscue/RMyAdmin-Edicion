library(DBI)
library(RMySQL)

## data from MySQL
metadata_sql <- function(usr, pass, corrida, placa = "placa1"){
  
  con <- dbConnect(MySQL(),
                   user = usr,
                   password = pass,
                   host = 'localhost',
                   dbname = 'seqcoviddb')
  query = paste0("SELECT NUMERACION_PLACA,NETLAB,OFICIO,CT,FECHA_TM,PROCEDENCIA,APELLIDO_NOMBRE,DNI_CE,VACUNADO,MOTIVO FROM `metadata` WHERE `PLACA` = '",
                     placa,"' AND `CORRIDA` = ",corrida,";")

  dbSendQuery(con, "SET NAMES utf8mb4;")
  on.exit(dbDisconnect(con))
  rs = dbSendQuery(con, query);
  df = fetch(rs, -1);
  dbClearResult(rs)
  return(df)
}


metadaEdition <- function(usr, pass, corrida,placa, min, max, corridaA){
  
  if(is.element(corrida,corridaA)){
    corrida = corrida
  }else{
    corrida = 0
  }
  
  con <- dbConnect(MySQL(),
                   user = usr,
                   password = pass,
                   host = 'localhost',
                   dbname = 'seqcoviddb')
  query = paste0("SELECT NUMERACION_PLACA,NETLAB,CT,FECHA_TM,PROCEDENCIA,PROVINCIA,DISTRITO,APELLIDO_NOMBRE,DNI_CE,EDAD,SEXO,VACUNADO,MARCA_PRIMERAS_DOSIS,1DOSIS,2DOSIS,MARCA_3DOSIS,3DOSIS,HOSPITALIZACION,FALLECIDO FROM `metadata` WHERE `NUMERACION_PLACA` BETWEEN ",
                 min," AND ",max," AND `PLACA` = '",placa,"' AND `CORRIDA` = ",corrida," ORDER BY `metadata`.`NUMERACION_PLACA` ASC;")
  dbSendQuery(con, "SET NAMES utf8mb4;")
  on.exit(dbDisconnect(con))
  rs = dbSendQuery(con, query);
  df = fetch(rs, -1);
  dbClearResult(rs)
  return(df)
}


library(utils)

update_sql <- function(usr, pass, sql_id, fecha_tm , procedencia, 
                       provincia, distrito, nombre, dni,
                       edad, sexo, vac, marca1, Pra, Sda,
                       marca2, Tra, Hp, Dead){
  if(length(fecha_tm) == 0){
    fecha_tm <- 'NULL'
  }
  
  if(is.null(procedencia) | is.na(procedencia)){
    procedencia <- 'NULL'
  }
  
  if(is.null(provincia) | is.na(provincia)){
    provincia <- 'NULL'
  }
  
  if(is.null(distrito) | is.na(distrito)){
    distrito <- 'NULL'
  }
  
  if(is.null(nombre) | is.na(nombre)){
    nombre <- 'NULL'
  }
  if(is.null(dni) | is.na(dni) | dni == ''){
    dni <- 'NULL'
  }
  if(is.null(edad) | is.na(edad)){
    edad <- 'NULL'
  }
  if(is.null(sexo) | is.na(sexo)){
    sexo <- 'NULL'
  }
  if(is.null(vac) | is.na(vac)){
    vac <- 'NULL'
  }
  if(is.null(marca1) | is.na(marca1)){
    marca1 <- 'NULL'
  }
  if(length(Pra) == 0){
    Pra <- 'NULL'
  }
  
  if(length(Sda) == 0){
    Sda <- 'NULL'
  }
  
  if(is.null(marca2) | is.na(marca2)){
    marca2 <- 'NULL'
  }
  if(length(Tra) == 0){
    Tra <- 'NULL'
  }
  
  if(is.null(Hp) | is.na(Hp)){
    Hp <- 'NULL'
  }
  if(is.null(Dead) | is.na(Dead)){
    Dead <- 'NULL'
  }
  
  con <- dbConnect(MySQL(),
                   user = usr,
                   password = pass,
                   host = 'localhost',
                   dbname = 'seqcoviddb')
  query <- paste0("UPDATE `metadata` SET `FECHA_TM` = '",fecha_tm,
                  "', `PROCEDENCIA` = '",procedencia,"', `PROVINCIA` = '",
                  provincia,"', `DISTRITO` = '",distrito,
                  "', `APELLIDO_NOMBRE` = '",nombre,"', `DNI_CE` = '",
                  dni,"', `EDAD` = '",edad,"', `SEXO` = '",sexo,
                  "', `VACUNADO` = '",vac,"', `MARCA_PRIMERAS_DOSIS` = '",
                  marca1,"', `1DOSIS` = '",Pra,"', `2DOSIS` = '",Sda,
                  "', `MARCA_3DOSIS` = '",marca2,"', `3DOSIS` = '",
                  Tra, "', `HOSPITALIZACION` = '",Hp,"', `FALLECIDO` = '",
                  Dead,"' WHERE `metadata`.`NETLAB` = \'",sql_id,"\'")
  
  query <- gsub("'NULL'", "NULL", query, fixed = TRUE)
  dbSendQuery(con, "SET NAMES utf8mb4;")
  on.exit(dbDisconnect(con))
  rs = dbSendQuery(con, query);
  df = fetch(rs, -1);
  dbClearResult(rs)
  return(df)
}


sqlRegion <- function(usr, pass){
  
  con <- dbConnect(MySQL(),
                   user = usr,
                   password = pass,
                   host = 'localhost',
                   dbname = 'ubigeo')
  query = paste0("SELECT region FROM `regiones` ORDER BY `regiones`.`id` ASC;")
  dbSendQuery(con, "SET NAMES utf8mb4;")
  on.exit(dbDisconnect(con))
  rs = dbSendQuery(con, query);
  df = fetch(rs, -1);
  dbClearResult(rs)
  return(df)
}

sqlProvincia <- function(usr, pass,region){
  
  con <- dbConnect(MySQL(),
                   user = usr,
                   password = pass,
                   host = 'localhost',
                   dbname = 'ubigeo')
  query = paste0("SELECT provincia FROM `provincia` WHERE `region` = '",region,"' ORDER BY `provincia`.`id-p` ASC;")
  dbSendQuery(con, "SET NAMES utf8mb4;")
  on.exit(dbDisconnect(con))
  rs = dbSendQuery(con, query);
  df = fetch(rs, -1);
  dbClearResult(rs)
  return(df)
}

sqlDistrito <- function(usr, pass, provincia, region){
  
  con <- dbConnect(MySQL(),
                   user = usr,
                   password = pass,
                   host = 'localhost',
                   dbname = 'ubigeo')
  query = paste0("SELECT distrito FROM `distrito` WHERE `provincia` = '",
                 provincia,"' AND `region` = '",region,"' ORDER BY `distrito`.`id-d` ASC;")
  dbSendQuery(con, "SET NAMES utf8mb4;")
  on.exit(dbDisconnect(con))
  rs = dbSendQuery(con, query);
  df = fetch(rs, -1);
  dbClearResult(rs)
  return(df)
}