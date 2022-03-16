################################################################################################################################################################
# Ui panel


################################################################################################################################################################

DataExp <- tabPanel("EXPLORACION",
                    
                    column(3, 
                           h3(p(style="color:black;text-align:left", 
                                tags$img(src="https://raw.githubusercontent.com/rstudio/hex-stickers/master/thumbs/shiny.png",width="60px",height="60px"),
                                tags$img(src="https://i1.wp.com/fileserialkey.com/wp-content/uploads/2019/07/2-2.png?fit=300%2C300&ssl=1",width="60px",height="60px"),
                           )),
                           numericInput("corrida", label = "Ingrese una corrida", value = 1031, min = 27, max = 1040),
                           selectInput(inputId = "placa",
                                       label = "Selecciona una placa",
                                       choices = c("placa1","placa2","placa3","placa4","placa5","placa6"),
                                       selected = "placa1")),
                    column(9,
                           shinycssloaders::withSpinner(
                             DT::dataTableOutput("tablemysql"), type = 3, color.background = "white", color = "blue"),
                    ),
                    column(12 , h2("")),
                    column(12 , column(3, h3(icon("file-excel"), "Descarga de Excel"),
                                       h3(icon("table"), "Busqueda de datos"),
                                       h3(icon("chart-pie"), "Graficas de dispersion")), 
                           column(9, plotlyOutput("point")))
                    
                    
                    
)

################################################################################################################################################################


UdateData <- navbarPage(theme = shinytheme("flatly"), 
                        "RMyAdmin-Ingreso", 
                        id="nav", 
                        tabPanel("INGRESO DE DATOS",
                                 useShinyjs(),
                                 column(12,style = "background-color:#0F446C;",
                                        column(3, 
                                               h3(p(style="color:black;text-align:left", 
                                                    
                                                    tags$img(src="https://raw.githubusercontent.com/rstudio/hex-stickers/master/thumbs/shiny.png",width="60px",height="60px"),
                                                    tags$img(src="https://i1.wp.com/fileserialkey.com/wp-content/uploads/2019/07/2-2.png?fit=300%2C300&ssl=1",width="60px",height="60px"),
                                               ))),
                                        column(3,style = "color:white;",
                                               numericInput("ncorrida", label = "Ingrese Corrida", value = 1031, min = 27, max =1040)),
                                        column(3, style = "color:white;",numericInput("minR", label = "Ingrese inicio #", value = 1, min = 1, max =385)),
                                        column(3, style = "color:white;",numericInput("maxR", label = "Ingrese fin #", value = 25, min = 1, max =385)),
                                        column(3, style = "color:white;",selectInput(inputId = "nplaca",
                                                                                     label = "Selecciona una placa",
                                                                                     choices = c("placa1","placa2","placa3","placa4","placa5","placa6"),
                                                                                     selected = NULL)),
                                        actionButton(inputId = "Buscar", 
                                                     label =  h4(icon("search"), "Buscar Metadatos"),
                                                     width = "200px")
                                        
                                 ),
                                 column(12, h2(" ")),
                                 column(12, aling="center",
                                        DT::dataTableOutput("SqlInput")
                                 ),
                                 shiny::includeScript("script.js"),
                                 column(1," "),
                                 
                        ), DataExp, 
                        footer = tags$div(
                          class = "footer",h3(p(style="color:black;text-align:left", 
                                                tags$img(src="https://media.slid.es/uploads/1121994/images/6529504/minsa.jpg",width="190px",height="70px"))),
                          tags$style(".footer{position:absolute;bottom:0; width:100%;}"))
)


################################################################################################################################################################


