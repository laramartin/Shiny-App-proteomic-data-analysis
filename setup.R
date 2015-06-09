
###################################################
#   LARA MARTIN - proyecto final de posgrado      #
#   setup.R                                       #
###################################################

# for install RforProteomics from source
if(!require("BiocInstaller", quietly = T))  
  install.packages("BiocInstaller")
require("BiocInstaller", quietly = T)

# RforProteomics contains the libraries needed
if(!require("RforProteomics", quietly = T)){
  biocLite("RforProteomics", dependencies = TRUE)
  require("RforProteomics", quietly = T)
}

# install if needed and load "shiny" lib
if(!require("shiny", quietly = T))  
  install.packages("shiny")
require("shiny", quietly = T)

# install if needed and load "lattice" lib
if(!require("lattice", quietly = T))  
  install.packages("lattice")
require("lattice", quietly = T)


