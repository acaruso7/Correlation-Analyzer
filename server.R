library(shiny)
library(ggplot2)

function(input, output) {
    getData = reactive({
        inFile = input$file
        if (is.null(inFile)) {
            return(NULL) 
        }
        df = read.csv(inFile$datapath, header = TRUE)
        return(df)
    })
    
    output$dataHead = renderTable({
        return(head(getData()))
    })
    output$xvars =
        renderUI({ # send list of available variable name choices to UI
            selectInput(inputId='selected_xvar', label="Select X Variable", choices=colnames(getData()), selected=input$selected_xvar)
        })
    output$yvars =
        renderUI({
            selectInput(inputId='selected_yvar', label="Select Y Variable", choices=colnames(getData()), selected=input$selected_yvar)
        })
    
    output$scatter = renderPlot({
        selected_xvar = input$selected_xvar
        selected_yvar = input$selected_yvar

        df = getData()
        if (is.null(df)==FALSE) {
            ggplot(df, aes_string(x=selected_xvar, y=selected_yvar)) +
                geom_point(shape=1, col="blue") +
                geom_smooth(method=lm) + ggtitle("Scatterplot") + xlab(selected_xvar) + ylab(selected_yvar) +
                theme(plot.title = element_text(size=18, hjust=0.5))
            
            # plot(unlist(df[selected_xvar]), unlist(df[selected_yvar]), main="Scatterplot", 
            #      xlab=selected_xvar, ylab=selected_yvar, pch=19)
        }
    })
}





