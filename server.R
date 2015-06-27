###################################################
#   LARA MARTIN - proyecto final de posgrado      #
#   server.R                                      #
###################################################

# library that provides basic access to PX data sets
library(rpx)
# library that allows access to different MS file formats
library(mzR) 
# library MSnbase 
library(MSnbase)
# library for plotting
library(lattice)
#library for MS/MS database search
library(MSGFplus)
# library to generate identification files mzid 
library(mzID)
# library for filterin MS/MS identifications
library(MSnID)


# function that generates an identification file (choice 3 analysis)
mzIDfromFasta <- function(fasta, rawdata){
  # creates msgfPar object 
  msgfpar <- msgfPar(database = fasta,
                     instrument = 'HighRes',
                     tda = TRUE,
                     enzyme = 'Trypsin',
                     protocol = 'iTRAQ')
  # identification file
  idres <- runMSGF(msgfpar, rawdata, memory=1000)
  # identification file generated (.mzid)
  idres
}

# read the identification file and create an object
msnid_from_fasta <- function(mymzID){
  msnid_object <- MSnID(".")
  msnid_object <- read_mzIDs(msnid_object,
                             basename(mzID::files(mymzID)$id))
  msnid_object
}

# Define server logic required to run the MS-app
shinyServer(function(input, output) {
  
  
  ##########################################################
  #                 INPUT shinyserver()                    #  
  ##########################################################
  

  # get ID input by user
  dataInput <- reactive({
    input$datasetID
  })
  
  # get data set
  dataset <- reactive({
    # PXDataset(dataInput())
    
    # for development purposes, the dataset "PXD000001" is stored locally, 
    # so I avoid  downloading every time I execute the App 
    #       selectInput("datasetID", label="Choose a dataset:",
    #                   choices="PXD000001"),
    load(file="C:/Users/Lara/Dropbox/MASTER/4o_semestre/proyecto/PEC2_borrador/MS-app/dataset.save")
    variable
  })
  
  # show list files for data set 
  list_files <- reactive({
    pxfiles(dataset())
  })
  
  # show taxonomic name of organism
  tax_name <- reactive({
    pxtax(dataset())
  })
  
  # get number file written by user
  numberFile <- reactive({
    input$number_file
  })
  
  # get raw MS data file
  mzf <- reactive({
    mzf_path <- pxget(dataset(), pxfiles(dataset())[numberFile()])
    mzf_path
  })
  
  # read raw MS data file
  ms <- reactive({
    openMSfile(mzf())
  })
  
  
  ########################  analysis 1st choice - Scan Peaks  ########################
  
  # get scan written by user to plot
  scan <- reactive({
    input$numScan
  })
  
  # get info of MS data
  hd <- reactive({
    header(ms())
  }) 
  
  
  # which data is MS1 spectra                      
  ms1 <- reactive({           
    which(hd()$msLevel == 1)
  })
  
  
  ########################  analysis 2nd choice - Spectra Raw Data  ########################
  
  # min Retention Time values in Spectra Raw Data analysis
  minSpectraRT <- reactive({
    input$sliderSpectraRT[1]
  })
  
  # max Retention Time values in Spectra Raw Data analysis  
  maxSpectraRT <- reactive({
    input$sliderSpectraRT[2]
  })
  
  # min m/z ratio in Spectra Raw Data analysis 
  minSpectraMZ <- reactive({
    input$sliderSpectraMZ[1]
  })
  
  # max m/z ratio in Spectra Raw Data analysis 
  maxSpectraMZ <- reactive({
    input$sliderSpectraMZ[2]
  })
  
  # retention time of MS1 data
  rtselSpectra <- reactive({  
    # MS1 data with retention time chosen 
    # by user (slider) 
    hd()$retentionTime[ms1()] / 60 > minSpectraRT() & 
      hd()$retentionTime[ms1()] / 60 < maxSpectraRT()
  })
  
  # change resolution for plot according to m/z ratio range
  # chosen by user
  resolutionSpectra <- reactive({
    (maxSpectraMZ() - minSpectraMZ()) * 0.0025
  })
  
  
  # plot raw data map for scan chosen by user
  mapSpectra <- reactive({
    M <- MSmap(ms(), ms1()[rtselSpectra()], 
               lowMz = minSpectraMZ(), 
               highMz= maxSpectraMZ(), 
               resMz = resolutionSpectra(), 
               hd())
  })
  
  
  ########################  analysis 3rd choice - MS/MS database search  ########################
  
  # get fasta file from user
  fastafileinput <- reactive({
    input$fasta_file
  })
  
  # user needs to print files list and clicks the button
  buttonprintfiles <- reactive(if(input$print_files_list != 0) {
    list_files()
  })
  
  # get number of fasta file from list
  fastafilenum <- reactive({
    input$num_fastafile_choice4
    
  })
  
  # download fasta file when user inputs number
  download_fasta <- reactive({
    dataset <- PXDataset("PXD000001")
    pxget(dataset, pxfiles(dataset)[fastafilenum()])
    
  })
  
  # return fasta file path
  fasta_file_path <- reactive(
    # if user uploads fasta file
    if(is.null(input$fasta_file) != TRUE){ # <----- doesn't work
      # get datapath
      fasta_path <- input$fasta_file
      fasta_path
    }
    # or if 
    else if(input$num_fastafile_choice4 != ""){
      fasta_path <- download_fasta()
      fasta_path
    }
  )
  
  # call the mzIDfromFasta() implemented outside shinyServer() 
  # to generate an identification file with fasta file and raw data
  create_mzID <- reactive({
    mzid <- mzIDfromFasta(fasta_file_path(), mzf())
    mzid
  })
  
  #read identification file
  msnid <- reactive({
    msnid_from_fasta(create_mzID())
  })
  
  
  
  ########################  analysis 4th choice - Correction and Filtering  ########################
  
  # apply the standard correction as in Bioconductor workflow
  correction_msnid <- reactive({
    # correction 
    msnid_correct <- correct_peak_selection(msnid())
    msnid_correct$msmsScore <- -log10(msnid_correct$`MS-GF:SpecEValue`)
    msnid_correct$absParentMassErrorPPM <- abs(mass_measurement_error(msnid_correct))
    msnid_correct
    
  })
  
  # create a filter object with user's inputs
  filtering_msnid <- reactive({
    # filter
    filtObj <- MSnIDFilter(correction_msnid())
    filtObj$absParentMassErrorPPM <- list(comparison="<", threshold=input$correction_ErrorPPM)
    filtObj$msmsScore <- list(comparison=">", threshold=input$correction_msmsScore)
    filtObj
  })
  
  # apply the filter to corrected data
  evaluate_msnid <- reactive({
    evaluate_filter(correction_msnid(), filtering_msnid())
  })
  
  #################  analysis 5th choice - Spectra Raw Data with identification  ###############
  # get path to mzID ID file
  id_file_path <- reactive({
    basename(mzID::files(create_mzID())$id)
  })
  
  #  read raw data and generate object type msexp
  msexp <- reactive({
    readMSData(mzf(), verbose = FALSE)
  })
  
  # add ID data to msexp object
  msexpIdent <- reactive({ 
    addIdentificationData(msexp(), id_file_path())
  })
  
  
  #################  analysis 6th choice - Quantitification  ###############
  
  # get method selected by user
  method_num <- reactive(input$quantif_method)
  
  # get method selected by user
  reporter_num <- reactive(input$quantif_reporter)
  
  # from list of methods, return which one is 
  select_method <- reactive({
    method_list <- c("trap", "max", "sum")
    method_list[as.numeric(method_num())]
  })
  
  # from list of reporters, return which one is 
  select_reporter <- reactive({
    reporter_list <- c("iTRAQ4", "iTRAQ5", "TMT6", "TMT7")
    reporter_list[as.numeric(reporter_num())]
  })
  
  # quantify with method and reporter selected
  msset <- reactive(
    quantify(msexpIdent(), 
             method = select_method(), 
             reporters = select_reporter(), 
             verbose=FALSE)
  )
  
  ##########################################################
  #                 OUTPUT shinyserver()                   #  
  ##########################################################
  
  # ID written by user as output
  output$id <- renderText({
    dataInput()
  })
  
  # print object taxonomic name
  output$datasetInfo <- renderPrint({   
    dataset()
  })
  
  # print taxonomic name of object
  output$datasetTax <- renderPrint({   
    tax_name()
  })
  
  # print list of files available in data set
  output$datasetFiles <- renderPrint({   
    list_files()
  })
  
  # print MS data information
  output$msFileInfo <- renderPrint({
    ms()
  })
  
  # get which analysis has been chosen
  output$radiobuttons <- renderPrint({
    input$radiobuttons 
  })

  
  ########################  analysis 1st choice - Scan Peaks  ########################
  
  # plot peaks of raw data
  output$plotPeaks <- renderPlot({
    plot(peaks(ms(), scan()), type = "h")
  })

  ########################  analysis 2nd choice - Spectra Raw Data  ########################

  # show range min-max 
  output$rangeMinMaxMZ <- renderText({ 
    c(min(hd()$lowMZ[ms1()]), 
      max(hd()$highMZ[ms1()]))
  })  
  
  # a set of spectra of interest: MS1 spectra eluted
  output$spectraRawData <- renderPlot({
    ff <- colorRampPalette(c("firebrick1", "navyblue"))
    trellis.par.set(regions=list(col=ff(100)))
    plot(mapSpectra(), aspect = 1, allTicks = FALSE)
  })
  
  # a set of spectra of interest: MS1 spectra eluted - 3D plot
  output$spectraRawData3D <- renderPlot({
    plot3D(mapSpectra())
  })
  
  ########################  analysis  3rd choice - MS/MS database search  ########################
  
  # print list of files of data set
  output$files_out <- renderPrint({
    buttonprintfiles()
  })
  
  # show info of identification file generated
  output$id_info <- renderPrint({
    show(msnid())
  })
  
  ########################  analysis 4th choice - Correction and Filtering  ########################
  
  # show which filter has been applied
  output$filtering_msnid_out <- renderPrint({
    filtering_msnid()
  })
  
  # results from filtration
  output$correct_filter_out <- renderPrint({
    evaluate_msnid()
  })
  
  #################  analysis 5th choice - Spectra Raw Data with Identification  #################
  
  # plot desired scans of msexp object with identifications
  output$msexpIdentPlot <- renderPlot({
    plot(msexpIdent()[c(input$msexpIdentPlot_num1, 
                        input$msexpIdentPlot_num2,
                        input$msexpIdentPlot_num3)], 
         full=TRUE)
  })

  # print total number of scans available
  output$msexp_length <- renderText(
    length(msexp())
  )
  
  
  #################  analysis 6th choice - Quantification  #################
  
  # print results of quantification
  output$msset_out <- renderPrint(
    if(input$quantif_button){
      exprs(msset())
    }
  )
  
  ## end of shinyserver() function  
})


