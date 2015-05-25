################################
#   LARA MARTIN - proyecto final de posgrado
# server.R
################################


# setwd("C:/Users/lara/Dropbox/MASTER/4o_semestre/proyecto/PEC2_borrador/")
# library(shiny)
# runApp("MS-app", display.mode = "showcase")

# another data set with a mzML file PXD000790


library(shiny)
# library that provides basic access to PX data sets
library(rpx)
# library that allows access to different MS file formats
library(mzR) 
# library MSnbase 
library(MSnbase)
# library for plotting
library(lattice)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  
  ########################    INPUT   ######################  
  
  # get ID input by user
  dataInput <- reactive({
    input$datasetID
  })
   
  dataset <- reactive({
#     PXDataset(input$datasetID)
    load(file="dataset.save")
    variable
  })
   
  list_files <- reactive({
    pxfiles(dataset())
  })
  
  tax_name <- reactive({
    pxtax(dataset())
  })
   
  numberFile <- reactive({
    input$number_file
  })
  
  mzf <- reactive({
    pxget(dataset(), pxfiles(dataset())[numberFile()])
  })
  
  ms <- reactive({
    openMSfile(mzf())
  })
  
  scan <- reactive({
    input$numScan
  })

  hd <- reactive({
    header(ms())
  }) 
    
  
                        
  ms1 <- reactive({           #### <-----------------------------------REACTIVE????
    which(hd()$msLevel == 1)
  })
  
  # min and max Retention Time values in Spectra Raw Data analysis (2nd choice in radiobuttons)
  minSpectraRT <- reactive({
    input$sliderSpectraRT[1]
  })
  maxSpectraRT <- reactive({
    input$sliderSpectraRT[2]
  })
  
  rtselSpectra <- reactive({  
    ## a set of spectra of interest: MS1 spectra eluted
    ## between 30 and 35 minutes retention time
    hd()$retentionTime[ms1()] / 60 > minSpectraRT() & 
      hd()$retentionTime[ms1()] / 60 < maxSpectraRT()
  })
  
  # min and max m/z ratio in Spectra Raw Data analysis (2nd choice in radiobuttons)
  minSpectraMZ <- reactive({
    input$sliderSpectraMZ[1]
  })
  maxSpectraMZ <- reactive({
    input$sliderSpectraMZ[2]
  })
  
  resolutionSpectra <- reactive({
    (maxSpectraMZ() - minSpectraMZ()) * 0.0025
  })
  
  mapSpectra <- reactive({
    M <- MSmap(ms(), ms1()[rtselSpectra()], 
               lowMz = minSpectraMZ(), 
               highMz= maxSpectraMZ(), 
               resMz = resolutionSpectra(), 
               hd())
  })
  
  
  ########################  OUTPUT    ########################
  
  
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
  
  output$plotPeaks <- renderPlot({
    plot(peaks(ms(), scan()), type = "h")
  })
  
  
  output$hd <- renderPrint({
    hd()
  })
  
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
  
})