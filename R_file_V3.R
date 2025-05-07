## ---------------------------
##
## Script name: R_file_V3
##
## Purpose of script: Create a shiny app, which creates teams by randomly drawing
##                    players from a (pre)specified list. 
##
## Author: Gerrit Stahn
##
## Date Created: 2025-05-07
## Last Update: 2025-05-07
##
## Copyright (c) Gerrit Stahn, 2025
## Email: gerrit.stahn@wiwi.uni-halle.de
##

## -----------------------------------------------------------------------------
## Start
## -----------------------------------------------------------------------------

# Install necessary packages if not already installed
# install.packages(c("shiny", "shinyjqui", "writexl"))

library(shiny)        # For the UI and server structure
library(shinyjqui)    # For making UI elements sortable via drag and drop
library(writexl)      # For exporting Excel files

# ------------------ SERVER START ------------------

# Read player list from RDS file or initialize if file doesn't exist
if (file.exists("spieler.rds")) {
  start_liste <- readRDS("spieler.rds")
  spieler_liste <- sort(unlist(start_liste)) # Sort by Name
} else {
  start_liste <- character(0)
  spieler_liste <- sort(unlist(start_liste)) # Sort by Name
  saveRDS(spieler_liste, "spieler.rds")
}

# ------------------ UI DEFINITION ------------------

ui <- fluidPage(
  titlePanel("Team Zuteilung mit persistenter Namensliste"),  # Team assignment with persistent name list
  sidebarLayout(
    sidebarPanel(
      h4("Mitspielerliste verwalten"),  # Manage player list
      textInput("new_player", "Neuen Namen hinzufügen:"),  # Add new name
      actionButton("add_player", "Hinzufügen"),            # Add
      hr(),
      selectInput("remove_player", "Namen entfernen:", choices = NULL),  # Remove name
      actionButton("delete_player", "Entfernen"),                       # Remove
      hr(),
      h4("Auswahl für Teambildung:"),  # Selection for team formation
      checkboxGroupInput("selected_players", label = NULL, choices = spieler_liste, selected = spieler_liste),
      hr(),
      numericInput("num_teams", "Anzahl der Teams:", value = 2, min = 2, max = 6),  # Number of teams
      actionButton("randomize", "Zufällige Teams"),                                 # Random teams
      hr(),
      uiOutput("modify_teams_ui"),   # UI to allow editing teams (dynamic content)
      hr(),
      downloadButton("download_excel", "Download Excel")  # Download Excel
    ),
    mainPanel(
      h3("Teams"),          # Teams
      uiOutput("team_ui")   # Team output (dynamic)
    )
  )
)

# ------------------ SERVER LOGIC ------------------

server <- function(input, output, session) {
  spieler <- reactiveVal(spieler_liste)  # Reactive player list
  teams <- reactiveVal(list())           # Reactive team list
  
  # Add player
  observeEvent(input$add_player, {
    name <- trimws(input$new_player)
    if (nzchar(name)) {
      updated <- unique(c(spieler(), name))
      spieler(updated)
      saveRDS(updated, "spieler.rds")  # Save updated list persistently
      updateTextInput(session, "new_player", value = "")  # Reset input
    }
  })
  
  # Remove player
  observeEvent(input$delete_player, {
    updated <- setdiff(spieler(), input$remove_player)
    spieler(updated)
    saveRDS(updated, "spieler.rds")  # Save updated list
  })
  
  # Update checkbox and dropdown inputs when player list changes
  observe({
    updateCheckboxGroupInput(session, "selected_players", choices = spieler(), selected = NULL)
    updateSelectInput(session, "remove_player", choices = spieler())
  })
  
  # Generate random teams
  observeEvent(input$randomize, {
    names <- input$selected_players
    num_teams <- input$num_teams
    num_names <- length(names)
    
    # Validation
    validate(
      need(num_names > 0, "Fehler: Bitte wähle mindestens einen Mitspieler aus."),  # Error: Select at least one player
      need(num_names >= num_teams, "Fehler: Zu wenige Spieler für diese Teamanzahl."),  # Error: Not enough players for that many teams
      need((num_names %% num_teams == 0) || (num_names %/% num_teams >= 2),
           "Fehler: Jedes Team muss mindestens zwei Spieler haben.")  # Error: Each team must have at least two players
    )
    
    # Shuffle and split names into teams
    shuffled_names <- sample(names)
    split_teams <- split(shuffled_names, rep(1:num_teams, length.out = num_names))
    team_list <- setNames(split_teams, paste0("Team ", 1:num_teams))
    teams(team_list)
  })
  
  # Render team UI (sortable via jQuery)
  output$team_ui <- renderUI({
    req(length(teams()) > 0)
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
  
  # Render UI for modifying teams (add/remove players)
  output$modify_teams_ui <- renderUI({
    req(length(teams()) > 0)
    tagList(
      h4("Teams bearbeiten"),  # Edit teams
      textInput("new_name", "Füge Namen hinzu:", ""),  # Add name:
      selectInput("team_select_add", "Wähle ein Team aus:", choices = names(teams())),  # Choose a team
      actionButton("add_name", "Füge Namen zum Team hinzu"),  # Add name to team
      hr(),
      selectInput("team_select_remove", "Wähle ein Team aus:", choices = names(teams())),  # Choose a team
      selectInput("name_select_remove", "Wähle Namen aus:", choices = NULL),               # Choose name
      actionButton("remove_name", "Entferne Namen vom Team")                               # Remove name from team
    )
  })
  
  # Update name selection for removal based on selected team
  observe({
    req(input$team_select_remove)
    team_data <- teams()
    updateSelectInput(session, "name_select_remove", choices = team_data[[input$team_select_remove]])
  })
  
  # Add name to team
  observeEvent(input$add_name, {
    req(input$new_name, input$team_select_add)
    current_teams <- teams()
    current_teams[[input$team_select_add]] <- c(current_teams[[input$team_select_add]], input$new_name)
    teams(current_teams)
    updateTextInput(session, "new_name", value = "")
  })
  
  # Remove name from team
  observeEvent(input$remove_name, {
    req(input$team_select_remove, input$name_select_remove)
    current_teams <- teams()
    current_teams[[input$team_select_remove]] <- setdiff(current_teams[[input$team_select_remove]], input$name_select_remove)
    teams(current_teams)
    updateSelectInput(session, "name_select_remove", choices = current_teams[[input$team_select_remove]])
  })
  
  # Export teams to Excel file
  output$download_excel <- downloadHandler(
    filename = function() { paste0("Team_Distribution_", Sys.Date(), ".xlsx") },
    content = function(file) {
      team_data <- teams()
      team_sheets <- lapply(team_data, function(names) data.frame(Name = names))
      write_xlsx(team_sheets, path = file)
    }
  )
}

# Launch the Shiny app
shinyApp(ui, server)
