# Setup for MS-app

listPackages <- c("BiocInstaller", "shiny", "lattice")

if(!require("BiocInstaller", quietly = T))  
  install.packages("BiocInstaller")
require("BiocInstaller", quietly = T)
biocLite("RforProteomics", dependencies = TRUE)
#library RforProteomics (has the libraries needed)
library(RforProteomics)

# install if needed and load "shiny" lib
if(!require("shiny", quietly = T))  
  install.packages("shiny")
require("shiny", quietly = T)

# install if needed and load "lattice" lib
if(!require("lattice", quietly = T))  
  install.packages("lattice")
require("lattice", quietly = T)

