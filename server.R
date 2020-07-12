#
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# Set your directory and Define server logic

shinyServer(function(input, output, session) {
    #Creating the waiter :-
    w <- Waiter$new(html = span("Initialising"))
    
    msgs <- c("Loading required liabraries", "Running model", "Ready!")
    
    observeEvent(input$show, {
        w$show()
        
        Sys.sleep(2)
        
        for(i in 1:3){
            w$update(html = msgs[i])
            Sys.sleep(2)
        }
        
        w$hide()
    })
    
    
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
            Extext <- ocr("www/sampleimage.png")
        }
        Extext
    })    

    
    output$intro <- renderUI({
        list(
            img(SRC = "textify.png", height = "40%", width = "60%"),
            
            p(br(),"Textify allows the user to extract text from an image that
              can be shared across any device and platform which supports 
              text. It is as simple as it sounds! Personally, I have been 
              using Textify to extract text from screenshots so that the text contained in the screenshot can be saved
              in notes and can be quickly searched.", style = "font-family: 'times'; font-size: 18px"),
            
            p("Once the user uploads an image, the app extracts text from
            the image and is displayed under the", em("Image and extracted text"), 
            "tab. The extracted text is used to identify seperate sentences within the text
              and is further used to form a wordcloud image for visualization purposes." , 
                style = "font-family: 'times'; font-size: 18px"),
              
            p("No image at hand ? No problem, if no image is uploaded a default 
            test image is used for OCR. The R source code for this app 
              can be found on my ", a(icon("github", lib="font-awesome"), style = "color:#080808", 
                href="https://github.com/AdiHasurkar/OCR-using-RShiny"), "profile. 
              Hope you enjoy using this web app as much as I've enjoyed making it.", style = "font-family: 'times'; font-size: 18px"),
            
            h4("Cheers, Aditya",span(icon("beer", lib = "font-awesome", class = "fa-spin"), style = "color:#f28e1c"),
               style = "font-family: 'Brush Script MT', cursive;
        font-weight: 500; line-height: 1.1; font-size: 24px;
        color:#553c2a ")
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
            list(src="www/sampleimage.png")
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
            style = "bootstrap4"
            
        )
        
    })
    
    
    
    output$cloud = renderPlot({
        
        text = extractedText()
        cp = Corpus(VectorSource(text)) #Load the text as a corpus
        cp = tm_map(cp, content_transformer(tolower)) #Transform the text to lower case
        cp = tm_map(cp, removePunctuation) #Remove any Punctuations from the text
        cp = tm_map(cp, stripWhitespace) #Remove extra whitespace
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
    
})





