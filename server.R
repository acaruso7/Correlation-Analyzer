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
    
    output$contvars =
        renderUI({
            selectInput(inputId='contvars', label="Select Continuous & Ordinal Variables", multiple=TRUE, choices=colnames(getData()))
        })
    output$catvars =
        renderUI({
            choices = c()
            for (var in colnames(getData())) {
                if (!(var %in% input$contvars)) {
                    choices = c(choices, var)
                }
            }
            selectInput(inputId='catvars', label="Select Nominal Categorical Variables", multiple=TRUE, choices=choices)
        })
    
    output$heatmapVars = 
        renderUI({
            if(input$corrType=='Continuous - Continuous (Pearson)') {
                selectInput(inputId='heatmap_vars', label="Select Continuous Variables", 
                            choices=input$contvars, multiple=TRUE, selected=input$contvars[1:2])
            } else {
                selectInput(inputId='heatmap_vars', label="Select Nominal Categorical Variables", 
                            choices=input$catvars, multiple=TRUE, selected=input$catvars[1:2])
            }
        })
    output$corrTypeTitle =
        renderUI({
            if(input$corrType=='Continuous - Continuous (Pearson)') {
                h3("Heatmap: Pearson Correlation")
            } else if(input$corrType=="Categorical - Categorical (Kramer's V)") {
                h3("Heatmap: Cramer's V Statistic")
            }
        })
    
    output$scatter = renderPlot({
        selected_xvar = input$selected_xvar
        selected_yvar = input$selected_yvar

        df = getData()
        if (is.null(df)==FALSE) {
            req(selected_xvar, selected_yvar)
            ggplot(df, aes_string(x=selected_xvar, y=selected_yvar)) +
                geom_point(shape=1, col="blue") +
                geom_smooth(method=lm) + xlab(selected_xvar) + ylab(selected_yvar)
        }
    })
    
    output$heatmap = renderPlot({
        selected_vars = input$heatmap_vars

        df = getData()
        if (is.null(df)==FALSE) {
            req(selected_vars)
            features = df[,selected_vars]
            if (input$corrType=='Continuous - Continuous (Pearson)') {
                cormat <- round(cor(as.matrix(sapply(features, as.numeric)), use="pairwise.complete.obs"), 2)
                melted_cormat <- melt(cormat)
                ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + geom_tile()
            } else {
                
            }
        }
    })
}





