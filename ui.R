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
            column(6,
                wellPanel(
                    h3("Scatterplot"),
                    fluidRow(
                        column(6, uiOutput("xvars")),
                        column(6, uiOutput("yvars"))  
                    ),
                    fluidRow(
                        column(12, plotOutput("scatter"))
                    )
                )
            ),
            column(6,
                wellPanel(
                    uiOutput("corrTypeTitle"),
                    uiOutput("heatmapVars"),
                    plotOutput("heatmap")   
                )
            )
        )
    )
)