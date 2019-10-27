library(shiny)

fluidPage(
    titlePanel("Correlation Analyzer"),
    sidebarLayout(
        sidebarPanel(
            uiOutput("sampledata"),
            fluidRow(
                column(10,fileInput("file", "Input your own CSV file",
                                   accept = c("text/csv","text/comma-separated-values,text/plain",".csv"))),
                column(2,actionButton("refresh", "Refresh", style="margin-top:24.4px"))
            ),
            uiOutput("contvars"),
            uiOutput("catvars"),
            radioButtons(inputId='corrType', label="Correlation Type", 
                               choices=c('Continuous - Continuous (Pearson)', "Categorical - Categorical (Kramer's V)", 
                                         'Continuous - Categorical (Correlation Ratio)'))
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
                               column(12, plotOutput("scatter", height="350px"))
                           )
                       ),
                       style="margin-bottom:-20px;"
                ),
                # HEATMAP TOP RIGHT
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
                # BAR CHART BOTTOM LEFT
                column(6,
                       wellPanel(
                           fluidRow(
                               column(3, h3("Correlation Ratios", style="margin-top:-5px; text-align:center;")),
                               column(4, uiOutput("contcorrvar", style="margin-top:-10px")),
                               column(5, uiOutput("catcorrvars", style="margin-top:-10px"))
                           ),
                           fluidRow(
                               column(12, plotOutput("barchart", height="350px"))
                           )
                       ),
                       style="margin-top:-10px;"
                ),
                # ANOVA BOTTOM RIGHT
                column(6,
                       wellPanel(

                       ),
                       style="margin-top:-10px;"
                )
            ),
            style="margin-top:-50px;"
        )
    )
)