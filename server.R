library(shiny)
library(ggplot2)

function(input, output) {
    output$csv = renderTable({
        inFile = input$file
        if (is.null(inFile))
            return(NULL)
        df = read.csv(inFile$datapath, header = TRUE)

        output$xvars = 
            renderUI({ # send list of available variable name choices to UI
                selectInput(inputId='selected_xvar', label="Select X Variable", choices=colnames(df), selected=input$selected_xvar)
            })
        output$yvars = 
            renderUI({
                selectInput(inputId='selected_yvar', label="Select Y Variable", choices=colnames(df), selected=input$selected_yvar)
            })
        selected_xvar = input$selected_xvar
        selected_yvar = input$selected_yvar

        output$scatter = renderPlot({
            plot(unlist(df[selected_xvar], use.names=FALSE), unlist(df[selected_yvar], use.names=FALSE), main="Scatterplot", 
                 xlab=selected_xvar, ylab=selected_yvar, pch=19, col="blue")
        })
    })
}





