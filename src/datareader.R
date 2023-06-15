
latin_countries <- c("Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Costa Rica", "Cuba", "Dominican Republic",
                     "Ecuador", "El Salvador", "Guatemala", "Haiti", "Honduras", "Mexico", "Nicaragua", "Panama",
                     "Paraguay", "Peru", "Puerto Rico", "Uruguay", "Venezuela")

#function to retrieve all data by countries
get_df_by_country = function(countries){
  if ("All" %in% countries){
    countries = latin_countries
  }
  df = data.frame()
  for (country in countries) {
    df = rbind(
      df,
      fread(paste0("data/",country,"_ViPR_DB.csv"), data.table=FALSE)
    )
  }
  return(df)
}

#auxiliary function to return unique values through a same columns from different csvs
read_column_from_csv <- function(file_names, column_name) {
  column_data <- c()
  for (file in file_names) {
    data <- fread(paste0("data/",file,"_ViPR_DB.csv"), data.table=FALSE)
    column_data <- c(column_data, data[,c(column_name)])
  }
  return(unique(column_data))
}

#specialized function to call all viruses on database
read_viruses <- function(ctr = latin_countries) {
  if ("All" %in% ctr){
    ctr = latin_countries
  }
  data = read_column_from_csv(ctr, "species")
  return(data)
}

#function to retrieve all publications linked to a search
get_pub_by_pmid = function(pmids){
  df = fread(paste0("data/pubmed.csv"), data.table=FALSE)
  df = df %>% filter(pmid %in% pmids)
  return(df)
}