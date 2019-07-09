library(shiny)
library(ggplot2)
library(reshape2)

function(input, output) {
    getData = reactive({
        inFile = input$file
        if (is.null(inFile)) {
            return(NULL) 
        }
        df = read.csv(inFile$datapath, header = TRUE)
        return(df)
    })
    
    output$xvars =
        renderUI({ # send list of available variable name choices to UI
            selectInput(inputId='selected_xvar', label="Select X Variable", choices=colnames(getData()), selected=input$selected_xvar)
        })
    output$yvars =
        renderUI({
            selectInput(inputId='selected_yvar', label="Select Y Variable", choices=colnames(getData()), selected=input$selected_yvar)
        })
    output$continuousVars = 
        renderUI({
            selectInput(inputId='selected_cont_vars', label="Select Continuous Variables", 
                        choices=colnames(getData()), multiple=TRUE, selected=colnames(getData()[1]))
        })
    
    output$scatter = renderPlot({
        selected_xvar = input$selected_xvar
        selected_yvar = input$selected_yvar

        df = getData()
        if (is.null(df)==FALSE) {
            req(selected_xvar, selected_yvar)
            ggplot(df, aes_string(x=selected_xvar, y=selected_yvar)) +
                geom_point(shape=1, col="blue") +
                geom_smooth(method=lm) + ggtitle("Scatterplot") + xlab(selected_xvar) + ylab(selected_yvar) +
                theme(plot.title = element_text(size=18, hjust=0.5))
        }
    })
    
    output$heatmap = renderPlot({
        selected_vars = input$selected_cont_vars

        df = getData()
        if (is.null(df)==FALSE) {
            req(selected_vars)
            features = df[,selected_vars]
            cormat <- round(cor(as.matrix(sapply(features, as.numeric)), use="pairwise.complete.obs"), 2)
            melted_cormat <- melt(cormat)
            ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) +
                ggtitle("Heatmap") + geom_tile()
        }
    })
}





