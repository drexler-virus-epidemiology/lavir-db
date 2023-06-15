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
  return(read.csv(stringr::str_replace_all(link, " ", "%20"), sep="\t", stringsAsFactors = T ))
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
  aux = paste0("and(and(eq(superkingdom,Viruses),eq(isolation_country,",country,")),ne(collection_year,*))")
  link_query = c(link_query, paste0(link_base, aux, link_sufix))
  for (year in as.character(2020:as.numeric(format(Sys.Date(), "%Y")))) {
    aux = paste0('and(eq(superkingdom,Viruses),ne(genome_name,Severe acute respiratory syndrome coronavirus 2),eq(collection_year,',year,"),eq(isolation_country,",country,"))")
    link_query = c(link_query, paste0(link_base, aux, link_sufix))
  }
  print(link_query)
  cl = makeCluster(detectCores()*5)
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

filtered_public <- unlist(lapply(pmids, function(x) strsplit(x, ",")[[1]][1]))
filtered_public <- Filter(function(x) x != "", unique(as.character(filtered_public)))
write_lines(filtered_public, "pmids.txt")
#filtered_public = read_lines("pmids.txt")

get_pubmed_info <- function(pmid) {
  result <- tryCatch({
    summary <- entrez_summary(db = "pubmed", id = pmid)
    title <- summary$title
    author <- summary$sortfirstauthor
    laut <- summary$lastauthor
    doi <- (summary$articleids %>% filter(idtype == "doi") )$value
    pub_date <- summary$history$date[2]
    message(paste0("pmid found: ", pmid))
    data.frame(pmid = pmid, title = title, author = author, last_author = laut, doi = doi, publication_date = pub_date)
  }, error = function(e) {
    message("An error occurred:", conditionMessage(e))
    return(data.frame(pmid = pmid, title = "", author = "", last_author = "", doi = "", publication_date = ""))
  }, warning = function(w) {
    message("A warning occurred:", conditionMessage(w))
    return(data.frame(pmid = pmid, title = "", author = "", last_author = "", doi = "", publication_date = ""))
  })
  return(result)
}

NCBI_data = sapply(filtered_public, get_pubmed_info)
NCBI_data = as.data.frame(t(NCBI_data))
NCBI_data = NCBI_data[NCBI_data$last_author != "",]

NCBI_data$pmid<- sapply(NCBI_data$pmid, paste, collapse = ", ")
NCBI_data$title <- sapply(NCBI_data$title, paste, collapse = ", ")
NCBI_data$author <- sapply(NCBI_data$author, paste, collapse = ", ")
NCBI_data$last_author <- sapply(NCBI_data$last_author, paste, collapse = ", ")
NCBI_data$doi<- sapply(NCBI_data$doi, paste, collapse = ", ")
NCBI_data$publication_date <- sapply(NCBI_data$publication_date, paste, collapse = ", ")

write.csv(NCBI_data, "pubmed.csv", row.names = FALSE)

