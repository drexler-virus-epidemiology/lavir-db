#!/bin/bash

R -q -e "install.packages(c('devtools'), quiet = TRUE)"
R -q -e "devtools::install_github('rstudio/gridlayout')"
R -q -e "devtools::install_github('allenbaron/rentrez', force = T)"
R -q -e "install.packages(c('leaflet'), quiet = TRUE)"
R -q -e "install.packages(c('shiny'), quiet = TRUE)"
R -q -e "install.packages(c('plotly'), quiet = TRUE)"
R -q -e "install.packages(c('bslib'), quiet = TRUE)"
R -q -e "install.packages(c('shinyWidgets'), quiet = TRUE)"
R -q -e "install.packages(c('tidyverse'), quiet = TRUE)"
R -q -e "install.packages(c('shinyalert'), quiet = TRUE)"
R -q -e "install.packages(c('data.table'), quiet = TRUE)"

