rm(list=ls())
setwd("~/dev/R/shiny_apps/Correlation-Analyzer")
library(shiny)
library(ggplot2)
library(reshape2)
library(lsr)


function(input, output, session) {
    output$sampledata =
        renderUI({
            selectInput(inputId='sampledata', 
                        label="Load a sample dataset", 
                        multiple=FALSE, 
                        choices=c("King's County Housing Data", "Boston Housing Data"))
        })
    
    loadSampleData = reactive({
        req(input$sampledata)
        if (input$sampledata=="King's County Housing Data") {
            df = read.csv("https://raw.githubusercontent.com/acaruso7/Correlation-Analyzer/grid_layout/data/kc_house_data.csv", header=TRUE)
        } else if (input$sampledata=="Boston Housing Data") {
            df = read.table("https://raw.githubusercontent.com/acaruso7/Correlation-Analyzer/grid_layout/data/boston_housing.csv", header = FALSE, sep = "")
            colnames(df) = c("CRIM","ZN","INDUS","CHAS","NAX","RM","AGE","DIS","RAD","TAX","PTRATIO","B","LSTAT","MEDV")
        }
        return(df)
    })
    
    getData = reactive({
        inFile = input$file
        if (is.null(input$file)) {
            df = loadSampleData()
        } else {
            df = read.csv(inFile$datapath, header = TRUE)
        }
        return(df)
    })
    
    observeEvent(input$refresh, {
        session$reload()
    })

    
    # inputs for all plots
    output$contvars =
        renderUI({
            df = getData()
            req(df)
            selectInput(inputId='contvars', label="Select Continuous & Ordinal Variables", multiple=TRUE, choices=colnames(df))
        })
    output$catvars =
        renderUI({
            df = getData()
            req(df)
            choices = c()
            for (var in colnames(df)) {
                if (!(var %in% input$contvars)) {
                    choices = c(choices, var)
                }
            }
            selectInput(inputId='catvars', label="Select Nominal Categorical Variables", multiple=TRUE, choices=choices)
        })
    
    
    # inputs for scatterplot
    output$xvars =
        renderUI({ # send list of available variable name choices to UI
            df = getData()
            req(df)
            selectInput(inputId='selected_xvar', label="X Variable", choices=colnames(df), selected=input$selected_xvar)
        })
    output$yvars =
        renderUI({
            df = getData()
            req(df)
            selectInput(inputId='selected_yvar', label="Y Variable", choices=colnames(df), selected=input$selected_yvar)
        })
    
    output$scatter = renderPlot({
        df = getData()
        req(df)
        
        features = colnames(df)
        
        selected_xvar = input$selected_xvar
        selected_yvar = input$selected_yvar
        req(selected_xvar, selected_yvar)
        
        if (is.null(df)==FALSE) {
            if (selected_xvar %in% features & selected_yvar %in% features) {
                ggplot(df, aes_string(x=selected_xvar, y=selected_yvar)) +
                    geom_point(shape=1, col="blue") +
                    geom_smooth(method=lm) + xlab(selected_xvar) + ylab(selected_yvar)
            }
        }
    })
    
    
    # inputs for heatmaps
    output$heatmapVars = 
        renderUI({
            if(input$corrType=='Continuous - Continuous (Pearson)') {
                selectInput(inputId='heatmap_vars', label="Continuous Variables", 
                            choices=input$contvars, multiple=TRUE, selected=input$contvars[1:2])
            } else {
                selectInput(inputId='heatmap_vars', label="Nominal Categorical Variables", 
                            choices=input$catvars, multiple=TRUE, selected=input$catvars[1:2])
            }
        })
    output$corrTypeTitle =
        renderUI({
            if(input$corrType=='Continuous - Continuous (Pearson)') {
                h3("Heatmap: Pearson Correlation", style="margin-top:-5px; text-align:center;")
            } else if(input$corrType=="Categorical - Categorical (Kramer's V)") {
                h3("Heatmap: Cramer's V Statistic", style="margin-top:-5px; text-align:center;")
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
    
    
    # inputs for barchart
    output$contcorrvar = 
        renderUI({
            selectInput(inputId='contcorrvar', label="Continuous Variable", choices=input$contvars, selected=input$contvars)
        })
    output$catcorrvars = 
        renderUI({
            selectInput(inputId='catcorrvars', label="Categorical Variables", multiple=TRUE,
                        choices=input$catvars, selected=input$catvars[1:3])
        })
    
    output$barchart = renderPlot({
        cont_var = input$contcorrvar
        cat_corr_vars = input$catcorrvars
        
        df = getData()
        if (is.null(df)==FALSE) {
            req(cont_var, cat_corr_vars)
            
            eta = c()
            for (var in cat_corr_vars) {
                anova <- aov(df[,cont_var] ~ factor(as.vector(df[,var])))
                print(paste("eta for", var, ":", as.character(etaSquared(anova)[2])))
                eta = c(eta, etaSquared(anova)[2])
            }
            corr_ratios = data.frame(cat = cat_corr_vars,
                                     eta = eta)
            # corr_ratios$cat <- factor(x$cat, levels = corr_ratios$cat[order(corr_ratios$eta)])
            # corr_ratios = corr_ratios[order(corr_ratios$eta, decreasing=TRUE),]
            
            tryCatch({
                ggplot(corr_ratios, aes_string(x="cat", y="eta")) +
                    geom_col(fill="#000080") +
                    xlab("Eta (observed - fitted correlation)") + ylab("Group")
                },
                error = function(e) {
                    message("cannot input contrinuous variables")
                })
        }
    })
}





