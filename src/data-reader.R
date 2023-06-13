
setwd("/home/muca10/Documents/lavir-db")

latin_countries <- c("Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Costa Rica", "Cuba", "Dominican Republic", 
                     "Ecuador", "El Salvador", "Guatemala", "Haiti", "Honduras", "Mexico", "Nicaragua", "Panama",
                     "Paraguay", "Peru", "Puerto Rico", "Uruguay", "Venezuela")

#function to retrieve all data by countries
get_df_by_country = function(countries){
  if (countries == "All"){
    countries = latin_countries
  }
  df = data.frame()
  for (country in countries) {
    df = rbind(
      df,
      read.csv(paste0("data/",country,"_ViPR_DB.csv"), sep=",", stringsAsFactors = T )
    )
  }
  return(df)
}

#auxiliary function to return unique values through a same columns from different csvs
read_column_from_csv <- function(file_names, column_name) {
  column_data <- c()
  for (file in file_names) {
    data <- read.csv(paste0("data/",file,"_ViPR_DB.csv"), sep=",", header = T)
    column_data <- c(column_data, data[,c(column_name)])
  }
  return(unique(column_data))
}

#specialized function to call all viruses on database
read_viruses <- function() {
  data = read_column_from_csv(latin_countries, "species")
  return(data)
}
