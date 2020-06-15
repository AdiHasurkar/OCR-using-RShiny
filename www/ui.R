#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/

#Load libraries and define UI logic :- 

library(shiny)
library(jpeg)
library(shinyWidgets)
library(shinycssloaders)
library(waiter)
library(tesseract)
library(wordcloud)
library(tm)
library(shinythemes)
library(RColorBrewer)
library(quanteda)
library(DT)


shinyUI(fluidPage(theme = shinytheme(theme = "sandstone"),
                  
                  tags$title(
                      tags$style(HTML("
      @import url('//fonts.googleapis.com/css?family=Lobster|Cabin:400,700');
      

    "))
                  ),
                  
                 
    # Web app title :- 
    fluidPage(
      titlePanel(
        h1("Textify : Say YES to Tex",icon("paragraph",lib = "font-awesome",class = "fa-xs"),
               style = "font-family: 'Helvetica';
        font-weight: 450; line-height: 1; 
        color: #553c2a"))),
    
    # Sidebar customization :-
    sidebarLayout(
        sidebarPanel(width = 3,
                     fileInput('file1', 'Choose an image'),
                     tags$hr(),
                     sliderTextInput(
                       inputId = "maxwords",
                       label = "Maximum number of words in cloud:", 
                       choices = c(1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100),
                       grid = F,
                       selected = 10,
                       width = "100%"
                     ),
                     
                     knobInput(
                       inputId = "minfreq",
                       label = "Minimum word frequency in cloud:",
                       value = 10,
                       min = 2,
                       displayPrevious = TRUE, 
                       lineCap = "round",
                       fgColor = "#428BCA",
                       inputColor = "#428BCA"
                     ),

                       prettyToggle(
                       inputId = "stopwords",
                       label_on = "Remove stopwords!", 
                       label_off = "Include stopwords.",
                       outline = TRUE,
                       plain = TRUE,
                       icon_on = icon("thumbs-up"), 
                       icon_off = icon("thumbs-down")
                     ),
                  
                
        ),
        
        # Designing the main panel :- 
        mainPanel(
            
            tabsetPanel(
                tabPanel(
                    "Introduction",
                    htmlOutput("intro")
                    
                ),
                
                tabPanel(
                    "Image & extracted text",
                    fluidRow(
                        column(
                            width=4,
                            withSpinner(imageOutput("sample"))
                        ),
                        column(
                            offset = 3,
                            width=4,
                            verbatimTextOutput("OCRtext")
                        )
                    )
                    
                ),
                
                tabPanel(
                    "Extracted text as sentences",
                    withSpinner(dataTableOutput("sentences"))
                ),
            
                tabPanel(
                    "Word Cloud",
                      withSpinner(plotOutput("cloud",height = "1000px")),
              
                ), 
                
                tabPanel(
                  "FAQ",
                  
              
                  h1(code("How does this app work?"), style = "font-size: 20pt"),
                  p("Textify uses the", a("Tesseract", href="https://github.com/ropensci/tesseract"), "R 
                  package, a powerful optical 
                    character recognition (OCR) engine that supports over
                    100 languages to extract text from images. Requires 
                    having sufficient training data for the language the 
                    user wishes to read.", strong("Works best"), "for images with high 
                    contrast, little noise and horizontal text.", style = "font-family: 'times'; font-size: 17px"),
                  
                  h2(code("What is OCR in simple terms?"), style = "font-size: 20pt"),
                  p(strong("O"),"ptical",strong("C"),"haracter",strong("R"),"ecognition is a technique
                    to digitize paper printed texts so that the text can be electronically
                    edited, searched, stored more compactly and can be further used in processes such as text mining,
                    computer vision, pattern recognition, text-to-speech translation and many more.
                    To know more about OCR and its applications, check out",a("this",href="https://medium.com/@anyline_io/what-is-ocr-why-does-it-make-your-life-easier-209b9fcedec4"), "article.", style = "font-family: 'times'; font-size: 17px"),
                  
                  
                  h2(code("Are my images secured?"), style = "font-size: 20pt"),
                  p("The conversion of image to text happens in a user’s 
                    browser and your images are", em("never uploaded"), "to the server. 
                    You can trust the app regarding data security as none of 
                    your images are saved on local machine and no one can access 
                    your images except you.", style = "font-family: 'times'; font-size : 17px"),
                  
                  h3(code("Is it a free app?"), style = "font-size: 20pt"),
                  p("Textify is completely free to use by anyone with no hidden costs, 
                    no signup required and no other limitations. You can scan
                    any number of images and use it to extract text without any restriction or cap, 
                    as long as you are connected to the internet.", style = "font-family: 'times'; font-size: 17px"),
                  
                  h4(code("How do you use this app personally?"), style = "font-size: 20pt"),
                  p("I have approximately 5 gigabytes of screenshots (in image format) of my
                    favourite facts & figures, quotes, news articles, interesting statistics 
                    and much more collected over number of years on my smartphone. This 
                    is a lot of information and a tedious process to find out certain 
                    information amongst plenty of images. I have been using Textify to 
                    extract information from those images and store it in my notes so that 
                    I can search for articles within a matter of seconds without scrolling 
                    through a plethora of images to find the one that I want.", style = "font-family: 'times'; font-size : 18px"),
                 
                  h4(code("Can I contact you?"), style = "font-size: 20pt"),
                  p("You certainly can! Please do let me know your experience if you are a",em("Textifier"),"by
                     getting in touch with me on" , a(icon("linkedin", lib="font-awesome"), style = "color:#0e76a8",href="https://linkedin.com/in/aditya-hasurkar"), "or
                     drop me an", a(icon("envelope-open", lib = "font-awesome"), style = "color:#2b2b2b", href="mailto:aditya.hasurkar@gmail.com"), 
                     style = "font-family: 'times'; font-size: 18px"),
                  
                  br(),
                  
                 use_waiter(),
                 fluidPage(column(
                   
                  11),
                  actionBttn("show",icon = icon("sync", lib = "font-awesome"),style = "material-circle",
                             color = "default", size = "xs"))
                 
                  
                )
            )
        )
    )
))
