### local host and port
options( shiny.host = '192.168.128.110' )
options( shiny.port = 5050 )
#options( shiny.maxRequestSize = 100*1024^2 ) 

corridaActual = c(1,2,500, 1032)

user_base <- tibble::tibble(
  user = c("alicia", "princesa", "vanesa", "steve","iris","luis",
           "veronica","wendy", "karla","user1", "user4", "user5"),
  password = sapply(c("alicia001", "princesa001", "vanesa001", 
                      "steve001","iris001","luis001","veronica001",
                      "wendy001","karla001","ins2021","ins2021", "ins2021"), sodium::password_store),
  permissions = c("standard", "standard","standard", "standard",
                  "standard", "standard","admin", "standard", "standard","standard","standard", "standard"),
  name = c("Alicia", "Princesa","Vanesa", "Steve","Iris", "Luis",
           "Veronica", "Wendy", "Karla","Usuario001","Usuario004","Usuario005")
)