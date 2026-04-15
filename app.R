## ---------------------------
##
## Script name: app.R
##
## Purpose of script: Create a Shiny app that generates teams by randomly drawing
##                    players from a predefined list.
##
## Version: 0.3.0
##
## Author: Gerrit Stahn
##
## Date Created: 2026-04-04
## Last Update: 2026-04-05
##
## Copyright (c) Gerrit Stahn, 2026
## Email: gerrit.stahn@wiwi.uni-halle.de
##

## -----------------------------------------------------------------------------
## Notes:
## -----------------------------------------------------------------------------

# In an earlier version, the player list was stored locally as a file,
# instead of a Google Spreadsheet located in a specific Google Drive folder.
#
# As of today, a Google Spreadsheet is a very practical solution if:
# - the player list should be shared across multiple users,
# - changes should persist between sessions,
# - the app is deployed on a server,
# - and you want a simple cloud-based storage option without setting up a database.
#
# For local testing or simple standalone use, a predefined in-code player list
# is often easier. This is what is used below.
#
# IMPORTANT:
# The predefined player list below is only meant as a temporary/local solution.
# This section should be removed or replaced once you use any external deployment
# or any persistent storage solution such as:
# - Google Sheets
# - a local .rds or .csv file on the server
# - an SQL database
# - or any other external backend

## -----------------------------------------------------------------------------
## Start
## -----------------------------------------------------------------------------

# Install necessary packages if they are not already installed
# install.packages(c(
#   "shiny", "writexl", "gridExtra", "shinymanager",
#   "googlesheets4", "googledrive", "dplyr", "bslib", "bsicons"
# ))

library(shiny)
# library(writexl) # Disabled: Excel export commented out
library(gridExtra)
library(grid)
library(shinymanager)
# library(googledrive)   # Disabled: Google Drive integration commented out
# library(googlesheets4) # Disabled: Google Sheets integration commented out
library(dplyr)
library(bslib)

# ------------------ PREDEFINED PLAYER LIST ------------------

# Temporary local player list used for development/testing.
# IMPORTANT:
# Delete or replace this section once the app is deployed with external storage.
# Otherwise, every fresh app start will fall back to this hardcoded list.
player_list <- sort(c(
  "Mark Grayson",
  "Debbie Grayson",
  "Nolan Grayson",
  "Oliver Grayson",
  "Atom Eve",
  "Samantha Eve Wilkins",
  "Amber Bennett",
  "William Clockwell",
  "Rex Splode",
  "Dupli-Kate",
  "Shrinking Rae",
  "Robot",
  "Rudy Connors",
  "Monster Girl",
  "Amanda",
  "Black Samson",
  "Darkwing",
  "Green Ghost",
  "Aquarus",
  "War Woman",
  "Immortal",
  "Cecil Stedman",
  "Donald Ferguson",
  "Art Rosenbaum",
  "Allen the Alien",
  "Anissa",
  "Thaedus",
  "Lucan",
  "Kregg",
  "Conquest"
))

# ------------------ GOOGLE DRIVE / GOOGLE SHEETS SETUP ------------------

# The section below is intentionally commented out.
# It can be enabled if you want to store the player list in a shared
# Google Spreadsheet again.
#
# HOW TO SET UP SUCH A GOOGLE SHEETS SOLUTION (AS OF APRIL 2026):
#
# 1. Create a Google Cloud project
#    - Go to the Google Cloud Console.
#    - Create a new project or use an existing one.
#
# 2. Enable the required APIs
#    - Enable the Google Drive API
#    - Enable the Google Sheets API
#
# 3. Create credentials
#    - Create either OAuth credentials or, in many server setups,
#      a service account.
#    - Download the JSON credential file.
#
# 4. Store the JSON file securely
#    - Place the JSON file somewhere outside public app folders if possible.
#    - In this script, the file path would be passed to gs4_auth() and drive_auth().
#
# 5. Create or choose a target Google Drive folder
#    - In Google Drive, create a folder that should hold the spreadsheet.
#    - Copy the folder URL and use it as FOLDER_URL.
#
# 6. Define spreadsheet and worksheet names
#    - SHEET_NAME is the file name of the spreadsheet in Google Drive.
#    - WORKSHEET_NAME is the tab name inside the spreadsheet.
#
# 7. Share access correctly
#    - If you use OAuth with your own Google account, log in once and cache credentials.
#    - If you use a service account, share the Google Drive folder or spreadsheet
#      with the service account email address.
#
# 8. First app start
#    - On first run, the script can either find the spreadsheet in the folder
#      or create it automatically if it does not exist.
#    - It can also create the worksheet/tab and write an empty Name column.
#
# 9. Ongoing use
#    - The app reads the player names from the sheet at startup.
#    - Whenever players are added or removed, the app writes the updated list back.
#
# WHY THIS IS USEFUL:
# - the player list survives app restarts
# - multiple users can work with the same source
# - no separate database is required
# - data management remains simple and transparent
#
# POTENTIAL DRAWBACKS:
# - requires Google authentication
# - app deployment becomes slightly more complex
# - external API availability is required
# - permissions must be configured correctly

# FOLDER_URL <- "[YOUR FOLDER URL]"
# SHEET_NAME <- "[YOUR SHEET NAME]"
# WORKSHEET_NAME <- "[YOUR WORKSHEET NAME]"

# Store OAuth cache locally
# options(gargle_oauth_cache = ".secrets")

# On first launch, authentication is done via browser login
# gs4_auth(path = "[YOUR JSON FILE NAME].json")
# drive_auth(path = "[YOUR JSON FILE NAME].json")

# Helper function: find spreadsheet in target folder or create a new one
# get_or_create_player_sheet <- function(folder_url, sheet_name, worksheet_name = "Players") {
#   
#   folder_id <- as_id(folder_url)
#   
#   # List all spreadsheet files in the target folder
#   files_in_folder <- drive_ls(
#     path = folder_id,
#     type = "spreadsheet"
#   )
#   
#   existing_sheet <- files_in_folder %>%
#     filter(name == sheet_name)
#   
#   if (nrow(existing_sheet) > 0) {
#     ss <- as_sheets_id(existing_sheet$id[[1]])
#     
#     # Check whether the requested worksheet already exists
#     existing_tabs <- sheet_names(ss)
#     if (!(worksheet_name %in% existing_tabs)) {
#       sheet_add(ss, sheet = worksheet_name)
#       sheet_write(
#         data.frame(Name = character(), stringsAsFactors = FALSE),
#         ss = ss,
#         sheet = worksheet_name
#       )
#     }
#     
#     return(ss)
#   }
#   
#   # Create a new spreadsheet inside the target folder
#   new_file <- drive_create(
#     name = sheet_name,
#     path = folder_id,
#     type = "spreadsheet"
#   )
#   
#   ss <- as_sheets_id(new_file$id[[1]])
#   
#   # Rename default worksheet or write initial data
#   existing_tabs <- sheet_names(ss)
#   
#   if (length(existing_tabs) > 0) {
#     # Rename default sheet if needed
#     if (existing_tabs[1] != worksheet_name) {
#       sheet_rename(ss, sheet = existing_tabs[1], new_name = worksheet_name)
#     }
#   } else {
#     sheet_add(ss, sheet = worksheet_name)
#   }
#   
#   # Write empty initial table
#   sheet_write(
#     data.frame(Name = character(), stringsAsFactors = FALSE),
#     ss = ss,
#     sheet = worksheet_name
#   )
#   
#   ss
# }

# Helper function: read player list from Google Sheet
# read_players_from_sheet <- function(ss, worksheet_name = "Players") {
#   df <- read_sheet(
#     ss,
#     sheet = worksheet_name,
#     col_types = "c"
#   )
#   
#   if (!"Name" %in% names(df)) {
#     return(character(0))
#   }
#   
#   players <- df$Name
#   players <- players[!is.na(players)]
#   players <- trimws(players)
#   players <- players[nzchar(players)]
#   
#   sort(unique(players))
# }

# Helper function: write full player list to Google Sheet
# write_players_to_sheet <- function(players, ss, worksheet_name = "Players") {
#   df <- data.frame(
#     Name = sort(unique(players)),
#     stringsAsFactors = FALSE
#   )
#   
#   sheet_write(df, ss = ss, sheet = worksheet_name)
# }

# Initialize spreadsheet
# player_sheet <- get_or_create_player_sheet(
#   folder_url = FOLDER_URL,
#   sheet_name = SHEET_NAME,
#   worksheet_name = WORKSHEET_NAME
# )

# Load player list initially from Google Sheet
# player_list <- read_players_from_sheet(
#   ss = player_sheet,
#   worksheet_name = WORKSHEET_NAME
# )

# Compatibility helper:
# In the current app version, write_players_to_sheet(...) may still be called
# in the server logic. This fallback function avoids errors while the Google
# Sheets integration is disabled.
write_players_to_sheet <- function(players, ss = NULL, worksheet_name = NULL) {
  invisible(NULL)
}

# Optional placeholders so old references do not break the app
player_sheet <- NULL
WORKSHEET_NAME <- NULL

# ------------------ PASSWORD PROTECTION ------------------

# Auto-logout after inactivity
inactivity <- "function idleTimer() {
var t = setTimeout(logout, 120000);
window.onmousemove = resetTimer;
window.onmousedown = resetTimer;
window.onclick = resetTimer;
window.onscroll = resetTimer;
window.onkeypress = resetTimer;

function logout() {
window.close();
}

function resetTimer() {
clearTimeout(t);
t = setTimeout(logout, 120000);
}
}
idleTimer();"

# Define usernames and passwords
credentials <- data.frame(
  user = c("1", "hello", "bye"),
  password = c("1", "world", "world"),
  stringsAsFactors = FALSE
)

# ------------------ UI DEFINITION ------------------

css <- "
.app-title {
  margin-bottom: 20px;
}
.sidebar-section {
  margin-bottom: 20px;
}
/* Footer */
.app-footer {
  margin-top: 40px;
  text-align: center;
  font-size: 0.75rem;
  color: #666;
}
"

# Custom Bootstrap theme
theme_custom <- bs_theme(
  version = 5,
  
  # Base colors
  bg = "#FFFFFF",
  fg = "#000000",
  primary = "#205585",
  secondary = "#E1BD4E",
  success = "#205585",
  info = "#E1BD4E",
  warning = "#E1BD4E",
  danger = "#000000",
  
  # Typography
  base_font = font_google("Inter"),
  heading_font = font_google("Poppins"),
  code_font = font_google("Fira Code"),
  
  # Slightly smaller font sizes
  base_font_size = "0.9rem",
  "h1-font-size" = "1.8rem",
  "h2-font-size" = "1.5rem",
  "h3-font-size" = "1.25rem",
  "h4-font-size" = "1.1rem",
  
  # General style
  "body-color" = "#000000",
  "body-bg" = "#FFFFFF",
  "border-color" = "#D9D9D9",
  "border-radius" = "0.7rem",
  "btn-border-radius" = "0.7rem",
  "card-border-radius" = "0.9rem",
  "input-border-radius" = "0.6rem",
  
  # Compact buttons
  "btn-padding-y" = "0.45rem",
  "btn-padding-x" = "1rem",
  "btn-font-weight" = "600",
  
  # Navbar
  "navbar-bg" = "#205585",
  "navbar-light-color" = "#FFFFFF",
  "navbar-light-hover-color" = "#E1BD4E",
  "navbar-light-active-color" = "#E1BD4E",
  
  # Cards
  "card-bg" = "#FFFFFF",
  "card-border-color" = "#EAEAEA",
  "card-box-shadow" = "0 4px 12px rgba(0, 0, 0, 0.08)",
  
  # Links
  "link-color" = "#205585",
  "link-hover-color" = "#163B5C",
  
  # Inputs
  "input-focus-border-color" = "#205585",
  "input-focus-box-shadow" = "0 0 0 0.2rem rgba(32, 85, 133, 0.25)"
)

ui <- fluidPage(
  theme = theme_custom,
  style = "padding-top:30px; padding-bottom:18px;",
  
  sidebarLayout(
    
    sidebarPanel(
      
      div(
        class = "sidebar-section",
        h4("Manage player list"),
        textInput("new_player", "Add new name:"),
        actionButton("add_player", "Add"),
        div(class = "section-divider"),
        selectInput("remove_player", "Remove name:", choices = NULL),
        actionButton("delete_player", "Remove")
      ),
      
      div(style = "margin-top:30px;"),
      
      div(
        class = "sidebar-section",
        uiOutput("selection_h4"),
        uiOutput("player_selection_ui"),
        div(style = "margin-top:12px;"),
        uiOutput("select_all_button")
      ),
      
      div(style = "margin-top:30px;"),
      
      div(
        class = "sidebar-section",
        h4("Team creation"),
        numericInput("num_teams", "Number of teams:", value = 2, min = 2, max = 6),
        actionButton("randomize", "Randomize teams")
      ),
      
      div(style = "margin-top:30px;"),
      
      div(
        class = "sidebar-section",
        uiOutput("modify_teams_ui")
      )
      
    ),
    
    mainPanel(
      h3(style = "color:#205585; font-weight:700;", "Teams"),
      uiOutput("team_ui"),
      uiOutput("captain_warning_ui"),
      uiOutput("download_ui")
    ) )
  
  # You can add a feedback button: Just uncomment and delete the second ")" after 
  # mainPanel
  # ),
  # div(
  #   class = "app-footer",
  #   tags$a(
  #     href = paste0(
  #       "mailto:[YOUR Mail]",
  #       "?subject=Feedback on Team App",
  #       "&body=Hello [YOUR NAME],%0D%0A%0D%0A",
  #       "I have the following feedback on the Team App:%0D%0A%0D%0A"
  #     ),
  #     class = "btn btn-link btn-sm",
  #     "Send feedback"
  #   )
  # )
)

ui <- secure_app(
  ui,
  theme = theme_custom,
  tags_top = tags$div(
    tags$head(tags$style(css)),
    tags$img(
      src = "https://www.sc261.de/images/layout/SC261.svg", # add an url for your own image here
      width = 200,
      height = 200,
      alt = "Logo not found",
      deleteFile = FALSE
    )
  )
)

# ------------------ SERVER LOGIC ------------------

server <- function(input, output, session) {
  
  # User authentication
  auth_result <- secure_server(
    check_credentials = check_credentials(credentials)
  )
  
  # Main reactive app state
  players <- reactiveVal(sort(player_list))
  teams <- reactiveVal(list())
  selected_captains <- reactiveVal(character(0))
  captain_warning <- reactiveVal(NULL)
  
  selected_players_state <- reactiveVal(
    setNames(rep(FALSE, length(player_list)), player_list)
  )
  captain_state <- reactiveVal(
    setNames(rep(FALSE, length(player_list)), player_list)
  )
  
  # Helper function:
  # Keep player selection state aligned with the current player list
  sync_states <- function(current_players) {
    old_selected <- selected_players_state()
    old_captains <- captain_state()
    
    new_selected <- setNames(rep(FALSE, length(current_players)), current_players)
    new_captains <- setNames(rep(FALSE, length(current_players)), current_players)
    
    common_selected <- intersect(names(old_selected), current_players)
    common_captains <- intersect(names(old_captains), current_players)
    
    if (length(common_selected) > 0) {
      new_selected[common_selected] <- old_selected[common_selected]
    }
    if (length(common_captains) > 0) {
      new_captains[common_captains] <- old_captains[common_captains]
    }
    
    # Players marked as captains should not also be marked as regular selected players
    new_selected[new_captains] <- FALSE
    
    selected_players_state(new_selected)
    captain_state(new_captains)
  }
  
  # Check whether captain assignments are still valid
  update_captain_warning <- function() {
    if (length(teams()) == 0) {
      captain_warning(NULL)
      return()
    }
    
    team_data <- teams()
    available_captains <- selected_captains()
    
    selected_dropdown_captains <- sapply(seq_along(team_data), function(i) {
      value <- input[[paste0("captain_team_", i)]]
      if (is.null(value) || identical(value, "")) {
        if (length(team_data[[i]]) > 0) team_data[[i]][1] else ""
      } else {
        value
      }
    }, USE.NAMES = FALSE)
    
    if (length(available_captains) == 0) {
      captain_warning(NULL)
      return()
    }
    
    if (length(unique(selected_dropdown_captains)) != length(selected_dropdown_captains)) {
      captain_warning("Not all selected captains are uniquely assigned across the teams. Please assign a different captain to each team.")
      return()
    }
    
    if (!setequal(selected_dropdown_captains, available_captains)) {
      captain_warning("Not all originally selected captains are currently assigned to exactly one team.")
      return()
    }
    
    captain_warning(NULL)
  }
  
  # Rebuild teams after manual captain reassignment in the dropdowns
  rebuild_teams_with_selected_captains <- function() {
    req(length(teams()) > 0)
    
    current_teams <- teams()
    available_captains <- selected_captains()
    
    if (length(available_captains) == 0) {
      return()
    }
    
    non_captain_members <- lapply(current_teams, function(team_vector) {
      setdiff(team_vector, available_captains)
    })
    
    selected_dropdown_captains <- sapply(seq_along(current_teams), function(i) {
      value <- input[[paste0("captain_team_", i)]]
      if (is.null(value) || identical(value, "")) {
        if (length(current_teams[[i]]) > 0) current_teams[[i]][1] else ""
      } else {
        value
      }
    }, USE.NAMES = FALSE)
    
    rebuilt_teams <- lapply(seq_along(current_teams), function(i) {
      captain_i <- selected_dropdown_captains[i]
      members_i <- non_captain_members[[i]]
      
      if (nzchar(captain_i)) {
        c(captain_i, members_i)
      } else {
        members_i
      }
    })
    
    names(rebuilt_teams) <- names(current_teams)
    teams(rebuilt_teams)
  }
  
  # Get current captains from the first position of each team
  get_current_captains_for_export <- function() {
    if (length(teams()) == 0) {
      return(character(0))
    }
    
    sapply(teams(), function(team_vector) {
      if (length(team_vector) > 0) team_vector[1] else ""
    }, USE.NAMES = FALSE)
  }
  
  # ------------------ MANAGE PLAYER LIST ------------------
  
  observeEvent(input$add_player, {
    name <- trimws(input$new_player)
    
    if (!nzchar(name)) {
      return(NULL)
    }
    
    updated <- sort(unique(c(players(), name)))
    players(updated)
    write_players_to_sheet(updated, player_sheet, WORKSHEET_NAME)
    sync_states(updated)
    
    updateTextInput(session, "new_player", value = "")
  })
  
  observeEvent(input$delete_player, {
    req(input$remove_player)
    
    player_to_delete <- input$remove_player
    
    if (player_to_delete %in% selected_captains()) {
      showModal(
        modalDialog(
          title = "Error",
          paste0(
            player_to_delete,
            " is currently a captain and therefore cannot be removed from the player list."
          ),
          easyClose = TRUE,
          footer = modalButton("Close")
        )
      )
      return(NULL)
    }
    
    updated <- sort(setdiff(players(), player_to_delete))
    players(updated)
    write_players_to_sheet(updated, player_sheet, WORKSHEET_NAME)
    sync_states(updated)
    
    updateSelectInput(session, "remove_player", choices = updated)
  })
  
  observe({
    current_players <- players()
    sync_states(current_players)
    
    updateSelectInput(
      session,
      "remove_player",
      choices = current_players
    )
  })
  
  # ------------------ PLAYER SELECTION + CAPTAIN SELECTION ------------------
  
  output$selection_h4 <- renderUI({
    selected_count <- sum(selected_players_state(), na.rm = TRUE) +
      sum(captain_state(), na.rm = TRUE)
    
    h4(paste0("Selection for team creation (", selected_count, " selected):"))
  })
  
  output$player_selection_ui <- renderUI({
    current_players <- players()
    selected_state <- selected_players_state()
    captain_values <- captain_state()
    
    tagList(
      fluidRow(
        column(6, tags$b("Name")),
        column(3, tags$b("Present"), align = "center"),
        column(3, tags$b("Captain"), align = "center")
      ),
      tags$hr(style = "margin-top:5px; margin-bottom:10px; border-color:#205585;"),
      lapply(current_players, function(player) {
        fluidRow(
          style = "margin-bottom:8px;",
          column(6, tags$div(style = "padding-top:6px;", player)),
          column(
            3, align = "center",
            if (!isTRUE(captain_values[player])) {
              checkboxInput(
                inputId = paste0("select_player_", make.names(player)),
                label = NULL,
                value = isTRUE(selected_state[player])
              )
            } else {
              tags$div(style = "padding-top:6px; color:#999;", "-")
            }
          ),
          column(
            3, align = "center",
            checkboxInput(
              inputId = paste0("captain_player_", make.names(player)),
              label = NULL,
              value = isTRUE(captain_values[player])
            )
          )
        )
      })
    )
  })
  
  # Create dynamic observers for all player checkboxes
  observe({
    lapply(players(), function(player) {
      local({
        current_player <- player
        safe_name <- make.names(current_player)
        
        observeEvent(input[[paste0("captain_player_", safe_name)]], {
          current_captains <- captain_state()
          current_selected <- selected_players_state()
          
          is_captain_now <- isTRUE(input[[paste0("captain_player_", safe_name)]])
          current_captains[current_player] <- is_captain_now
          
          if (is_captain_now) {
            current_selected[current_player] <- TRUE
          }
          
          captain_state(current_captains)
          selected_players_state(current_selected)
        }, ignoreInit = TRUE)
        
        observeEvent(input[[paste0("select_player_", safe_name)]], {
          current_selected <- selected_players_state()
          
          if (!isTRUE(captain_state()[current_player])) {
            current_selected[current_player] <- isTRUE(input[[paste0("select_player_", safe_name)]])
            selected_players_state(current_selected)
          }
        }, ignoreInit = TRUE)
      })
    })
  })
  
  output$select_all_button <- renderUI({
    current_players <- players()
    current_selected <- selected_players_state()
    current_captains <- captain_state()
    
    non_captains <- current_players[!current_captains[current_players]]
    captains <- current_players[current_captains[current_players]]
    
    all_non_captains_selected <- length(non_captains) == 0 || all(current_selected[non_captains])
    all_captains_selected <- length(captains) == 0 || all(current_captains[captains])
    
    all_active <- all_non_captains_selected && all_captains_selected
    
    label <- if (all_active) {
      "Deselect all"
    } else {
      "Mark all as present"
    }
    
    actionButton("select_all_present", label)
  })
  
  observeEvent(input$select_all_present, {
    
    current_players <- players()
    current_selected <- selected_players_state()
    current_captains <- captain_state()
    
    non_captains <- current_players[!current_captains[current_players]]
    captains <- current_players[current_captains[current_players]]
    
    all_non_captains_selected <- length(non_captains) == 0 || all(current_selected[non_captains])
    all_captains_selected <- length(captains) == 0 || all(current_captains[captains])
    
    all_active <- all_non_captains_selected && all_captains_selected
    
    if (all_active) {
      new_selected <- setNames(rep(FALSE, length(current_players)), current_players)
      new_captains <- setNames(rep(FALSE, length(current_players)), current_players)
      
      selected_players_state(new_selected)
      captain_state(new_captains)
      
      lapply(current_players, function(player) {
        updateCheckboxInput(
          session,
          paste0("captain_player_", make.names(player)),
          value = FALSE
        )
        
        updateCheckboxInput(
          session,
          paste0("select_player_", make.names(player)),
          value = FALSE
        )
      })
      
    } else {
      new_selected <- setNames(rep(TRUE, length(current_players)), current_players)
      new_selected[current_captains] <- FALSE
      
      selected_players_state(new_selected)
      
      lapply(current_players, function(player) {
        if (!isTRUE(current_captains[player])) {
          updateCheckboxInput(
            session,
            paste0("select_player_", make.names(player)),
            value = TRUE
          )
        }
      })
    }
    
  })
  
  # ------------------ WARNING MESSAGE ------------------
  
  output$captain_warning_ui <- renderUI({
    req(length(teams()) > 0)
    
    if (is.null(captain_warning())) {
      return(NULL)
    }
    
    div(
      class = "warning-box",
      HTML(paste0("Warning: ", captain_warning()))
    )
  })
  
  # ------------------ DOWNLOAD UI ------------------
  
  output$download_ui <- renderUI({
    req(length(teams()) > 0)
    
    div(
      class = "download-box",
      h4(style = "color:#205585; font-weight:700;", "Export"),
      # downloadButton("download_excel", "Download Excel"),
      # tags$span(" "),
      downloadButton("download_pdf", "Download PDF")
    )
  })
  
  # ------------------ RANDOMIZATION ------------------
  
  observeEvent(input$randomize, {
    selected_state <- selected_players_state()
    captain_values <- captain_state()
    
    random_players <- names(selected_state[selected_state])
    captains <- names(captain_values[captain_values])
    num_teams <- input$num_teams
    num_captains <- length(captains)
    
    if (num_teams != num_captains) {
      showModal(
        modalDialog(
          title = "Error",
          paste0(
            "Error: The number of teams (=", num_teams,
            ") and the number of selected captains (=", num_captains,
            ") do not match."
          ),
          easyClose = TRUE,
          footer = modalButton("Close")
        )
      )
      return(NULL)
    }
    
    if (num_captains == 0) {
      showModal(
        modalDialog(
          title = "Error",
          "Error: Please select at least one captain.",
          easyClose = TRUE,
          footer = modalButton("Close")
        )
      )
      return(NULL)
    }
    
    shuffled_names <- sample(random_players)
    
    if (length(shuffled_names) > 0) {
      split_teams <- split(
        shuffled_names,
        rep(1:num_teams, length.out = length(shuffled_names))
      )
    } else {
      split_teams <- vector("list", num_teams)
      names(split_teams) <- as.character(1:num_teams)
      split_teams[] <- list(character(0))
    }
    
    full_teams <- vector("list", num_teams)
    for (i in seq_len(num_teams)) {
      if (!is.null(split_teams[[as.character(i)]])) {
        full_teams[[i]] <- split_teams[[as.character(i)]]
      } else if (!is.null(split_teams[[i]])) {
        full_teams[[i]] <- split_teams[[i]]
      } else {
        full_teams[[i]] <- character(0)
      }
    }
    
    # Place one captain at the beginning of each team
    for (i in seq_len(num_teams)) {
      full_teams[[i]] <- c(captains[i], full_teams[[i]])
    }
    
    team_list <- setNames(full_teams, paste0("Team ", seq_len(num_teams)))
    teams(team_list)
    selected_captains(captains)
    captain_warning(NULL)
  })
  
  # ------------------ TEAM OUTPUT ------------------
  
  output$team_ui <- renderUI({
    req(length(teams()) > 0)
    team_data <- teams()
    available_captains <- selected_captains()
    
    fluidRow(
      lapply(seq_along(team_data), function(i) {
        team_name <- names(team_data)[i]
        current_team <- team_data[[i]]
        
        current_dropdown_value <- input[[paste0("captain_team_", i)]]
        current_captain <- if (!is.null(current_dropdown_value) && current_dropdown_value != "") {
          current_dropdown_value
        } else if (length(current_team) > 0) {
          current_team[1]
        } else {
          ""
        }
        
        team_members_without_captain <- setdiff(current_team, available_captains)
        
        column(
          width = max(12 / length(team_data), 3),
          div(
            class = "team-card",
            h4(
              paste0(
                team_name, " - ",
                length(team_data[[team_name]]), " ",
                ifelse(length(team_data[[team_name]]) == 1, "person", "people")
              ),
              style = "text-align:center; font-weight:bold; color:#205585;"
            ),
            selectInput(
              inputId = paste0("captain_team_", i),
              label = "Captain:",
              choices = available_captains,
              selected = current_captain
            ),
            tags$ul(
              lapply(team_members_without_captain, function(name) {
                tags$li(name)
              })
            )
          )
        )
      })
    )
  })
  
  # Rebuild teams if captain dropdown selection changes
  observe({
    req(length(teams()) > 0)
    
    lapply(seq_along(teams()), function(i) {
      local({
        idx <- i
        
        observeEvent(input[[paste0("captain_team_", idx)]], {
          rebuild_teams_with_selected_captains()
          update_captain_warning()
        }, ignoreInit = TRUE)
      })
    })
  })
  
  # ------------------ EDIT TEAMS ------------------
  
  output$modify_teams_ui <- renderUI({
    req(length(teams()) > 0)
    
    tagList(
      h4("Edit teams"),
      textInput("new_name", "Add name:", ""),
      selectInput("team_select_add", "Choose a team:", choices = names(teams())),
      actionButton("add_name", "Add name to team"),
      div(class = "section-divider"),
      selectInput("team_select_remove", "Choose a team:", choices = names(teams())),
      selectInput("name_select_remove", "Choose a name:", choices = NULL),
      actionButton("remove_name", "Remove name from team")
    )
  })
  
  observe({
    req(input$team_select_remove)
    team_data <- teams()
    available_captains <- selected_captains()
    team_players <- team_data[[input$team_select_remove]]
    
    removable_players <- setdiff(team_players, available_captains)
    
    updateSelectInput(
      session,
      "name_select_remove",
      choices = removable_players
    )
  })
  
  observeEvent(input$add_name, {
    req(input$new_name, input$team_select_add)
    
    new_name <- trimws(input$new_name)
    
    if (!nzchar(new_name)) {
      showModal(
        modalDialog(
          title = "Error",
          "Error: Please enter a name.",
          easyClose = TRUE,
          footer = modalButton("Close")
        )
      )
      return(NULL)
    }
    
    current_teams <- teams()
    
    if (new_name %in% unique(unlist(current_teams))) {
      showModal(
        modalDialog(
          title = "Error",
          "Error: This person is already assigned to a team.",
          easyClose = TRUE,
          footer = modalButton("Close")
        )
      )
      return(NULL)
    }
    
    current_teams[[input$team_select_add]] <- c(
      current_teams[[input$team_select_add]],
      new_name
    )
    
    teams(current_teams)
    updateTextInput(session, "new_name", value = "")
    update_captain_warning()
  })
  
  observeEvent(input$remove_name, {
    req(input$team_select_remove, input$name_select_remove)
    
    current_teams <- teams()
    team_name <- input$team_select_remove
    player_to_remove <- input$name_select_remove
    available_captains <- selected_captains()
    
    if (player_to_remove %in% available_captains) {
      showModal(
        modalDialog(
          title = "Error",
          "Error: A captain cannot be removed manually from a team."
          , easyClose = TRUE,
          footer = modalButton("Close")
        )
      )
      return(NULL)
    }
    
    current_teams[[team_name]] <- setdiff(
      current_teams[[team_name]],
      player_to_remove
    )
    
    teams(current_teams)
    
    updated_team_players <- current_teams[[team_name]]
    removable_players <- setdiff(updated_team_players, available_captains)
    
    updateSelectInput(
      session,
      "name_select_remove",
      choices = removable_players
    )
    
    update_captain_warning()
  })
  
  # ------------------ EXPORT ------------------
  
  # Excel export can be added ()just uncomment
  # output$download_excel <- downloadHandler(
  #   filename = function() {
  #     paste0("Team_Distribution_", Sys.Date(), ".xlsx")
  #   },
  #   content = function(file) {
  #     team_data <- teams()
  #     
  #     if (length(team_data) == 0) {
  #       showModal(
  #         modalDialog(
  #           title = "Error",
  #           "No teams available for export.",
  #           easyClose = TRUE,
  #           footer = modalButton("Close")
  #         )
  #       )
  #       return(NULL)
  #     }
  #     
  #     current_captains <- get_current_captains_for_export()
  #     
  #     team_sheets <- lapply(seq_along(team_data), function(i) {
  #       team_members <- team_data[[i]]
  #       captain_i <- current_captains[i]
  #       
  #       export_names <- sapply(team_members, function(name) {
  #         if (nzchar(captain_i) && identical(name, captain_i)) {
  #           paste0(name, " (Captain)")
  #         } else {
  #           name
  #         }
  #       }, USE.NAMES = FALSE)
  #       
  #       data.frame(Name = export_names, stringsAsFactors = FALSE)
  #     })
  #     
  #     names(team_sheets) <- names(team_data)
  #     write_xlsx(team_sheets, path = file)
  #   }
  # )
  
  output$download_pdf <- downloadHandler(
    filename = function() {
      paste0("Team_Distribution_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      team_data <- teams()
      
      if (length(team_data) == 0) {
        showModal(
          modalDialog(
            title = "Error",
            "No teams available for export.",
            easyClose = TRUE,
            footer = modalButton("Close")
          )
        )
        return(NULL)
      }
      
      current_captains <- get_current_captains_for_export()
      
      team_data_export <- lapply(seq_along(team_data), function(i) {
        team_members <- team_data[[i]]
        captain_i <- current_captains[i]
        
        sapply(team_members, function(name) {
          if (nzchar(captain_i) && identical(name, captain_i)) {
            paste0(name, " (Captain)")
          } else {
            name
          }
        }, USE.NAMES = FALSE)
      })
      
      names(team_data_export) <- names(team_data)
      
      max_len <- max(sapply(team_data_export, length))
      team_table <- do.call(cbind, lapply(team_data_export, function(x) {
        c(x, rep("", max_len - length(x)))
      }))
      
      colnames(team_table) <- names(team_data_export)
      df <- as.data.frame(team_table, stringsAsFactors = FALSE)
      
      pdf(file, width = 11.69, height = 8.27)
      grid.newpage()
      grid.text("Team Allocation", y = 0.95, gp = gpar(fontsize = 16, fontface = "bold"))
      grid.text(paste("Created on:", Sys.Date()), y = 0.92, gp = gpar(fontsize = 10))
      
      table_grob <- gridExtra::tableGrob(
        df,
        rows = NULL,
        theme = gridExtra::ttheme_default(
          core = list(fg_params = list(cex = 0.9)),
          colhead = list(fg_params = list(fontface = "bold"))
        )
      )
      
      grid.draw(table_grob)
      dev.off()
    }
  )
}

# Launch the Shiny app
shinyApp(ui = ui, server = server)

