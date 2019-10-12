library(shiny)

fluidPage(
    titlePanel("Correlation Analyzer"),
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Choose Clean CSV File to Analyze (must include headers)",
                      accept = c("text/csv","text/comma-separated-values,text/plain",".csv")
            ),
            uiOutput("contvars"),
            uiOutput("catvars"),
            radioButtons(inputId='corrType', label="Correlation Type", 
                               choices=c('Continuous - Continuous (Pearson)', "Categorical - Categorical (Kramer's V)", 
                                         'Continuous - Categorical (Correlation Ratio)'))
        ),
        mainPanel(
            fluidRow(
                column(6,
                       wellPanel(
                           fluidRow(
                               column(4, h2("Scatterplot", style="margin-top:5px; text-align:center;")),
                               column(4, uiOutput("xvars", style="margin-top:-10px")),
                               column(4, uiOutput("yvars", style="margin-top:-10px"))  
                           ),
                           fluidRow(
                               column(12, plotOutput("scatter", height="350px"))
                           )
                       )
                ),
                column(6,
                       wellPanel(
                           fluidRow(
                               column(5, uiOutput("corrTypeTitle")),
                               column(7, uiOutput("heatmapVars", style="margin-top:-10px"))
                           ),
                           fluidRow(
                               column(12, plotOutput("heatmap", height="350px"))
                           )
                       )
                )
            ),
            fluidRow(
                column(6,
                       wellPanel(
                           fluidRow(
                               column(4, h3("Correlation Ratios", style="margin-top:5px; text-align:center;")),
                               column(4, uiOutput("contcorrvar", style="margin-top:-10px")),
                               column(4, uiOutput("catcorrvars", style="margin-top:-10px"))
                           ),
                           fluidRow(
                               column(12, plotOutput("barchart", height="350px"))
                           ),
                           style="padding:-50px;"
                       )
                ),
                column(6,
                       wellPanel(

                       )
                )
            ),
            style="margin-top:-50px;"
        )
    )
)