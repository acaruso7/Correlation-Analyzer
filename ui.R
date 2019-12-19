library(shiny)

fluidPage(
    titlePanel("Correlation Analyzer"),
    sidebarLayout(
        sidebarPanel(
            uiOutput("sampledata"),
            fluidRow(
                column(10,fileInput("file", "Input a CSV file",
                                   accept = c("text/csv","text/comma-separated-values,text/plain",".csv"))),
                column(2,actionButton("refresh", "Refresh", style="margin-top:24.5px"))
            ),
            h3("Map Variable Types"),
            wellPanel(
                fluidRow(
                    column(6, 
                        fluidRow(
                            h3("Variable"),
                            p(textOutput("allvars", container = pre))
                        )
                    ),
                    column(6, 
                        fluidRow(
                            h3("Type"),
                            # h4("test new row")
                            # p(textOutput("allvars2", container = pre))
                            uiOutput("dtypedropdowns")
                        )
                    )
                )
            )
            # ,
            # uiOutput("contvars"),
            # uiOutput("catvars")
        ),
        mainPanel(
            fluidRow(
                # SCATTERPLOT TOP LEFT
                column(6,
                       wellPanel(
                           fluidRow(
                               column(4, h2("Scatterplot", style="margin-top:5px; text-align:center;")),
                               column(4, uiOutput("xvars", style="margin-top:-10px")),
                               column(4, uiOutput("yvars", style="margin-top:-10px"))  
                           ),
                           fluidRow(
                               column(12, plotOutput("scatter", height="340px"))
                           )
                       ),
                       style="margin-top:5px; margin-bottom:-20px;"
                ),
                # PEARSON HEATMAP TOP RIGHT
                column(6,
                       wellPanel(
                           fluidRow(
                               column(5, h3("Heatmap: Pearson Correlation", style="margin-top:-5px; text-align:center;")),
                               column(7, uiOutput("pearsonHeatmapVars", style="margin-top:-10px"))
                           ),
                           fluidRow(
                               column(12, plotOutput("pearsonHeatmap", height="340px"))
                           )
                       ),
                       style="margin-top:5px; margin-bottom:-20px;"
                )
            ),
            fluidRow(
                # BAR CHART BOTTOM LEFT
                column(6,
                       wellPanel(
                           fluidRow(
                               column(3, h3("Correlation Ratios", style="margin-top:-5px; text-align:center;")),
                               column(4, uiOutput("contcorrvar", style="margin-top:-10px")),
                               column(5, uiOutput("catcorrvars", style="margin-top:-10px"))
                           ),
                           fluidRow(
                               column(12, plotOutput("barchart", height="340px"))
                           )
                       ),
                       style="margin-top:15px;"
                ),
                # KRAMER'S V BOTTOM RIGHT
                column(6,
                       wellPanel(
                           fluidRow(
                               column(5, h3("Heatmap: Cramer's V Statistic", style="margin-top:-5px; text-align:center;")),
                               column(7, uiOutput("kramersHeatmapVars", style="margin-top:-10px"))
                           ),
                           fluidRow(
                               column(12, plotOutput("kramersHeatmap", height="340px"))
                           )
                       ),
                       style="margin-top:15px;"
                )
            ),
            style="margin-top:-50px;"
        )
    )
)