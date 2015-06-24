###################################################
#   LARA MARTIN - proyecto final de posgrado      #
#   server.R                                      #
###################################################


# setwd("C:/Users/Lara/Dropbox/MASTER/4o_semestre/proyecto/PEC2_borrador/")
# library(shiny)
# runApp("MS-app", display.mode = "showcase")

# library that provides basic access to PX data sets
library(rpx)
# library that allows access to different MS file formats
library(mzR) 
# library MSnbase 
library(MSnbase)
# # library for plotting
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
    if(is.null(input$fasta_file) != TRUE){ # <----- NO FUNCIONA
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
  
  correction_msnid <- reactive({
    # correction 
    msnid_correct <- correct_peak_selection(msnid())
    msnid_correct$msmsScore <- -log10(msnid_correct$`MS-GF:SpecEValue`)
    msnid_correct$absParentMassErrorPPM <- abs(mass_measurement_error(msnid_correct))
    msnid_correct
    
  })
  
  filtering_msnid <- reactive({
    # filter
    filtObj <- MSnIDFilter(correction_msnid())
    filtObj$absParentMassErrorPPM <- list(comparison="<", threshold=input$correction_ErrorPPM)
    filtObj$msmsScore <- list(comparison=">", threshold=input$correction_msmsScore)
    filtObj
  })
  
  evaluate_msnid <- reactive({
    evaluate_filter(correction_msnid(), filtering_msnid())
  })
  
  
  
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
  
  
  output$radiobuttons <- renderPrint({
    input$radiobuttons 
  })
  
  
  ########################  analysis 1st choice - Scan Peaks  ########################
  
  # plot peaks of raw data
  output$plotPeaks <- renderPlot({
    plot(peaks(ms(), scan()), type = "h")
  })
  
  
  #   output$hd <- renderPrint({
  #     hd()
  #   })
  
  ########################  analysis 2nd choice - Spectra Raw Data  ########################
  
  
  #   output$range <- renderPrint({ 
  #     input$sliderSpectra 
  #     })
  
  
  #   output$rangeMax <- renderText({
  #     max(hd()$retentionTime[ms1()])
  #   })
  #   
  #   output$rangeMin <- renderText({ #### <-----------------------------------NECESSARY OR ZERO????
  #     min(hd()$retentionTime[ms1()])
  #   })  
  
  #   output$minslider <- renderText({
  #     minSpectra()
  #   })
  
  
  output$rangeMaxMZ <- renderText({
    max(hd()$highMZ[ms1()])
  })
  
  output$rangeMinMZ <- renderText({ 
    min(hd()$lowMZ[ms1()])
  })  
  
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
  
  output$spectraRawData3D <- renderPlot({
    plot3D(mapSpectra())
  })
  
  #  # plot with MS1 and some MS2 data
  #   output$spectra2RawData <- renderPlot({
  #     ## With some MS2 spectra
  #     i <- ms1()[which(rtselSpectra())][1]
  #     j <- ms1()[which(rtselSpectra())][2]
  #     M2 <- MSmap(ms(), i:j, 100, 1000, 1, hd())
  #     plot3D(M2)
  #   })
  
  
  ########################  analysis  3rd choice - MS/MS database search  ########################
  
  output$files_out <- renderPrint({
    buttonprintfiles()
  })
  
  output$fasta_printnum <- renderPrint({
    fasta_file_path()
  })
  
  output$id_info <- renderPrint({
    show(msnid())
  })
  
  
  
  ########################  analysis 4th choice - Correction and Filtering  ########################
  
  output$filtering_msnid_out <- renderPrint({
    filtering_msnid()
  })
  
  output$correct_filter_out <- renderPrint({
    evaluate_msnid()
  })
  
  
  
  
  
  
  
  
  
  ## end of shinyserver() function  
})


