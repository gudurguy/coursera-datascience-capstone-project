library(dplyr)
library(shiny)
library(ggplot2)
library(shinycssloaders)
library(shinyBS) 
library(shinythemes)


shinyUI(
        navbarPage(
          "Coursera Data Science Capstone: Final Project Submission",
          theme = shinytheme("cerulean"),
          tabPanel("Next Word Prediction",
                      br(),
                      br(),
                      # Sidebar
                      sidebarLayout(
                          sidebarPanel(
                                helpText("This is an example demonstration to predict the next word given an input word or a sentence"),
                                br(),
                                textInput("inputString", "Please enter a word or a sentence here",value = ""),
                                br(),
                                br(),
                                br(),
                                br()
                          ),
                          mainPanel(
                                h2("Next Word Prediction"),
                                h5("The next word for a given word or a sentence is predicted using the NLP techquies,
                              especially using Katz back-off model."),
                                br(),
                                strong("Next word prediction is"),
                                verbatimTextOutput("prediction") %>% withSpinner(color="#0dc5c1"),
                                br(),
                                strong("User Input so far:"),
                                tags$style(type='text/css', '#text1 {font-weight: bolder;}'), 
                                strong(code(textOutput('text1'))),
                                br(),
                                strong("N-Gram used for the Prediction:"),
                                tags$style(type='text/css', '#text2 {font-weight: bolder;}'),
                                strong(code(textOutput('text2')))
                          )
                      )
                            
                   ),
          tabPanel(
            "Help",
            p("First and foremost using ", strong("5 %"), " of the data given by SwiftKey folks a corpus is generated. Reason for using just 5% of the data is due to computational burden. Anything more can not be processed in reasonable amount time given the resources of an ordinary machine."),
            br(),
            p("Using this corpus, generated 2-grams, 3-grams and 4-grams and these are saved to be used by the app instead of generation during the start up. This N-Gram data itself is almost ", strong("60 MB"), ". Hence it takes a bit to time to load this data during the initial launch of the app and also while searching. Especially 4-Gram data which is enormous."),
            br(),
            p("The app in turn uses",  strong("Katz Back-Off Language Model"), "to predict the next word based on the user input."),
            br(),
            strong(p("Katz Back-Off Algorithm works as the following")),
            p("To predict the next word, 4-gram is first used."),
            p("If no 4-grams are found, back off to 3-gram."),
            p("If no 3-grams are found, back off to 2-gram."),
            p("If no 2-grams are found, fall back to the most common word i.e. \"the\".")          
            ),
          tabPanel(
            "About",
            h3("Coursera Data Science Capstone - Final Project - Shiny Application"),
            h3("Author: Gudur Guy - July, 2023"),     
            br(),
            p("This application shows an example of making a web application using R and ",
              a(href = "https://shiny.rstudio.com/", "Shiny library"),
              "together, final project for the course,",
              a(href = "https://www.coursera.org/learn/data-science-project", "Data Science Capstone")
            ),
            p("This in turn is part of the Data Science Specialized Program offered Johns Hopkins University via Coursera",
              a(href = "https://www.coursera.org/specializations/jhu-data-science", "Data Science Specialization")
            ),
            br(),
            p("Source code of this application is available at",
              a(href = "https://github.com/gudurguy/coursera-datascience-capstone-project",
                "https://github.com/gudurguy/coursera-datascience-capstone-project")
            ),
            p("Presentation for this application is available at",
              a(href = "https://rpubs.com/gudurguy/1061297",
                "https://rpubs.com/gudurguy/1061297")
            )
          )
)
)
