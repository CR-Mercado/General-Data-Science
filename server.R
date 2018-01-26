# This app takes in an "About Us" or "Job Description" 
# purposeful text with specific repetitions 
# and creates a wordcloud of the most frequent keywords 
# in nice colors and sizes. 
# add this to your cover letters for fun. 
#
#

library(shiny) 
library(dplyr)     
library(tidytext) #for unnesting
library(tm)   #for text cleaning
library(RColorBrewer) #for cool colors 
library(wordcloud) #for the wordcloud
# Define server logic required to create a wordcloud
shinyServer(function(input, output){
        
        TheText <- reactive({              # react to changes
                thebigclean(input$phrase)           # clean the input 
                #note: lowercase, no stop words, no foreign letters,
                # punctuation, numbers, etc. 
        })
        
        TheText.df <- reactive({
                TheTEXT1 <- as.data.frame(TheText()) #reactive change to df
                colnames(TheTEXT1) <- "Text"  #change column name
                
                TheTEXT1 #assign this df to the reactive TheText.df
        })
        
        
        TheNgrams <- reactive({           # react to changes 
                input$DesiredNgrams      #get the number of n-grams desired
        })
        
        
        ngramify  <- reactive({
                #function counts and tables n-grams from text
                unnest_tokens(TheText.df(),  #TheText.df is reactive so use "()" 
                              NGRAM,      #The desired column name 
                              Text,   #The current column name
                              token="ngrams", #how to unnest 
                              n=TheNgrams())            #how many words in each group
        })
        library(plyr)  #need to override dplyr's count() 
        output$TheWordCloud <- renderPlot({
                with(              #using the reactive datatable 
                        #made from unnest_token 
                        count(                   #makes a data table with "n" 
                                #counts of each element                       
                                ngramify(),  #ungroup the data.table
                                "NGRAM"),        #count this column 
                        wordcloud(NGRAM,             #the column
                          freq = freq,   #the frequencies - from count() 
                          max.words = 50,    #most ngrams permitted on wordcloud
                          scale = c(2,.2),   #range of permitted sizes
                          min.freq = 1,      #min # of occurances
                          random.order = FALSE,  #make most common in the middle                                  random.color = FALSE, #select color by frequency 
                          colors = brewer.pal(4,"Dark2") #from RColorBrewer
                        )       
                )
                
        })
})






#  Backend Functions below 
#
#
#
#
#
#
#
#
### Taken from another of my Shiny Apps - Text Prediction these functions 
### are relevant 


remove.vector.stopwords <- function(inputcorp) {
        
        library(tm)
        #This is the fast version for removing stopwords from large character classes     
        #make sure to remove punctuation, numbers, symbols, foreign letters, FIRST
        
        badwords <- stopwords(kind="en") #get the 174 stopwords
        badwords <- gsub("\'","",badwords) #remove apostrophes 
        #again, punctuation should already be removed 
        
        inputcorp <- removeWords(inputcorp,badwords)
        return(inputcorp)
        #Remove extra whitespace LAST: see thebigclean() 
}

makeInternational <- function(inputtext){ 
        inputtext <- iconv(inputtext, to="ASCII//TRANSLIT") 
        #makes foreign letters into standard letters, some symbols become punctuation
        #NOTE this does NOT need to be looped over large character classes, just input all of it
        return(inputtext)
}

thebigclean <- function(inputtext, removestops = TRUE,lowercase = TRUE, 
                        punctuation = TRUE, numbers = TRUE, international =TRUE){ 
        library(tm) 
        if(lowercase == TRUE)
                inputtext <- tolower(inputtext) #works on large characters
        
        if(international == TRUE)
                inputtext <- makeInternational(inputtext) #works on large characters
        
        if(punctuation == TRUE)
                inputtext <- gsub("[[:punct:]]", "", inputtext) #removes punctuation
        #works on large characters
        
        if(numbers == TRUE)
                inputtext <- gsub("[0-9]","",inputtext) #removes numbers
        #works on large characters 
        
        if(removestops == TRUE)
                inputtext <- remove.vector.stopwords(inputtext)
        #removes stopwords (punctuation adjusted) using tm package, faster than a loop 
        
        inputtext <- gsub("\\s+"," ",inputtext) #removes extra spaces from above, DO THIS LAST!
        #works on large characters 
        
        return(inputtext)
}

# Test case included 
#
#
test.words <- c("chicken","burger","cheese","sandwich","the","a","eat","I","want")
test.sample <- sample(test.words, 500, replace = TRUE)
test.to.clean <- paste(test.sample, collapse = " ")
