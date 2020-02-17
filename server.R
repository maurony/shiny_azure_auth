library(AzureAuth)
library(shiny)

resource <- "https://management.azure.com"
tenant <- Sys.getenv("TENANT_ID") 
app <- Sys.getenv("APP_ID") 

# set this to the site URL of your app once it is deployed
# this must also be the redirect for your registered app in Azure Active Directory
redirect <- "http://localhost:6744"

options(shiny.port=as.numeric(httr::parse_url(redirect)$port))

# replace this with your app's regular UI
ui <- fluidPage(
  verbatimTextOutput("token")
)

ui_func <- function(req)
{
  opts <- parseQueryString(req$QUERY_STRING)
  if(is.null(opts$code))
  {
    auth_uri <- build_authorization_uri(resource, tenant, app, redirect_uri=redirect)
    redir_js <- sprintf("location.replace(\"%s\");", auth_uri)
    tags$script(HTML(redir_js))
  }
  else ui
}

server <- function(input, output, session)
{
  opts <- parseQueryString(isolate(session$clientData$url_search))
  if(is.null(opts$code))
    return()
  
  token <- get_azure_token(resource, tenant, app, authorize_args=list(redirect_uri=redirect),
                           use_cache=FALSE, auth_code=opts$code)
  
  output$token <- renderPrint(token)
}

shinyApp(ui_func, server)