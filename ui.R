###################################################
#   LARA MARTIN - proyecto final de posgrado      #
#   ui.R                                          #
###################################################

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
      
      # for development purposes, the dataset "PXD000001" is stored locally, 
      # so I avoid  downloading every time I execute the App 
#       selectInput("datasetID", label="Choose a dataset:",
#                   choices="PXD000001"),

      br(),
      br(),
      
      # show the radio buttons if user writes the number of the file to be analyzed
      conditionalPanel("input.number_file",
        # set of radio buttons to choose type of analysis   
        radioButtons("radiobuttons", label = h3("Step 2: choose type of analysis"),
               choices = list("Scan Peaks" = 1, 
                              "Spectra Raw Data" = 2, 
                              "Correction and Filtering" = 3,
                              "MS/MS database search" = 4), 
               
               selected = 1)
      )
     
    ),
    
    
    ############  MAIN PANEL ##########
    
    mainPanel(
      conditionalPanel("!input.number_file",
        
        # this panel will show up only when the user writes an ID                              
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
            following formats: mzXML or mzML."),   ##### mzXML o mzML   <-----------------
          br(),
          
          # choosing the MS file to be analyzed
          numericInput("number_file", 
                    label = "Number of the file", 
                    value = "")
        )
      ),
      
      ## conditional to begin/show analysis available
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
          h2("Spectra Raw Data"),
          
          #slider for Retention Time (RT) x-axis
          sliderInput("sliderSpectraRT", label = h3("Choose Retention Time range"), min = 0, 
                      max = 60, value = c(30, 35)),     #### <-----------------------------------x-bar between 0 and 60????
          
          #slider for M/Z ratio (m/z) y-axis
          p("The minimum and maximum m/z ratios are", 
            verbatimTextOutput("rangeMinMaxMZ"),
            "Choose a m/z ratio range in the slider bar between those values"),
          
          
          sliderInput("sliderSpectraMZ", label = h3("Choose M/Z ratio range"), 
                      min=200, max=2500,              ### <-------------------- I can't give the value in rangeMinMZ from output
#                       min = textOutput("rangeMinMZ"), 
#                       max = textOutput("rangeMaxMZ"), 
                      value = c(521, 523)),     
         
          # plots shown in 2on choice (Spectra Raw data)
          plotOutput("spectraRawData"),
          plotOutput("spectraRawData3D")
          # plotOutput("spectra2RawData")
          ), 


        # if user chooses analysis 3 (Correction and Filtering)               
        conditionalPanel("input.radiobuttons=='3'",
          h2("Correction and Filtering"), 
          p("First, We need to perform a MS/MS database search. For that we use the MSGF+ engine, parsing the
            raw data against the fasta file of the organism"),
          verbatimTextOutput("MSMSsearch_out"),
          h4("TO BE IMPLEMENTED")
        ),
      

        # if user chooses analysis 4 (MS/MS database search)               
        conditionalPanel("input.radiobuttons=='4'",
          h2("MS/MS database search"),
          p("We can obtain an identification file searching the raw data against 
            the database of the organism when it is available. To generate the 
            identification file, you have to upload the database in fasta format."),
          
          br(),
          br(),
          
          h4("Generate an identification file"),
          br(),
          p("We need the database to parse it with the raw data. You can upload the fasta file if you have it.
            In case the data you are using already distributes the fasta file, click the print button to see 
            the list of files available. Then write in the box the correspondent number."),
          br(), 
          
          h5(strong("-> Updload the database in fasta format here:")),
          
          #file upload manager for fasta file
          fileInput("fasta_file", label = "", 
                    accept= c(".fasta",
                              ".fa",
                              ".mpfa",
                              ".fna",
                              ".fsa",
                              ".fas"),
                    multiple = FALSE),
          br(), 
          
          h5(strong("-> Print the list of files available in the data set and choose the fasta file:")),
          
          
          # AnADIR BOTON PARA imprimir lista files y una caja numerica
          actionButton("print_files_list", label = "Print files list"), 
          
          br(), 
          br(),
          
          conditionalPanel(
            condition= "input.print_files_list != '0'", 
            p(verbatimTextOutput("files_out")),
            numericInput("num_fastafile_choice4",
                         label = "Number of the fasta file on the data set",
                         value = ""),
            
            conditionalPanel("input.num_fastafile_choice4 | input.fasta_file", 
                             p("Now the raw data is going to be parsed against the fasta file to 
                               create an identification file")
            
            
            )
          
          # close conditionalPanel("input.radiobuttons=='4'",
          )

      # close conditional conditionalPanel("input.number_file"
      )
    # close mainPanel()
    )
  # close sidebarLayout()
  )
# close fluidPage
  )
# close shinyUI
)
