library(shiny)

fluidPage(
    titlePanel("Correlation Analyzer"),
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Choose Clean CSV File to Analyze (must include headers)",
                      accept = c("text/csv","text/comma-separated-values,text/plain",".csv")
            ),
            uiOutput("xvars"), # dropdowns for selecting variable names
            uiOutput("yvars"),
            checkboxGroupInput(inputId='corrType', label="Correlation Type", 
                               choices=c('Continuous - Continuous (Pearson)', "Categorical - Categorical (Kramer's V)", 
                                         'Continuous - Categorical (Correlation Ratio)'), 
                               selected = NULL, inline = FALSE, width = NULL),
            uiOutput("continuousVars")
        ),
        mainPanel(
            plotOutput("scatter"),
            plotOutput("heatmap")
        )
    )
)