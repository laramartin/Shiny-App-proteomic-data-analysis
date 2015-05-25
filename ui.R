################################
#   LARA MARTIN - proyecto final de posgrado
#   ui.R
################################

library(shiny)

shinyUI(fluidPage(
  
  ############  TITLE PANEL ##########
  
  titlePanel("Mass Spectrometry Analysis App"),
  p("Note that when downloading a data set, it can take some time to download and show information."),

  ############  SIDEBAR PANEL ##########
  
  sidebarLayout(
    sidebarPanel(
      # explain the first step
      h3("Step 1: choose a data set"),
      helpText("Write in the box the PX ID of the data set of interest. 
               You can use for example the PXD000001 data set."),
      textInput("datasetID", 
                label = h5("Data set Identifiyer from ProteomeXchange"), 
                value = ""),
#       selectInput("datasetID", label="Choose a dataset:",
#                   choices="PXD000001"),

      br(),
      br(),
      
      # show the radio buttons if user writes the number of the file to be analyzed
      conditionalPanel("input.number_file",
        # set of radio buttons to choose type of analysis   
        radioButtons("radiobuttons", label = h3("Choose type of analysis"),
               choices = list("Scan Peaks" = 1, "Spectra Raw Data" = 2, "Choice 3" = 3), 
               selected = 1)
      )
     
    ),
    
    
    ############  MAIN PANEL ##########
    
    mainPanel(
      conditionalPanel("!input.number_file",
        conditionalPanel("input.datasetID",
  
          # title - show data set ID that is going to be analyzed
          h2("Dataset", textOutput("id")),
          
          # information from data set
          h3("Information from dataset"),
          helpText("Here is shown some information from the data set"),
          
          # dataset object information
          h4("Dataset object information"),
          p(verbatimTextOutput("datasetInfo")),
          
          # taxonomic name
          h4("Taxonomic name of object"),
          p(verbatimTextOutput("datasetTax")),
          
          # list of files available in data set
          h4("Files available from data set"),
          helpText("The following list is the files available in the data set"),
          p(verbatimTextOutput("datasetFiles")),
          br(),
          p("To proceed the analysis, choose a file with one of the 
            following formats: netCDF, mzXML, mzData or mzML."),
          br(),
          
          # choosing the MS file to be analyzed
          numericInput("number_file", 
                    label = "Number of the file", 
                    value = "")
        )
      ),
      
      conditionalPanel("input.number_file",
                       
        # if user chooses analysis 1 (scan peaks)               
        conditionalPanel("input.radiobuttons=='1'",
          p(verbatimTextOutput("msFileInfo")),
          numericInput("numScan", 
                       label = "Scan number to plot", 
                       value = ""),
          conditionalPanel("input.numScan",
                           plotOutput('plotPeaks')
          )
        ),
        
        # if user chooses analysis 2 (Spectra Raw Data)               
        conditionalPanel("input.radiobuttons=='2'",
          p("Spectra Raw Data"),
          sliderInput("sliderSpectra", label = h2("Choose range"), min = 0, 
                      max = 100, value = c(30, 35)),     #### <-----------------------------------x-bar between 0 and 60????
          
          plotOutput('spectraRawData'),
          plotOutput("spectraRawData3D"),
          plotOutput("spectra2RawData")
            
          )
      
          # p(verbatimTextOutput("hd"))       #### <----------------------------------- ????
          
        )
      )
    
  )
))