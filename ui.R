#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that creates a wordcloud from text
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Analyzing your Job Description"),
  
  # Sidebar with a text input
  sidebarLayout(
    sidebarPanel(
            tags$style("#phrase {font-size:10px;height:200px;}"),
            h2("Paste the Job Description"),
            textInput(inputId <- "phrase",   #ID for internal app reference
                      label="Description",   #label above the input box
                      value="Please input your text here"),   #default text to be replaced
            h3("10 max, but 2 or 3 is best"),
            numericInput(inputId = "DesiredNgrams",
                         label = "N-grams",
                         value = 2, # No default value
                         min = 1,            # min value
                         max = 10,           # max value 
                         step = 1),          # 
            submitButton("Get Wordcloud")
    ),
    
    # Show a wordcloud of the Job Description
    mainPanel(
            h2("A Wordcloud of the desired number of key-words!"),
       plotOutput("TheWordCloud")
    )
  )
))
