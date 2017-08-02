#' Run fastQC shiny app
#'
#' @description Returns a shiny app interface to parse many fastQC objects
#'
#' @details Currently some plots can take a while to render if the \code{FastqcDataList} passed to
#' \code{fastqcInput} has many elements
#'
#' @param fastqcInput can be a \code{FastqcFileList}, \code{fastqcDataList},
#' or simply a \code{character} vector of paths to fastqc files.
#' @param subsetAll a \code{character} vector of length 1 to subset all files input into shiny app by
#'
#' @import shiny
#' @import plotly
#'
#' @return UI data for fastQC shiny.
#'
#' @export
#' @rdname fastqcShiny


fastqcShiny <- function(fastqcInput, subsetAll = ""){

  if(class(fastqcInput) != "FastqcDataList"){
    fdl <- ngsReports::getFastqcData(fastqcInput)
  }
  if(class(fastqcInput) == "FastqcDataList"){
    fdl <- fastqcInput
  }

  ui <- shiny::shinyUI(shiny::fluidPage(
    shiny::navbarPage("fastqcR",
                      #first panel is summary
                      shiny::tabPanel("fastQC Flags Summary",
                                      shiny::splitLayout(
                                        shiny::fixedPanel(
                                          shiny::sidebarPanel(
                                            shiny::textInput("sub",
                                                             "Pattern to subset data",
                                                             value = ""),
                                            width = "20%", left = "0%", right = "80%"
                                          ), width = "20%"),
                                        shiny::absolutePanel(
                                          shiny::h1("Summary of fastQC Flags"),
                                          shiny::h5("Heatmap of fastQC flags (pass, warning or fail) for each fastQC report"),
                                          plotly::plotlyOutput("SummaryFlags"),
                                          width = "70%", left = "30%", right = "0%"))),
                      shiny::tabPanel("Total Reads",
                                      shiny::splitLayout(
                                        shiny::fixedPanel(
                                          shiny::sidebarPanel(
                                            shiny::textInput("sub",
                                                             "Pattern to subset data",
                                                             value = ""),
                                            shiny::radioButtons(inputId="RDLbar", label="Bar presentation",
                                                                choices=c("stacked","adjacent"), selected = "stacked"),
                                            width = "20%", left = "0%", right = "80%"
                                          ), width = "20%"),
                                        shiny::absolutePanel(
                                          shiny::h1("Duplication levels in reads"),
                                          shiny::h5("Total number of unique and duplicated reads in each sample"),
                                          plotly::plotlyOutput("ReadDuplication"),
                                          width = "70%", left = "30%", right = "0%"))),
                      shiny::tabPanel("% GC Content",
                                      shiny::splitLayout(
                                        shiny::fixedPanel(
                                          shiny::sidebarPanel(
                                            shiny::textInput("sub",
                                                             "Pattern to subset data",
                                                             value = ""),
                                            shiny::checkboxInput("GCtheory", "Normalize using theoretical GC", value = FALSE),
                                            shiny::htmlOutput("GCspecies"),
                                            shiny::radioButtons(inputId="GCheatType", label="Value to plot",
                                                                choices=c("Count","Frequency"), selected = "Frequency"),
                                            shiny::checkboxInput("GCcluster", "Cluster Filenames", value = FALSE),
                                            width = "20%", left = "0%", right = "80%"
                                          ), width = "20%"),
                                        shiny::absolutePanel(
                                          shiny::h1("GC content in reads"),
                                          shiny::h5("GC content (%) in sample, can either view total count or frequency"),
                                          plotly::plotlyOutput("GCheatmap"),
                                          width = "70%", left = "30%", right = "0%"))),
                      shiny::tabPanel("Overrepresented Sequences",
                                      shiny::splitLayout(
                                        shiny::fixedPanel(
                                          shiny::sidebarPanel(
                                            shiny::textInput("sub",
                                                             "Pattern to subset data",
                                                             value = ""),
                                            shiny::radioButtons(inputId="ORType", label="Individual or Overall",
                                                                choices=c("Individual","Overall"), selected = "Overall"),
                                            shiny::checkboxInput("ORcluster", "Cluster Filenames", value = FALSE),
                                            shiny::sliderInput("ORslide", "Number of seq", min = 1, max = 20, value = 10),
                                            width = "20%", left = "0%", right = "80%"
                                          ), width = "20%"),
                                        shiny::absolutePanel(
                                          shiny::h1("Overrepresented Sequences"),
                                          shiny::h5("Overrepresented sequences in each sample, can either view sequence on an individual or overall basis"),
                                          plotly::plotlyOutput("overRepHeatmap"),
                                          width = "70%", left = "30%", right = "0%"))),
                      shiny::tabPanel("Per Base Sequence Quality",
                                      shiny::splitLayout(
                                        shiny::fixedPanel(
                                          shiny::sidebarPanel(
                                            shiny::textInput("sub",
                                                             "Pattern to subset data",
                                                             value = ""),
                                            shiny::radioButtons(inputId="BQType", label="Base Quality",
                                                                choices=c("Mean","Median"), selected = "Mean"),
                                            shiny::checkboxInput("BQcluster", "Cluster Filenames", value = FALSE),
                                            shiny::htmlOutput("BQdendro"),
                                            shiny::selectInput("BQheight", "Plot Height", choices = c("auto", 250, 500, 1000)),
                                            shiny::verbatimTextOutput('click'),
                                            width = "20%", left = "0%", right = "80%"
                                          ), width = "20%"),
                                        shiny::absolutePanel(
                                          shiny::h1("Base Quality"),
                                          shiny::h5("Per base sequence quality in each sample, can either view mean or median for each cycle"),
                                          plotly::plotlyOutput("baseQualHeatmap"),
                                          shiny::plotOutput("baseQualIndv"),
                                          width = "70%", left = "30%", right = "0%"))),
                      shiny::tabPanel("% N-Content",
                                      shiny::splitLayout(
                                        shiny::fixedPanel(
                                          shiny::sidebarPanel(
                                            shiny::textInput("sub",
                                                             "Pattern to subset data",
                                                             value = ""),
                                            shiny::checkboxInput("Ncluster", "Cluster Filenames", value = FALSE),
                                            width = "20%", left = "0%", right = "80%"
                                          ), width = "20%"),
                                        shiny::absolutePanel(
                                          shiny::h1("N content in reads"),
                                          shiny::h5("N content (%) in sample"),
                                          plotly::plotlyOutput("NCheatmap"),
                                          width = "70%", left = "30%", right = "0%")))
    )


  ))

  server <- function(input, output){
    output$SummaryFlags <- plotly::renderPlotly({
      plotly:subplot(ngsReports::plotSummary(fdl)) %>% plotly::layout(margin = list(r = 200), xaxis=list(
        autorange=TRUE,
        showgrid=FALSE,
        zeroline=FALSE,
        showline=FALSE,
        autotick=FALSE,
        ticks='',
        showticklabels=FALSE
      ),
      yaxis=list(
        autorange=TRUE,
        showgrid=FALSE,
        zeroline=FALSE,
        showline=FALSE,
        autotick=FALSE,
        ticks='',
        showticklabels=FALSE
      ))
    })


    output$ReadDuplication <- plotly::renderPlotly({
      ngsReports::plotDeduplicatedTotalsPlotly(fdl,
                                         subset = grepl(input$sub,
                                                        fileNames(fdl)),
                                         bars = input$RDLbar) %>% plotly::layout(margin = list(r = 200))

    })

    output$GCspecies <- shiny::renderUI({
      if(input$GCtheory){
        shiny::selectInput("GCspecies", "Select species for Theoretical GC",
                           choices = ngsReports::genomes(ngsReports::gcTheoretical),
                           selected = "Hsapiens")
      }
    })


    output$GCheatmap <- plotly::renderPlotly({
      GCtype <- input$GCheatType == "Count"
      ngsReports::plotGCHeatmapPlotly(fdl,
                                subset = grepl(input$sub,
                                               fileNames(fdl)),
                                clusterNames = input$GCcluster,
                                counts = GCtype,
                                GCtheory = input$GCtheory,
                                species = input$GCspecies
      ) %>% plotly::layout(margin = list(r = 200))

    })

    output$overRepHeatmap <- plotly::renderPlotly({
      ngsReports::plotOverrepresentedHeatmapPlotly(fdl,
                                             subset = grepl(input$sub,
                                                            fileNames(fdl)),
                                             clusterNames = input$ORcluster,
                                             method = input$ORType,
                                             nSeq = input$ORslide) %>% layout(margin = list(r = 200))
    })

    output$BQdendro <- shiny::renderUI({
      if(input$BQcluster) {
        checkboxInput("BQdendro", "plot Dendrogram", value = FALSE)
      }
    })

    output$baseQualHeatmap <- plotly::renderPlotly({
      ngsReports::plotBaseQualitiesPlotly(fdl,
                                          subset = grepl(input$sub,
                                                         fileNames(fdl)),
                                          clusterNames = input$BQcluster,
                                          type = input$BQType,
                                          setHeight = input$BQheight,
                                          dendrogram = input$BQdendro) %>% layout(margin = list(r = 200))
    })

    output$click <- shiny::renderPrint({d <- plotly::event_data("plotly_click")
    d$key[[1]]
    })

    output$baseQualIndv <- shiny::renderPlot({
      click <- plotly::event_data("plotly_click")
      key <- click$key[[1]]

      if(!is.null()){ngsReports::plotBaseQualities(FastqcFile())}
    })

    output$NCheatmap <- plotly::renderPlotly({
      ngsReports::plotNContentPlotly(fdl,
                               subset = grepl(input$sub,
                                              fileNames(fdl)),
                               clusterNames = input$Ncluster) %>% plotly::layout(margin = list(r = 200))
    })
  }

  shinyApp(ui = ui, server = server)
}
