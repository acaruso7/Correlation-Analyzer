library(shiny)

fluidPage(
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Choose CSV File",
                      accept = c("text/csv","text/comma-separated-values,text/plain",".csv")
            ),
            uiOutput("xvars"), # dropdowns for selecting variable names
            uiOutput("yvars")
        ),
        mainPanel(
            tableOutput("csv"),
            plotOutput("scatter")
        )
    )
)