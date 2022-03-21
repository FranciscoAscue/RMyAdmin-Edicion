source("R/dependencies.R", local = TRUE)
source("R/ui-panel.R", local = TRUE)
source("R/data-mysql.R", local = TRUE)
source("config.R", local = TRUE)


create_btns <- function(x) {
  x %>% purrr::map_chr(~
                         paste0(
                           '<div class = "btn-group">
                   <button class="btn btn-default action-button btn-info action_button" id="edit_',
                           .x, '" type="button" onclick=get_id(this.id)><i class="fas fa-edit"></i></button>'
                         ))
}



ui <- fluidPage( title = "RMyAdmin-Edicion",  
                 div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
                 
                 # login section
                 shinyauthr::loginUI(id = "login", title = h3(icon("server"), icon("biohazard"),"RMyAdmin - Edicion"), 
                                     user_title = "Usuario", pass_title = "Contraseña"),
                 
                 uiOutput("Page") )


server <- function(input, output, session) {
  
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    sodium_hashed = TRUE,
    log_out = reactive(logout_init())
  )
  
  # Logout to hide
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )
  
  
  output$point <- renderPlotly({
    
    plot_ly(mysql_explore(), x= ~FECHA_TM, y = ~CT, color = ~MOTIVO, text= ~NETLAB, type = 'scatter', mode = "markers")
    
  })
  
  output$tablemysql <- DT::renderDataTable(mysql_explore(), extensions = 'Buttons',
                                           options = list( dom = 'Blfrtip', buttons = c('copy', 'excel')),
                                           rownames = FALSE,server = FALSE, escape = FALSE, selection = 'none')
  
  
  output$SqlInput <- DT::renderDataTable(inputData(),
                                         options = list(scrollX = TRUE),
                                         rownames = FALSE, server = FALSE, escape = FALSE, selection = 'none')
  
  
  
  mysql_explore <- reactive({
    user <- credentials()$info[["user"]]
    password <- user
    data <- metadata_sql(usr = user, pass = password, corrida = input$corrida, placa = input$placa)
    data$FECHA_TM <- as.Date(data$FECHA_TM)
    data
  })
  
  inputData <- reactive({
    req(input$Buscar)
    user <- credentials()$info[["user"]]
    password <- user
    data <- metadaEdition(usr = user, pass = password, corrida =  input$ncorrida,
                          placa = input$nplaca , min = input$minR , max =  input$maxR, 
                          corridaA =  corridaActual)
    x <- create_btns(data$NETLAB)
    data <- data %>%
      dplyr::bind_cols(tibble("EDITAR" = x))
    colnames(data) <- c("Nº","NETLAB","CT","FECHA_TM","PROCEDENCIA","PROVINCIA","DISTRITO","APELLIDO_NOMBRE","DNI_CE","EDAD","SEXO",
                        "VACUNADO","MARCA_PRIMERAS_DOSIS","1DOSIS","2DOSIS","MARCA_3DOSIS","3DOSIS","HOSPITALIZACION","FALLECIDO","EDITAR")
    data
  })
  
  ############################################################################################################################################################
  
  observeEvent(input$Buscar,{
    
      tmp <- input$ncorrida 
      updateTextInput(session, "ncorrida", value = 0)
      updateTextInput(session, "ncorrida", value = tmp)
      output$SqlInput <- DT::renderDataTable(inputData(), extensions = "FixedColumns",
                                             options = list(pageLength = 25, scrollX = TRUE),
                                             rownames = FALSE, server = FALSE, escape = FALSE, selection = 'none'
                                          )
  
  })
  
  
  
  shiny::observeEvent(input$current_id, {
    shiny::req(!is.null(input$current_id) &
                 stringr::str_detect(input$current_id,pattern = "edit"))
    edit_row <- which(stringr::str_detect(inputData()$EDITAR, pattern = paste0("\\b", input$current_id, "\\b") ))
    
    sql_id <- inputData()[edit_row, ][["NETLAB"]]
    fecha_tm <- inputData()[edit_row, ][["FECHA_TM"]]
    procedencia <- inputData()[edit_row, ][["PROCEDENCIA"]]
    provincia <- inputData()[edit_row, ][["PROVINCIA"]]
    distrito <- inputData()[edit_row, ][["DISTRITO"]]
    nombre <- inputData()[edit_row, ][["APELLIDO_NOMBRE"]]
    dni <- inputData()[edit_row, ][["DNI_CE"]]
    edad <- inputData()[edit_row, ][["EDAD"]]
    sexo <- inputData()[edit_row, ][["SEXO"]]
    vac <- inputData()[edit_row, ][["VACUNADO"]]
    marca1 <- inputData()[edit_row, ][["MARCA_PRIMERAS_DOSIS"]]
    Pra <- inputData()[edit_row, ][["1DOSIS"]]
    Sda <- inputData()[edit_row, ][["2DOSIS"]]
    marca2 <- inputData()[edit_row, ][["MARCA_3DOSIS"]]
    Tra <- inputData()[edit_row, ][["3DOSIS"]]
    Hp <- inputData()[edit_row, ][["HOSPITALIZACION"]]
    Dead <- inputData()[edit_row, ][["FALLECIDO"]]
    
    shiny::modalDialog(
      title = column(12, h3(icon("id-card"),"COD. NETLAB :",sql_id)),
      column(12, style = "background-color:#AED6F1;",
             column(12, column(1, h4(icon("map-marked"))), column(6, h4("Datos de Procedencia"))),
             column(6,
                    
                    dateInput(inputId = "fecha_tm",
                              label = "Fecha de toma de muestra",
                              language = "es", value = fecha_tm , min = "2020-01-01", max = "2022-05-28"
                    )
                    
             ),
             column(6, selectInput(inputId = "procedencia",
                                   label = "Selecciona Procedencia",
                                   choices = sqlRegion(credentials()$info[["user"]], 
                                                       credentials()$info[["user"]]),
                                   selected = procedencia)),
      ),
      
      column(12, style = "background-color:#AED6F1;",
             column(6,
                    uiOutput("Prov")),
             column(6,   
                    uiOutput("Dis")),
      ), 
      
      column(12, " "),
      
      column(12, style = "background-color:#ABEBC6;",
             column(12, column(1, h4(icon("id-card"))), column(5, h4("Datos Personales"))),
             column(6,
                    textInput(inputId = "apellido_nombre",
                              label = "Ingrese Nombre",
                              value = nombre , placeholder = "APELLIDOS - NOMBRES"),    
             ),
             column(6,   
                    textInput(inputId = "dni",
                              label = "Ingrese DNI o CE",
                              value = dni , placeholder = "DNI"),    
             ),
             
      ), 
      
      
      column(12, style = "background-color:#ABEBC6;",
             column(6,
                    numericInput("edad", label = "Ingrese Edad", value = edad, min = 0, max = 107),
             ),
             column(6,   
                    selectInput(inputId = "sexo",
                                label = "Ingrese Sexo",
                                choices = c("NULL","Female", "Male" ),
                                selected = sexo),
             ),
             
      ), 
      
      column(12, " "),
      
      column(12, column(12, column(1, h4(icon("syringe"))), column(5, h4("Datos de Vacunas"))),
             column(6,
                    selectInput(inputId = "vacunado",
                                label = "Vacunacion",
                                choices = c("NULL","SI", "NO", "NO INDICA"),
                                selected = vac),
             ),
             column(6,
                    selectInput(inputId = "marca1",
                                label = "Marca de Primeras dosis",
                                choices = c('NULL','AstraZeneca-Oxford', 'Sinopharm','Pfizer-BioNTech',  'Johnson & Johnson', 'NO INDICA'),
                                selected = marca1),
             ),
      ), 
      
      
      column(12, 
             column(6,
                    dateInput(inputId = "PDosis",
                              label = "Fecha de Primera Dosis",
                              language = "es", value = Pra , min = "2020-01-01", max = "2022-05-28"
                    )),
             column(6, 
                    
                    dateInput(inputId = "SDosis",
                              label = "Fecha de Segunda Dosis",
                              language = "es", value = Sda , min = "2020-01-01", max = "2022-05-28"
                    )),
      ),
      
      
      column(12, 
             column(6,
                    selectInput(inputId = "marca2",
                                label = "Marca 3ra Dosis",
                                choices = c('NULL','AstraZeneca-Oxford', 'Sinopharm','Pfizer-BioNTech',  'Johnson & Johnson', 'NO INDICA' ),
                                selected = marca2),
             ),
             column(6,
                    
                    dateInput(inputId = "TDosis",
                              label = "Fecha de Tercera Dosis",
                              language = "es", value = Tra , min = "2020-01-01", max = "2022-05-28"
                    )
                    
             ),
      ), 
      
      column(12," "),
      
      column(12, style = "background-color:#AED6F1;",
             column(12, column(1, h4(icon("procedures"))), column(5, h4("Datos de mortalidad"))),
             column(6,
                    selectInput(inputId = "hospitalizacion",
                                label = "Hospitalizacion",
                                choices = c("NULL","SI", "NO", "NO INDICA"),
                                selected = Hp),
             ),
             column(6,
                    selectInput(inputId = "fallecido",
                                label = "Fallecido",
                                choices = c("NULL","SI", "NO", "NO INDICA"),
                                selected = Dead),
             ),
      ),
      
      column(12 , h3(" ")),
      
      easyClose = TRUE,
      footer = div(
        shiny::actionButton(inputId = "final_edit",
                            label   = "Ingresar",
                            icon = shiny::icon("edit"),
                            class = "btn-info"),
        shiny::actionButton(inputId = "dismiss_modal",
                            label   = "Cancelar",
                            class   = "btn-danger")
      )
    ) %>% shiny::showModal()
    
  })
  
  shiny::observeEvent(input$final_edit, {
    
    tryCatch({
    shiny::req(!is.null(input$current_id) &
                 stringr::str_detect(input$current_id,pattern = "edit"))
    edit_row <- which(stringr::str_detect(inputData()$EDITAR, pattern = paste0("\\b", input$current_id, "\\b") ))
    
    sql_id <- inputData()[edit_row, ][["NETLAB"]]
    user <- credentials()$info[["user"]]
    password <- user
    update_sql(usr = user, pass = password, sql_id, fecha_tm = input$fecha_tm, procedencia =input$procedencia , provincia =input$provincia ,
               distrito =input$distrito ,nombre = toupper(input$apellido_nombre) ,dni =input$dni , edad =input$edad ,sexo =input$sexo ,
               vac =input$vacunado ,marca1 =input$marca1 ,Pra =input$PDosis , Sda =input$SDosis ,
               marca2 =input$marca2 ,Tra =input$TDosis , Hp =input$hospitalizacion , Dead =input$fallecido)
    
    },
    
    error = function(e){
      showModal(
        modalDialog(
          title = "DNI DUPLICADO!",
          tags$i("Revise si el paciente fue ingresado previamente"),br(),br(),
          tags$code(e$message)
        )
      )
    })
    
  })
  
  shiny::observeEvent(input$dismiss_modal, {
    shiny::removeModal()
  })
  
  shiny::observeEvent(input$final_edit, {
    
    shiny::removeModal()
    tmp <- input$ncorrida
    updateTextInput(session, "ncorrida", value = 0)
    updateTextInput(session, "ncorrida", value = tmp)
    
  })
  
  output$Prov <- renderUI({
    if(is.null(input$procedencia))
      return()
    
    edit_row <- which(stringr::str_detect(inputData()$EDITAR, 
                                          pattern = paste0("\\b",
                                                           input$current_id, "\\b") ))
    provin <- inputData()[edit_row, ][["PROVINCIA"]]
    user <- credentials()$info[["user"]]
    password <- user
    selectInput(inputId = "provincia",
                label = "Selecciona Provincia",
                choices = sqlProvincia(usr = user, pass = password,
                                       region = input$procedencia),
                selected = provin
    )
  })
  
  output$Dis <- renderUI({
    if(is.null(input$provincia))
      return()
    
    edit_row <- which(stringr::str_detect(inputData()$EDITAR, 
                                          pattern = paste0("\\b", 
                                                           input$current_id, "\\b") ))
    user <- credentials()$info[["user"]]
    password <- user
    distrito <- inputData()[edit_row, ][["DISTRITO"]]
    selectInput(inputId = "distrito",
                label = "Selecciona Distrito",
                choices = sqlDistrito(usr = user, pass = password, 
                                      provincia = input$provincia, 
                                      region = input$procedencia),
                selected = distrito)
  })
  
  
  output$Page <- renderUI({
    req(credentials()$user_auth)
    if(is.null(credentials()$user_auth)){
      return()
    }
    UdateData
  })
  
}
shinyApp(ui = ui, server = server)

# Run the application 
