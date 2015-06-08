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
# library for filterin MS/MS identifications
library(MSnID)






# Define server logic required to draw a histogram
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
     PXDataset(dataInput())
    # load(file="MS-app/dataset.save")
    # variable
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
    pxget(dataset(), pxfiles(dataset())[numberFile()])
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
  
  
  
  ########################  analysis 3rd choice - Correction and Filtering  ########################
  
  # MS/MS database search (3rd choice)
  MSMSsearch <- reactive({
    
    # get fasta file
    fas <- pxget(dataset(), pxfiles(dataset())[10])
    
    # creates msgfPar object 
    msgfpar <- msgfPar(database = fas,
                       instrument = 'HighRes',
                       tda = TRUE,
                       enzyme = 'Trypsin',
                       protocol = 'iTRAQ')
    # identification file
    idres <- runMSGF(msgfpar, mzf, memory=1000)
    
    # create an MSnID object
    msnid <- MSnID(".")
    # read mzIDs from mzid file
    msnid <- read_mzIDs(msnid,
                        basename(mzID::files(idres)$id))
    # return 
    msnid
  })
  
  
  
  # NOT IMPLEMENTED YET
  
  correct_filter <- reactive({
    # correction 
    MSMSsearch() 
    msnid_correct <- correct_peak_selection(msnid)
    msnid_correct$msmsScore <- -log10(msnid_correct$`MS-GF:SpecEValue`)
    msnid_correct$absParentMassErrorPPM <- abs(mass_measurement_error(msnid_correct))
    
    # filter
    filtObj <- MSnIDFilter(msnid_correct)
    filtObj$absParentMassErrorPPM <- list(comparison="<", threshold=5.0)
    filtObj$msmsScore <- list(comparison=">", threshold=8.0)
    filtObj
    
    evaluate_filter(msnid_correct, filtObj)
    
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
  
  ########################  analysis 3rd choice - Correction and Filtering  ########################
  
  output$MSMSsearch_out <- renderText({
    MSMSsearch()
  })
  
})