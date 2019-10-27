rm(list=ls())
library(shiny)
library(ggplot2)
library(reshape2)
library(lsr)
library(DescTools)
library(rsconnect)


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
    output$pearsonHeatmapVars = 
        renderUI({
            selectInput(inputId='pearson_heatmap_vars', label="Continuous Variables", 
                        choices=input$contvars, multiple=TRUE, selected=input$contvars[1:4])
        })
    output$kramersHeatmapVars = 
        renderUI({
            selectInput(inputId='kramers_heatmap_vars', label="Nominal Variables", 
                        choices=input$catvars, multiple=TRUE, selected=input$catvars[1:4])
        })
    
    output$pearsonHeatmap = renderPlot({
        selected_vars = input$pearson_heatmap_vars

        df = getData()
        if (is.null(df)==FALSE) {
            req(selected_vars)
            features = df[,selected_vars]
            cormat <- round(cor(as.matrix(sapply(features, as.numeric)), use="pairwise.complete.obs"), 2)
            melted_cormat <- melt(cormat)
            ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + geom_tile()
        }
    })
    
    output$kramersHeatmap = renderPlot({
        selected_vars = input$kramers_heatmap_vars
        
        df = getData()
        if (is.null(df)==FALSE) {
            req(selected_vars)
            features = df[,selected_vars]
            cramersV_matrix = PairApply(features, CramerV, symmetric = TRUE)
            melted_cormat = melt(cramersV_matrix)
            ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + geom_tile()
        }
    })
    
    
    # inputs for barchart
    output$contcorrvar = 
        renderUI({
            selectInput(inputId='contcorrvar', label="Continuous Variable", choices=input$contvars, selected=input$contvars[1])
        })
    output$catcorrvars = 
        renderUI({
            selectInput(inputId='catcorrvars', label="Categorical Variables", multiple=TRUE,
                        choices=input$catvars, selected=input$catvars)
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
                eta = c(eta, etaSquared(anova)[2])
            }
            corr_ratios = data.frame(cat = cat_corr_vars,
                                     eta = eta)
            
            tryCatch({
                ggplot(corr_ratios, aes_string(x="reorder(cat, -eta)", y="eta")) +
                    geom_col(fill="#000080") +
                    xlab("Group") + ylab("Eta (observed - fitted correlation)")
                },
                error = function(e) {
                    message("cannot input continuous variables")
                })
        }
    })
}





