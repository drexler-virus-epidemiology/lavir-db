library(parallel)
library(rentrez)
library(tidyverse)
library(RCurl)
library(readr)
library(stringr)

setwd("/home/muca10/Documents/lavir-db/data/")

#references
#https://www.bv-brc.org/api/doc/genome
#https://www.bv-brc.org/api/doc/

get_df_web = function(link){
  return(read.csv(stringr::str_replace_all(link, " ", "%20"), sep="\t" ))
}

parse_bvbrc_country = function(country = ""){
  current_year <- as.numeric(format(Sys.Date(), "%Y"))
  link_base = "https://www.bv-brc.org/api/genome/?"
  link_sufix = "&limit(500000000000000)&http_accept=text/tsv"
  link_query = c()
  for (year in as.character(1944:2019)){
    aux = paste0("and(and(eq(superkingdom,Viruses),eq(collection_year,",year,")),eq(isolation_country,",country,"))")
    link_query = c(link_query, paste0(link_base, aux, link_sufix))
  }
  aux = paste0("and(eq(isolation_country,",country,"),ne(collection_year,*))")
  link_query = c(link_query, paste0(link_base, aux, link_sufix))
  for (year in as.character(2020:as.numeric(format(Sys.Date(), "%Y")))) {
    aux = paste0('and(eq(superkingdom,Viruses),ne(genome_name,Severe acute respiratory syndrome coronavirus 2),eq(collection_year,',year,"),eq(isolation_country,",country,"))")
    link_query = c(link_query, paste0(link_base, aux, link_sufix))
  }
  print(link_query)
  cl = makeCluster(detectCores()*2)
  dataframes = parLapply(cl, link_query, get_df_web)
  stopCluster(cl)
  print(paste0("Downloaded, parsing data from ",country,"!"))
  return( do.call(rbind, dataframes) )
}

latin_countries <- c("Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Costa Rica", "Cuba", "Dominican Republic", 
                     "Ecuador", "El Salvador", "Guatemala", "Haiti", "Honduras", "Mexico", "Nicaragua", "Panama",
                     "Paraguay", "Peru", "Puerto Rico", "Uruguay", "Venezuela")

pmids = c()
for (ctr in latin_countries) {
  dataset = parse_bvbrc_country(ctr)
  pmids = c(pmids, dataset$publication)
  write_csv(dataset, paste0(ctr,"_ViPR_DB.csv"))
}

filtered_public <- Filter(function(x) x != "", unique(as.character(pmids)))
filtered_public <- unlist(lapply(filtered_public, function(x) strsplit(x, ",")[[1]][1]))
print(filtered_public)

get_pubmed_info <- function(pmid) {
  summary <- entrez_summary(db = "pubmed", id = pmid)
  author <- summary$sortfirstauthor
  laut <- summary$lastauthor
  doi <- (summary$articleids %>% filter(idtype == "doi") )$value
  pub_date <- summary$history$date[2]
  list(pmid = pmid, author = author, last_author = laut, doi = doi, publication_date = pub_date)
}

NCBI_data = sapply(filtered_public, get_pubmed_info)
NCBI_data = t(as.data.frame(NCBI_data))
write.csv(NCBI_data, "pubmed.csv", row.names = F)

latitude <- c(-34.61, -16.29, -14.24, -33.45, 4.61, 9.93, 23.13, 18.73, -0.23, 13.79, 14.63, 18.97, 15.2, 23.63, 
              12.87, 8.98, -23.43, -9.19, 18.22, -32.53, 6.42)

longitude <- c(-58.38, -63.59, -51.92, -70.66, -74.08, -84.08, -82.36, -70.16, -78.51, -88.9, -90.51, -72.33, -86.24, 
               -102.55, -85.21, -79.53, -58.44, -75.98, -66.03, -55.77, -66.91)

country_data <- data.frame(Country = latin_countries, Latitude = latitude, Longitude = longitude)

write.csv(country_data, "latin_tude.csv", row.names = F)
