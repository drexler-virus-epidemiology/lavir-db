server <- function(input, output, session) {
  
  source(file = "src/load_dependencies.R")
  
  values = reactiveValues()
  latin_countries = c("Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Costa Rica", "Cuba", "Dominican Republic", 
                      "Ecuador", "El Salvador", "Guatemala", "Haiti", "Honduras", "Mexico", "Nicaragua", "Panama",
                      "Paraguay", "Peru", "Puerto Rico", "Uruguay", "Venezuela")
  values$latin_countries = latin_countries
  
  values$country_location <- data.frame(
    isolation_country = latin_countries,
    Latitude = c(-34.61, -16.29, -14.24, -33.45, 4.61, 9.93, 23.13, 18.73, -0.23, 13.79, 14.63, 18.97, 15.2, 23.63, 12.87, 8.98, -23.43, -9.19, 18.22, -32.53, 6.42),
    Longitude = c(-58.38, -63.59, -51.92, -70.66, -74.08, -84.08, -82.36, -70.16, -78.51, -88.9, -90.51, -72.33, -86.24, -102.55, -85.21, -79.53, -58.44, -75.98, -66.03, -55.77, -66.91)
  )
  
  # First Map Loading
  output$map <- renderLeaflet (
    {
      leaflet() %>% addTiles() %>% setView(lng = -84.08, lat = 9.93, zoom = 12)
    }
  )
  
  observeEvent (
    "",
    {
      menu_options <- c("All", values$latin_countries)
      updateSelectInput(session, "selected_countries", choices = menu_options, selected = menu_options[1])
    } 
  )
  
  observeEvent (
    input$selected_countries,
    {
      updateSelectizeInput(session, "selected_viruses", choices = read_viruses(input$selected_countries), server = TRUE)
    }
  )
  
  observeEvent(
    input$go_button,
    {
      validate(
        need(
          isFALSE(any(is.na(input$selected_years))), "Need to select range!"
          )
        )
      data = 
        get_df_by_country(input$selected_countries) %>% #reading
        filter(species %in% input$selected_viruses) %>% #select by viruses
        filter(collection_year >= input$selected_years[1] & 
                 collection_year <= input$selected_years[2]) #select by date
      
      if( dim(data)[1] < 1 ){
        shinyalert::shinyalert(
          title = "No results",
          text = "Your query returned 0 results!",
          type = "warning"
        )
      } else {
        #quantities in the map
        output$map <- renderLeaflet (
          {
            data %>%
              group_by(isolation_country) %>%
              summarize(Count = n()) %>%
              left_join(., values$country_location, by = "isolation_country") %>%
              leaflet() %>% addTiles() %>%
              addCircles(lng = ~Longitude, lat = ~Latitude, weight = 1,
                         radius = ~Count * 1000, popup = ~isolation_country
              )
          }
        )
        #publication and information
        data_aux = data %>% select(publication, host_name)
        data_aux$publication = as.integer(data_aux$publication)
        
        pubmed =
          get_pub_by_pmid(data$publication) %>%
          left_join(., data_aux, by = c('pmid'='publication'))
        
        output$pmidOutput <- renderUI({
          column (
              width = 12,
              height = 600,
              createMiniCards(pubmed)
          )
        })
        
        values$data <- data
      }
    }
  )
  
  output$downloadData = downloadHandler(
    filename = "metadata.csv",
    content = function(file) {
      fwrite(values$data, file)
    }
  )
  
  output$downloadSeq = downloadHandler(
    filename = "seqdata.fasta",
    content = function(file) {
      
      wh <- entrez_post(db = "nuccore", id = values$data$genbank_accession)
      fasta <- entrez_fetch(db = "nuccore", web_history = wh, rettype = "fasta")
      
      writeLines(fasta, file)
    }
  )

}
