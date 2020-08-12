# Find out more about building applications with Shiny here:
#    http://shiny.rstudio.com/

#Loading libraries and defining UI logic :- 

library(shiny)
library(jpeg)
library(shinyWidgets)
library(shinycssloaders)
library(tesseract)
library(wordcloud)
library(tm)
library(shinythemes)
library(RColorBrewer)
library(quanteda)
library(DT)


ui = fluidPage(
    
    
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
                     
                     sliderTextInput(
                         inputId = "minfreq",
                         label = "Minimum word frequency in cloud:",
                         choices = c(2,4,6,8,10),
                         selected = 2,
                         grid = F
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
                            imageOutput("sample")
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
                    dataTableOutput("sentences")
                ),
                
                tabPanel(
                    "Word Cloud",
                    plotOutput("cloud",height = "1000px"),
                    
                ), 
                
                tabPanel(
                    "FAQ",
                    
                    
                    h1(code("How does this app work?"), style = "font-size: 20pt"),
                    p("Textify uses the Tessaract R package, a powerful optical 
                    character recognition (OCR) engine that supports over
                    100 languages to extract text from images. Requires 
                    having sufficient training data for the language the 
                    user wishes to read. Works best for images with high 
                    contrast, little noise and horizontal text.", style = "font-family: 'times'; font-size: 17px"),
                    
                    h2(code("What is OCR in simple terms?"), style = "font-size: 20pt"),
                    p(strong("O"),"ptical",strong("C"),"haracter",strong("R"),"ecognition is a technique
                    to digitize paper printed texts so that the text can be electronically
                    edited, searched, stored more compactly and can be further used in processes such as text mining,
                    computer vision, pattern recognition, text-to-speech translation and many more.", style = "font-family: 'times'; font-size: 17px"),
                    
                    
                    h3(code("Are my images secured?"), style = "font-size: 20pt"),
                    p("The conversion of image to text happens in a user’s 
                    browser and your images are", em("never uploaded"), "to the server. 
                    You can trust the app regarding data security as none of 
                    your images are saved on local machine and no one can access 
                    your images except you.", style = "font-family: 'times'; font-size : 17px"),
                    
                    h4(code("Is it a free app?"), style = "font-size: 20pt"),
                    p("Textify is completely free to use by anyone with no hidden costs, 
                    no signup required and no other limitations. You can scan
                    any number of images and use it to extract text without any restriction or cap, 
                    as long as you are connected to the internet.", style = "font-family: 'times'; font-size: 17px"),
                    
                                    
                    br(),
                    
                    
                )
            )
        )
    )
)


# Defining server logic:

server = function(input, output, session) {
    
    extractedText <- reactive({
        
        progress <- Progress$new(session, min=1, max=15)
        on.exit(progress$close())
        
        progress$set(
            message = 'OCR in progress', 
            detail = 'Stay Tuned...'
        )
        
        inFile = input$file1
        
        if (!is.null(inFile))
        {
            Extext <- ocr(inFile$datapath)
        }
        else
        {
            Extext <- ocr("Your Default Image Path") #Must be in www folder and where your app.R file is saved.
        }
        Extext
    })    
    
    
    output$intro <- renderUI({
        list(
            img(SRC = "textify.png", height = "40%", width = "60%"),
            
            p(br(),"Textify allows the user to extract text from an image that
              can be shared across any device and platform that supports 
              text. It is as simple as it sounds! Personally, I have been 
              using Textify to extract text from screenshots so that the text contained in the screenshot can be saved
              in notes and can be quickly searched.", style = "font-family: 'times'; font-size: 18px"),
            
            p("Once the user uploads an image, the app extracts text from
            the image and is displayed under the", em("Image and extracted text"), 
              "tab. The extracted text is used to identify seperate sentences within the text
              and is further used to form a wordcloud image for visualization purposes." , style = "font-family: 'times'; font-size: 18px"),
            
            p("No image at hand ? No problem, if no image is uploaded a default 
            test image is used for OCR. Simply click on", em("Image and extracted text")," and see it in action.") 
           
        )
        
    })
    
    output$sample <- renderImage({
        
        inFile = input$file1
        print(inFile)
        if (!is.null(inFile))
        {
            
            width  <- session$clientData$output_sample_width
            height <- session$clientData$output_sample_height
            list(
                src = inFile$datapath,
                width=width,
                height=height
            )
        }
        else
        {
            list(src="Your Default Image Path")
        }
    },
    deleteFile = FALSE
    )
    
    
    output$OCRtext = renderPrint({
        
        
        cat(extractedText())
    })
    
    
    output$sentences = renderDataTable({
        
        text = extractedText()
        tmp = tokenize_sentence(text, what = "sentence")
        DT::datatable(  
            data.frame(
                sentence = 1:length(tmp[[1]]),
                text = tmp[[1]]
            ),
            rownames = FALSE,
            #style = "bootstrap4"
            
        )
        
    })
    
    
    
    output$cloud = renderPlot({
        
        text = extractedText()
        cp = Corpus(VectorSource(text)) #Load the text as a corpus
        cp = tm_map(cp, content_transformer(tolower)) #Transform the text to lower case
        cp = tm_map(cp, removePunctuation) #Remove any Punctuations from the text
        if(input$stopwords){
            cp = tm_map(cp, removeWords, stopwords('english')) #Remove stopwords for english language
        }
        
        pal <- brewer.pal(9,"PuBu") #Select color
        pal <- pal[-(1:4)]
        wordcloud(
            cp, 
            max.words = input$maxwords,
            min.freq = input$minfreq,
            random.order = FALSE,
            colors = pal
        )
        
    })
    
}

# Running the application 
shinyApp(ui = ui, server = server)
