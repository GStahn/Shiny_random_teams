# install.packages(c("shiny", "shinyjqui", "rmarkdown"))

setwd("/Users/apxww/Library/Mobile Documents/com~apple~CloudDocs/GitHub/Shiny_random_teams")

library(shiny)
library(shinyjqui)
library(writexl)

ui <- fluidPage(
  titlePanel("Team Zuteilung"),
  sidebarLayout(
    sidebarPanel(
      textAreaInput("name_input", "Gebe Namen ein (einen pro Zeile):", rows = 10),
      numericInput("num_teams", "Anzahl der Teams:", value = 2, min = 2, max = 6),
      actionButton("randomize", "Zufällige Teams"),
      hr(),
      
      # UI for adding and removing names (only visible after randomization)
      uiOutput("modify_teams_ui"),
      
      hr(),
      downloadButton("download_excel", "Download Excel")
    ),
    mainPanel(
      h3("Teams"),
      uiOutput("team_ui")
    )
  )
)

server <- function(input, output, session) {
  teams <- reactiveVal(list())
  
  observeEvent(input$randomize, {
    names <- unlist(strsplit(input$name_input, "\n"))
    names <- names[names != ""]  # Remove empty lines
    num_teams <- input$num_teams
    num_names <- length(names)
    
    # Validation: Check if distribution is valid
    validate(
      need(num_names > 0, "Fehler: Bitte gebe einen Namen ein."),
      need(num_names >= num_teams, "Fehler: Die Anzahl der Teams kann nicht die Anzahl an Spielern überschreiten."),
      need((num_names %% num_teams == 0) || (num_names %/% num_teams >= 2),
           "Fehler: Jedes Team muss mindestens zwei Spieler haben.")
    )
    
    # Randomly assign names to teams
    shuffled_names <- sample(names)
    split_teams <- split(shuffled_names, rep(1:num_teams, length.out = length(names)))
    
    team_list <- setNames(split_teams, paste0("Team ", 1:num_teams))
    teams(team_list)
  })
  
  # Dynamic UI for modifying teams (only shown after randomization)
  output$modify_teams_ui <- renderUI({
    req(length(teams()) > 0)  # Only show after teams exist
    
    tagList(
      h4("Modify Teams"),
      
      # Add a name UI
      textInput("new_name", "Füge Namen hinzu:", ""),
      selectInput("team_select_add", "Wähle ein Team aus:", choices = names(teams())),
      actionButton("add_name", "Füge Namen zum Team hinzu"),
      
      hr(),
      
      # Remove a name UI
      selectInput("team_select_remove", "Wähle ein Team aus:", choices = names(teams())),
      selectInput("name_select_remove", "Wähle Namen aus:", choices = NULL),
      actionButton("remove_name", "Entferne Namen vom Team")
    )
  })
  
  # Update names dropdown when a team is selected for removal
  observe({
    req(input$team_select_remove)
    team_data <- teams()
    updateSelectInput(session, "name_select_remove",
                      choices = team_data[[input$team_select_remove]])
  })
  
  # Add a new name to a selected team
  observeEvent(input$add_name, {
    req(input$new_name, input$team_select_add)  # Ensure inputs are not empty
    current_teams <- teams()
    
    # Append the new name to the selected team
    current_teams[[input$team_select_add]] <- c(current_teams[[input$team_select_add]], input$new_name)
    teams(current_teams)
    
    # Clear input after adding
    updateTextInput(session, "new_name", value = "")
  })
  
  # Remove a name from a selected team
  observeEvent(input$remove_name, {
    req(input$team_select_remove, input$name_select_remove)
    current_teams <- teams()
    
    # Remove selected name
    current_teams[[input$team_select_remove]] <- setdiff(current_teams[[input$team_select_remove]], input$name_select_remove)
    teams(current_teams)
    
    # Update name selection dropdown
    updateSelectInput(session, "name_select_remove", choices = current_teams[[input$team_select_remove]])
  })
  
  output$team_ui <- renderUI({
    validate(
      need(length(teams()) > 0, "Keine Teams generiert. Klicke 'Zufällige Teams'.")
    )
    
    team_data <- teams()
    
    lapply(names(team_data), function(team) {
      tagList(
        h4(team),
        jqui_sortable(
          div(id = team, class = "team-box", lapply(team_data[[team]], function(name) {
            div(class = "sortable-item", name)
          }))
        )
      )
    })
  })
  
  output$download_excel <- downloadHandler(
    filename = function() { paste0("Team_Distribution_", Sys.Date(), ".xlsx") },
    content = function(file) {
      team_data <- teams()
      
      # Convert teams into a format suitable for Excel export
      team_sheets <- lapply(team_data, function(names) data.frame(Name = names))
      
      # Write to Excel file
      writexl::write_xlsx(team_sheets, path = file)
    }
  )
}

shinyApp(ui, server)
