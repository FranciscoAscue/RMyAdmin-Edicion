### local host and port
options( shiny.host = '192.168.128.110' )
options( shiny.port = 5050 )
#options( shiny.maxRequestSize = 100*1024^2 ) 

corridaActual = c(1031,1029)

user_base <- tibble::tibble(
  user = c("alicia", "princesa", "vanesa", "steve","iris","luis",
           "veronica","wendy", "user1"),
  password = sapply(c("alicia001", "princesa001", "vanesa001", 
                      "steve001","iris001","luis001","veronica001",
                      "wendy001","user001"), sodium::password_store),
  permissions = c("standard", "standard","standard", "standard",
                  "standard", "standard","admin", "standard", "standard"),
  name = c("User", "User","User", "User","User", "User","User", "User", "Usuario001")
)