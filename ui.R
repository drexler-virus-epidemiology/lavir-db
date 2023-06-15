source(file = "src/load_dependencies.R")

ui <- gridlayout::grid_page (

  layout = c(
    "header header",
    "sidebar_param output_area",
    "footer footer"
  ),
  row_sizes = c("60px", "1fr", "70px"),
  col_sizes = c("245px","1fr"),
  gap_size = "1rem",
  
  grid_card_text(
    area = "header",
    alignment = "start",
    is_title = TRUE,
    content = "Latin America Virus Research DB"
  ),
  
  grid_card(
    area = "footer",
    alignment = "start",
    width = "100%", 
    height =  "100%",
    is_title = FALSE, 
    layout_column_wrap(
      card_image(file = "img/Logo_Charite.png", width = "150px", height = "auto"),
      markdown(""),
      markdown("This app is manteined by the [Drexler's Virus Epidemiology Lab](https://virologie-ccm.charite.de/en/research/ag_drexler/)."),
      markdown(""),
      markdown("Its source code is publicly available on [GitHub](https://github.com/drexler-virus-epidemiology/lavir-db)."),
      markdown(""),
      card_image(file = "img/GLACIER_German-2021.png", width = "150px", height = "auto"),  
      fixed_width = T,
      width = 1/7,
      gap = "30px"
    )
  ),
  
  grid_card (
    area = "sidebar_param",
    card_header ("Settings"),
    
    card_body_fill (
      
      selectInput (
        inputId = "selected_countries",
        label = "Countries:",
        choices = "All",
        multiple = T,
      ),
      
      selectizeInput (
        inputId = "selected_viruses",
        label = "Viruses:",
        choices = "All",
        multiple = T,
        selected = "All"
      ),
      
      
      numericRangeInput (
        inputId = "selected_years",
        label = "Year of Collection:",
        value = c(2010, 2023),
        separator = " to ",
        min = 1944,
        max = 2023,
        step = 1
      )
      
    ),
    
    card_footer (
      column (
        width = 12,
        height = 600,
        
        actionButton ( inputId = "go_button", label = "GO" ),
        br(),br(),
        downloadButton( outputId = "downloadData", label = "Metadata"),
        br(),br(),
        downloadButton( outputId = "downloadSeq", label = "Sequence"),
        br(),br(),
      ),
    )
    
  ),
  
  grid_card (
    
    area = "output_area",
    
    card_body_fill (
      
      grid_container (
        
        layout = c(
          "map_area map_area data_area"
        ),

        gap_size = "10px",
        
        grid_card (
          area = "map_area",
          full_screen = F,
          leafletOutput("map", width="100vh", height="100vh")
        ),
        
        grid_card (
          area = "data_area",
          full_screen = F,
          card_header("Publications"),
          uiOutput("pmidOutput")
        )
      )
    )
  )
  
)
