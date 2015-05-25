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
    pxget(px, pxfiles(px)[numberFile()])
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
  
  # min and max values in Spectra Raw Data analysis (2nd choice in radiobuttons)
  minSpectra <- reactive({
    input$sliderSpectra[1]
  })
  maxSpectra <- reactive({
    input$sliderSpectra[2]
  })
  
  rtselSpectra <- reactive({  
    ## a set of spectra of interest: MS1 spectra eluted
    ## between 30 and 35 minutes retention time
    rtsel <- hd()$retentionTime[ms1()] / 60 > minSpectra() & #"input$sliderSpectra[1]"
      hd()$retentionTime[ms1()] / 60 < maxSpectra() #"input$sliderSpectra[2]"
  })
  
  mapSpectra <- reactive({
    M <- MSmap(ms(), ms1()[rtselSpectra()], 521, 523, .005, hd())
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

  
  output$rangeMax <- renderText({
    max(hd()$retentionTime[ms1()])
  })
  
  output$rangeMin <- renderText({ #### <-----------------------------------NECESSARY OR ZERO????
    min(hd()$retentionTime[ms1()])
  })  

  output$minslider <- renderText({
    minSpectra()
  })
  
  # a set of spectra of interest: MS1 spectra eluted
  output$spectraRawData <- renderPlot({
    ff <- colorRampPalette(c("red", "steelblue"))
    trellis.par.set(regions=list(col=ff(100)))
    plot(mapSpectra(), aspect = 1, allTicks = FALSE)
  })

  output$spectraRawData3D <- renderPlot({
    plot3D(mapSpectra())
  })
  
  output$spectra2RawData <- renderPlot({
    ## With some MS2 spectra
    i <- ms1()[which(rtselSpectra())][1]
    j <- ms1()[which(rtselSpectra())][2]
    M2 <- MSmap(ms(), i:j, 100, 1000, 1, hd())
    plot3D(M2)
  })
  
})