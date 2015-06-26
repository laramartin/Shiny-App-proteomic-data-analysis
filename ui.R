###################################################
#   LARA MARTIN - proyecto final de posgrado      #
#   ui.R                                          #
###################################################

library(shiny)

shinyUI(fluidPage(
  
  ############  TITLE PANEL ##########
  
  fluidRow(
    column(2,
           img(src="lara_martin_tiny_logo.png", height="150px")
    ),
    column(10,
           titlePanel("Mass Spectrometry Analysis App"),
           strong(div("Note that when downloading a data set, it can take some time to download and show information.
             There is no function available that shows a progress bar while Shiny is busy that can be
                      used for this app.", 
                      style = "color:blue"))
    )
  ),
           

  
  # img(src="lara_martin_tiny_logo.png", titlePanel("Mass Spectrometry Analysis App")),
  # titlePanel("Mass Spectrometry Analysis App"),
  br(),
  br(),
  
  ############  SIDEBAR PANEL ##########
  
  sidebarLayout(
    sidebarPanel(

      # explain the first step
     
      p("If this is your first time using the App, read the help text in the main panel before starting."),
      
      
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
                              "MS/MS database search" = 3,
                              "Correction and Filtering" = 4,
                              "Spectra Raw Data with identifications" = 5,
                              "Quantification" = 6),
               selected = 1)
      )
     
    ),
    
    
    ############  MAIN PANEL ##########
    
    mainPanel(
      
      ## user writes ID  - information will be printed
      conditionalPanel("!input.number_file",
        
                                        
         # this panel will show up only when the user writes an ID                              
         conditionalPanel("!input.datasetID",
                          
                          # intro explaining what does this app
                          p("The MS-app allows to analyze proteomic data obtained
                            by Mass Spectrometry. The protocol implemented is inspired by the ",
                            a("Bioconductor proteomics workflow.", 
                              href = "http://www.bioconductor.org/help/workflows/proteomics/")),
                          
                          br(),
                          
                          
                          
                          p("The", strong("first step"), "is to select the experiment data. For that, 
                            introduce on the sidebar the ID of one data set located in the ", 
                            a("ProteomeXchange database", 
                              href = "http://www.proteomexchange.org/"),
                            "you want to analyse. Notice that for now, it is only possible to analyse the data set with ID", 
                            strong("PXD000001"), ". Once written the ID, the MS-app will download the data set and
                            will show some information about the data set in the main panel."),
                          
                          p("The", strong("second step"), "is to select the raw data. Raw data can be stored in 
                            different formats, but this application takes only two:", 
                            strong("mzML"), "and", strong("mzXML"), ". Once entered the data set ID, one of the things that 
                            you will see printed in the main panel is the list of files available in the data set. Below this 
                            list, there will be a box where you have to enter which raw data file it is going to be used. 
                            Doing this automatically translates to download the file "),
                          
                          p("The", strong("third step"), "is to select a type of analysis. The analysis implemented are:"),
                          
                          
                          ### EXPLICAR BREVEMENTE QUE ES CADA UNO  <<<<<<------------------
                          tags$ol(
                            tags$li(strong("Scan Peaks"), ": the number of scans will be printed, allowing you to choose
                                    a number of scan to see its plot."), 
                            tags$li(strong("Spectra Raw Data"), ": generates two plots. The first one is a heat map
                                    of the MS1 Spectra by m/z ratio and retention time chosen. The second plot is a
                                    3D of the first plot, adding the intensity as third axis."), 
                            tags$li(strong("MS/MS database search"), ":"),
                            tags$li(strong("Correction and Filtering"))
                            ),

                          br(),
                          
                          

                          
                          
                          br(),
                          br(),
                          br(),
                          br(),
                          br(),

                          
                          hr(),
                          
                          fluidRow(
                            column(2,
                                   img(src="alarm.gif", height="100px")
                            ),
                            column(10,
                                   div(
                                     p("DISCLAIMER"), 
                                     br(),
                                     p("This application is not complete. The author, Lara Martin, does not
                                       have programmer experience and had a limited time to develop this.
                                       Some of the functionality may not be completed or correct. Please
                                       refer to documentation for reference."),
                                     style = "color:red")
                            )
                          )
         ),                  
                       
                       
        
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
          p("Here below will be printed the numbers of scans in the raw data"),
          p(verbatimTextOutput("msFileInfo")),
          p("Choose and write in the box the scan number you desire to plot and 
            it will be generated below."),
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
          p("Here you can plot a specific slice of raw data to examine by retention time (RT) and M/Z ratio"),
          
          #slider for Retention Time (RT) x-axis
          sliderInput("sliderSpectraRT", label = strong("Choose Retention Time range"), min = 0, 
                      max = 60, value = c(30, 35)),     
          
          #slider for M/Z ratio (m/z) y-axis
          p("Please, notice what the minimum and maximum m/z ratios for the raw data are and choose
            a range between those numbers:"), 
          # print range M/Z ratio for raw data
          verbatimTextOutput("rangeMinMaxMZ"),
          sliderInput("sliderSpectraMZ", label = strong("Choose M/Z ratio range"), 
                      min=200, max=2500,              
                      value = c(521, 523)),     
         
          # plots shown in 2on choice (Spectra Raw data)
          plotOutput("spectraRawData"),
          plotOutput("spectraRawData3D")
          # plotOutput("spectra2RawData")
          ), 





        # if user chooses analysis 3 (MS/MS database search)               
        conditionalPanel("input.radiobuttons=='3'",
          h2("MS/MS database search"),
          p("We can search for MS/MS identifications in the raw data. For that we create an identification file 
            with mzID format using the MSGF+ engine, parsing the raw data against the fasta file of the organism."),

          br(),

          h4("Generate an identification file"),
          
          p("We need the database to parse it with the raw data. You can upload the fasta file if you have it.
            In case the data set you are using already distributes the fasta file, click the print button to see 
            the list of files available. Then write in the box below the correspondent number."),
          br(), 
          
          h5(strong("-> Upload the database in fasta format here:"),
             div(p("Sorry, the uploading doesn't work"), style = "color:red")),
          
          #file upload manager for fasta file
          fileInput("fasta_file", label = "", 
                    accept= c(".fasta",
                              ".fa",
                              ".mpfa",
                              ".fna",
                              ".fsa",
                              ".fas"),
                    multiple = FALSE),

          h5(strong("-> Print the list of files available in the data set and choose the fasta file:")),
          
          

          actionButton("print_files_list", label = "Print files list"), 
          
          br(), 
          br(),
          
          conditionalPanel(
            condition= "input.print_files_list != '0'", 
            p(verbatimTextOutput("files_out")),
            numericInput("num_fastafile_choice4",
                         label = "Number of the fasta file on the data set",
                         value = ""),
            conditionalPanel("input.num_fastafile_choice4", 
                           p("Now the raw data is going to be parsed against the fasta file to 
                             create an identification file. The search for default uses:"),
                           code("instrument = 'HighRes',"), code("enzyme = 'Trypsin',"), code("protocol = 'iTRAQ'"),
                           p("Another options are not implemented in this version."),
                           
                           br(),
                           
                           strong("This process can take more than 2 minutes. If you see this error:", 
                                  code("Error: missing value where TRUE/FALSE needed"), 
                                  "then the files are being parsed. When it's over, you will
                                  see some information here below. You can follow the Progress
                                  on the RStudio Console."),
                           
                           verbatimTextOutput("id_info")
                           )
            # close conditionalPanel "input.print_files_list != '0'"
            )
          
          # close conditionalPanel("input.radiobuttons=='3'",
          ),
        
        # if user chooses analysis 4 (Correction and Filtering)               
        conditionalPanel("input.radiobuttons=='4'",
                         h2("Correction and Filtering"), 
                         p("Once you have performed a MS/MS database search, we can correct and
                           filter the results."),
                         p("First we apply a correction of monoisotropic peaks. Then we define two filters:"),
                         tags$ol(
                           tags$li(strong("MS/MS Score threshold"), "- The MS/MS match score is the -10log of a probability, that
                                   the match between the experimental data and the database is a random event.If we expect a
                                   0.05 significance level (1/20), and we have 2000 peptides within the mass tolerance, that is P=1/(20*2000) and 
                                   the score threshold is 46 (-10log(P))."),
                           tags$li(strong("Mass measurement error"), "- Computes error of the parent ion mass to charge measurement.")
                           ),
                         
                        
                         
                         p("The result is a matrix with with column names", em("fdr"), "and", em("n"), "Column", em("n"),
                          "contains the number of features (spectra, peptides or proteins/accessions) passing 
                          the filter. Column", em("fdr"), "is the false discovery rate (i.e. identification confidence) for 
                          the corresponding features."), 
                         p("Choose the desired thresholds. Below you will see the results:"),
                         verbatimTextOutput("filtering_msnid_out"),
                         verbatimTextOutput("correct_filter_out"),
                         sliderInput("correction_msmsScore", label = h3("MS/MS Score"), min = 0, 
                                     max = 100, value = 5),
                         sliderInput("correction_ErrorPPM", label = h3("Parent Mass Error PPM"), min = 0, 
                                     max = 100, value = 10)

                         
        # close input.radiobuttons=='4'            
        ),

        # if user chooses the 5th choice "spectra raw data"
        conditionalPanel("input.radiobuttons=='5'",
                         h2("Spectra Raw Data with Identification"),
                         p("With the identification data generated in", strong("MS/MS database search"), 
                           "we can add this identifications to the raw data and extract and plot spectra and part
                           of experiments."),
                         p("For that, we need the identification file (mzID format), so please, if you didn't 
                           already do it, go to", strong("MS/MS database search"), "and generate the identification file."),
                         p("Also notice that while data is being read, the following error can appear:"),
                         code("error in evaluating the argument 'x' in selecting a method for function 'plot'"),
                         plotOutput('msexpIdentPlot'),
                         p("The total scans are:"),
                         verbatimTextOutput("msexp_length"),
                         p("You can plot up to 3 scans. The 3 numbers should be different. "),
                         numericInput("msexpIdentPlot_num1", 
                                      label = "1st Number of scan", 
                                      value = "1"),
                         numericInput("msexpIdentPlot_num2", 
                                      label = "2nd Number of scan", 
                                      value = "2"),
                         numericInput("msexpIdentPlot_num3", 
                                      label = "3rd Number of scan", 
                                      value = "3")

                       # close input.radiobuttons=='5'            
                       ),

        
        conditionalPanel("input.radiobuttons=='6'",
                         h2("Quantification"),
                         p("There are a wide range of proteomics quantitation techniques. Here we implement
                           a MS level 2 quantitation (MS2) where a method quantifies individual 'Spectrum' objects with MS2-level
                           isobar tagging using iTRAQ and TMT. "),
                         p("Also you can select a peak quantitation method. These methods are:"),
                         tags$ol(
                           tags$li(strong("Trapezoidation"), "- Returns the area under the peaks."),
                           tags$li(strong("Maximum"), "- Returns the maximum of the peaks"),
                           tags$li(strong("Sum"), "- Returns the sum of all intensities of the peaks.")
                           ),
                         p("The Bioconductor protocol uses method 'trapezoidation' and reporter 'iTRAQ4' with the PXD000001
                           data set."),
                         selectInput("quantif_method", label = h3("Select Peak Quantitation Method"), 
                                      choices = list("trapezoidation" = 1, 
                                                     "maximum" = 2, "sum" = 3), 
                                      selected = 1),
                         selectInput("quantif_reporter", label = h3("Select Reporter Ion"), 
                                    choices = list("iTRAQ4" = 1, "iTRAQ5" = 2, 
                                                   "TMT6" = 3, "TMT7" = 4), 
                                    selected = 1),
                         
                         helpText("Choose method and reporter and hit the button 'Calculate'. The following error may show up
                                  while calculating:"),
                         code("error in evaluating the argument 'object' in selecting a method for function"),
                         actionButton("quantif_button", label = "Calculate"),
                         verbatimTextOutput("calculateIfButton"),
                         
                         verbatimTextOutput("msset_out")
                         
                         # close input.radiobuttons=='6'
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
