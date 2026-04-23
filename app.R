## ---------------------------
##
## Script name: app.R
##
## Purpose of script: Create a shiny app, which creates teams by randomly drawing
##                    players from a (pre)specified list.
##
## Version: 0.4.0
##
## Author: Gerrit Stahn
##
## Date Created: 2026-04-22
## Last Update: 2026-04-23
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

# Install necessary packages if not already installed
# install.packages(c(
#   "shiny", "writexl", "gridExtra", "shinymanager",
#   "googlesheets4", "googledrive", "dplyr", "bslib", "bsicons"
# ))

library(shiny)
# library(writexl)
library(gridExtra)
library(grid)
library(shinymanager)
# library(googledrive)
# library(googlesheets4)
library(dplyr)
library(bslib)

# ------------------ DUMMY PLAYER LIST ------------------

# Temporary local player list used for development/testing.
# Replace this with an external data source if needed later.
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

# FOLDER_URL <- "https://drive.google.com/drive/folders/[YOUR_FOLDER_ID]"
# SHEET_NAME <- "player_list_team_app"
# WORKSHEET_NAME <- "Players"

# Store OAuth cache locally
# options(gargle_oauth_cache = ".secrets")

# Browser login on first start
# gs4_auth(path = "[YOUR_JSON_FILE].json")
# drive_auth(path = "[YOUR_JSON_FILE].json")

# Helper function: find spreadsheet in target folder or create a new one
# get_or_create_player_sheet <- function(folder_url, sheet_name, worksheet_name = "Players") {
#   
#   folder_id <- as_id(folder_url)
#   
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
#   new_file <- drive_create(
#     name = sheet_name,
#     path = folder_id,
#     type = "spreadsheet"
#   )
#   
#   ss <- as_sheets_id(new_file$id[[1]])
#   existing_tabs <- sheet_names(ss)
#   
#   if (length(existing_tabs) > 0) {
#     if (existing_tabs[1] != worksheet_name) {
#       sheet_rename(ss, sheet = existing_tabs[1], new_name = worksheet_name)
#     }
#   } else {
#     sheet_add(ss, sheet = worksheet_name)
#   }
#   
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

# Helper function: write player list back to Google Sheet
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

# Load player list initially from spreadsheet
# player_list <- read_players_from_sheet(
#   ss = player_sheet,
#   worksheet_name = WORKSHEET_NAME
# )

# Compatibility helper while Google Sheets is disabled
write_players_to_sheet <- function(players, ss = NULL, worksheet_name = NULL) {
  invisible(NULL)
}

player_sheet <- NULL
WORKSHEET_NAME <- NULL

# ------------------ PASSWORD PROTECTION ------------------

### Restrict inactivity ###
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
t = setTimeout(logout, 600000);
}
}
idleTimer();"

# data.frame with credentials info
credentials <- data.frame(
  user = c("admin", "guest"),
  password = c("change_me_1", "change_me_2"),
  stringsAsFactors = FALSE
)

# ------------------ UI DEFINITION ------------------

css <- "
html, body {
  width: 100%;
  overflow-x: hidden;
}

.app-title {
  margin-bottom: 20px;
}

.well,
.sidebar,
aside,
.col-sm-4 {
  background: transparent !important;
  border: none !important;
  box-shadow: none !important;
}

.well {
  padding: 0 !important;
  margin-bottom: 0 !important;
}

.sidebar-panel-custom {
  padding-right: 8px;
}

.sidebar-section {
  margin-bottom: 20px;
  background: #FFFFFF;
  border: 1px solid #E3E7EB;
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.05);
}

.section-header {
  background: #F5F8FB;
  border-bottom: 1px solid #E3E7EB;
  padding: 12px 16px;
  font-weight: 700;
  color: #205585;
  font-size: 1rem;
}

.section-body {
  padding: 16px;
}

.section-divider {
  height: 1px;
  background: #E9ECEF;
  margin: 14px 0;
  border: none;
}

.team-card {
  background: #FFFFFF;
  border: 1px solid #E3E7EB;
  border-top: 4px solid #205585;
  border-radius: 16px;
  padding: 18px;
  margin-bottom: 18px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
}

.warning-box {
  margin-top: 16px;
  padding: 12px 14px;
  border-left: 4px solid #E1BD4E;
  background: #FFF8E1;
  border-radius: 10px;
}

.export-section {
  margin-bottom: 20px;
  background: #FFFFFF;
  border: 1px solid #E3E7EB;
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.05);
}

.export-buttons {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.center-button-wrap {
  text-align: center;
  margin-top: 12px;
  margin-bottom: 6px;
}

.center-button-wrap .btn {
  min-width: 220px;
}

.main-panel-custom {
  min-height: 100%;
}

.app-footer {
  margin-top: 40px;
  text-align: center;
  font-size: 0.75rem;
  color: #666;
}

@media (max-width: 768px) {
  .container-fluid {
    padding-left: 10px;
    padding-right: 10px;
  }

  .section-body {
    padding: 14px;
  }

  .btn {
    width: 100%;
    margin-bottom: 8px;
  }

  .export-buttons {
    display: block;
  }
}

.modal-content {
  border-radius: 16px;
  border: none;
}

.modal-header {
  border-bottom: 1px solid #E3E7EB;
}

.modal-footer {
  border-top: 1px solid #E3EEB;
}

/* ---------- Login Help Overlay ---------- */
.login-help-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  z-index: 99999;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.login-help-modal {
  width: 100%;
  max-width: 850px;
  max-height: 85vh;
  background: #FFFFFF;
  border-radius: 16px;
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.20);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.login-help-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  border-bottom: 1px solid #E3E7EB;
  background: #FFFFFF;
}

.login-help-close {
  border: none;
  background: transparent;
  font-size: 1.8rem;
  line-height: 1;
  color: #205585;
  cursor: pointer;
}

.login-help-body {
  padding: 18px 20px;
  overflow-y: auto;
  background: #FAFBFC;
}

.login-help-footer {
  padding: 14px 20px;
  border-top: 1px solid #E3E7EB;
  background: #FFFFFF;
  text-align: right;
}

.help-intro-box {
  background: #F5F8FB;
  border: 1px solid #E3E7EB;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 20px;
}

.help-section {
  margin-bottom: 18px;
}

.help-section-title {
  font-weight: 700;
  color: #205585;
  margin-bottom: 8px;
  font-size: 1rem;
}

.help-section-body {
  background: #FFFFFF;
  border: 1px solid #E3E7EB;
  border-radius: 12px;
  padding: 14px 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.help-section-body ul {
  margin-bottom: 0;
  padding-left: 20px;
}

.help-section-body p {
  margin-bottom: 0;
}

@media (max-width: 768px) {
  .login-help-modal {
    max-height: 90vh;
  }
  
  .login-help-header,
  .login-help-body,
  .login-help-footer {
    padding-left: 14px;
    padding-right: 14px;
  }
}

.login-help-body {
  text-align: left !important;
}

.help-section-body {
  text-align: left !important;
}

.help-intro-box {
  text-align: left !important;
}

.login-top-content {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}
"

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

# ------------------ APP UI CORE ------------------

# ------------------ SHARED HELP CONTENT ------------------

help_section_ui <- function(title, icon, items) {
  div(
    class = "help-section",
    div(class = "help-section-title", paste0(icon, " ", title)),
    div(
      class = "help-section-body",
      tags$ul(
        lapply(items, tags$li)
      )
    )
  )
}

help_intro_ui <- function() {
  div(
    class = "help-intro-box",
    tags$h4(style = "margin-top:0; color:#205585;", "🎯 Purpose of the app"),
    tags$p(
      style = "margin-bottom:0;",
      "This app supports the quick creation of random teams. ",
      "Players can be selected and managed, captains can be defined, ",
      "teams can be generated automatically, adjusted manually if needed, ",
      "and then exported."
    )
  )
}

help_content_ui <- function(include_feedback = FALSE) {
  tagList(
    help_intro_ui(),
    
    help_section_ui(
      "Security & notes",
      "🔐",
      list(
        "The app is password protected and only accessible to authorized users.",
        "After inactivity, an automatic logout is triggered to prevent unauthorized access.",
        "The player list currently uses a local dummy list for testing and demonstration purposes.",
        HTML('If you have any questions or issues, please send an email to <a href="mailto:contact@example.com" target="_blank">contact@example.com</a>.')
      )
    ),
    
    help_section_ui(
      "Select players for team creation",
      "👥",
      list(
        "Use the overview to mark present players for the current team creation.",
        "Additionally, the captain role can be activated for individual people.",
        "Captains are automatically treated as selected and do not need to be marked separately as present.",
        "The bulk action can be used to select or deselect all available players at once."
      )
    ),
    
    help_section_ui(
      "Manage player list",
      "➕",
      list(
        "New names can be added permanently to the central player list.",
        "Names that are no longer needed can be removed from the list.",
        "People currently set as captains cannot be deleted in order to protect the team logic."
      )
    ),
    
    help_section_ui(
      "Create random teams",
      "🎲",
      list(
        "Before creating teams, define the desired number of teams.",
        "The number of teams must exactly match the number of selected captains.",
        "When generating teams, the selected players are randomly distributed across the teams.",
        "The captains are assigned automatically and placed in the first position of each team."
      )
    ),
    
    help_section_ui(
      "Display and check teams",
      "📋",
      list(
        "After creation, all teams are displayed clearly together with team size.",
        "For each team, the captain selection can be checked or adjusted via a dropdown.",
        "If captains are not uniquely distributed across the teams, a warning message appears."
      )
    ),
    
    help_section_ui(
      "Edit teams manually",
      "✏️",
      list(
        "Additional names can be added manually to an existing team.",
        "Unneeded team members can be removed again from a team.",
        "Captains cannot be removed manually so that the team structure remains intact.",
        "Duplicate assignments are prevented, so one person cannot appear in multiple teams at the same time."
      )
    ),
    
    help_section_ui(
      "Export results",
      "📤",
      list(
        # "The final team distribution can be exported as an Excel file.",
        "A PDF export is available for easy sharing or printing.",
        "Captains are clearly marked in the export."
      )
    ),
    
    if (include_feedback) {
      help_section_ui(
        "Feedback",
        "⚠️",
        list(
          HTML(
            paste0(
              '<a href="mailto:kixxntrixx@web.de',
              '?subject=How much is the fish?',
              '&body=Hello,%0D%0A%0D%0A',
              'I want to donate 1000EUR to you. What is your IBAN?%0D%0A%0D%0A">',
              'Send feedback',
              '</a>'
            )
          )
        )
      )
    }
  )
}

app_ui <- fluidPage(
  theme = theme_custom,
  
  tags$head(
    tags$style(HTML(css)),
    tags$script(HTML(inactivity)),
    tags$script(HTML("
  Shiny.addCustomMessageHandler('scrollToTeams', function(message) {
    var el = document.getElementById('teams_section');
    if (el) {
      el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });
"))
  ),
  
  div(
    style = "max-width: 1100px; margin: 0 auto;",
    
    div(
      class = "app-title",
      
      fluidRow(
        column(
          width = 8,
          h1("Team App", style = "color:#205585; font-weight:700; margin-bottom:6px;"),
          p(
            style = "color:#5F6B7A; margin-bottom:0;",
            "Manage players, define captains, and create random teams."
          )
        ),
        
        column(
          width = 4,
          align = "right",
          div(
            style = "margin-top:10px;",
            actionButton(
              "show_help",
              label = "Help",
              icon = icon("circle-info"),
              class = "btn btn-primary btn-sm"
            )
          )
        )
      )
    ),
    
    # 1) Player list for team creation
    div(
      class = "sidebar-section",
      div(class = "section-header", "👥 Player list"),
      div(
        class = "section-body",
        uiOutput("selection_h4"),
        uiOutput("select_all_button"),
        div(style = "margin-top:15px;"),
        uiOutput("player_selection_ui")
      )
    ),
    
    # 2) Manage player list
    div(
      class = "sidebar-section",
      div(class = "section-header", "➕ Manage player list"),
      div(
        class = "section-body",
        textInput("new_player", "Enter new name:", placeholder = "e.g. Alex Example"),
        actionButton("add_player", "Add player permanently", class = "btn btn-primary"),
        
        div(class = "section-divider"),
        
        selectInput("remove_player", "Select player:", choices = NULL),
        actionButton("delete_player", "Remove player permanently", class = "btn btn-outline-danger")
      )
    ),
    
    # 3) Random teams
    div(
      class = "sidebar-section",
      style = "
        background: linear-gradient(135deg, #205585 0%, #163B5C 100%);
        border: none;
        box-shadow: 0 8px 20px rgba(32, 85, 133, 0.18);
      ",
      div(
        class = "section-header",
        style = "
          background: transparent;
          border-bottom: 1px solid rgba(255,255,255,0.15);
          color: #FFFFFF;
        ",
        "🎲 Random teams"
      ),
      div(
        class = "section-body",
        style = "color:#FFFFFF;",
        
        numericInput(
          "num_teams",
          "Number of teams:",
          value = 3,
          min = 1,
          step = 1,
          width = "100%"
        ),
        
        tags$p(
          style = "font-size:0.9rem; color:rgba(255,255,255,0.85); margin-top:10px;",
          "The number of teams must match the number of selected captains."
        ),
        
        actionButton(
          "randomize",
          "Generate teams",
          class = "btn btn-warning",
          style = "font-weight:700; width:100%; margin-top:8px;"
        )
      )
    ),
    
    # Additional content appears only after first team creation
    uiOutput("main_content_ui")
  )
)

# ------------------ SECURE APP WRAPPER ------------------

ui <- secure_app(
  app_ui,
  theme = theme_custom,
  tags_top = tags$div(
    class = "login-top-content",
    
    tags$head(
      tags$style(css)
    ),
    
    tags$img(
      src = "https://www.sc261.de/images/layout/SC261.svg",
      width = 200,
      height = 200,
      alt = "Logo not found"
    ),
    
    div(
      style = "margin-top:12px;",
      tags$button(
        type = "button",
        class = "btn btn-outline-primary btn-sm",
        onclick = "document.getElementById('loginHelpOverlay').style.display='flex';",
        "Help"
      )
    ),
    
    div(
      id = "loginHelpOverlay",
      class = "login-help-overlay",
      style = "display:none;",
      
      div(
        class = "login-help-modal",
        
        div(
          class = "login-help-header",
          tags$div(
            style = "font-weight:700; color:#205585; font-size:1.2rem;",
            "Help for the Team App"
          ),
          tags$button(
            type = "button",
            class = "login-help-close",
            onclick = "document.getElementById('loginHelpOverlay').style.display='none';",
            HTML("&times;")
          )
        ),
        
        div(
          class = "login-help-body",
          help_content_ui(include_feedback = FALSE)
        ),
        
        div(
          class = "login-help-footer",
          tags$button(
            type = "button",
            class = "btn btn-secondary btn-sm",
            onclick = "document.getElementById('loginHelpOverlay').style.display='none';",
            "Close"
          )
        )
      )
    )
  )
)

# ------------------ SERVER LOGIC ------------------

server <- function(input, output, session) {
  
  result_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )
  
  players <- reactiveVal(sort(player_list))
  teams <- reactiveVal(list())
  captains_selected <- reactiveVal(character(0))
  captain_warning <- reactiveVal(NULL)
  
  show_help_modal <- function() {
    modalDialog(
      title = div(style = "font-weight:700; color:#205585;", "Help for the Team App"),
      size = "l",
      easyClose = TRUE,
      footer = modalButton("Close"),
      
      tags$div(
        style = "max-height:70vh; overflow-y:auto;",
        div(
          style = "padding: 4px 2px;",
          help_content_ui(include_feedback = TRUE)
        )
      )
    )
  }
  
  observeEvent(input$show_help, {
    showModal(show_help_modal())
  })
  
  selected_players_state <- reactiveVal(setNames(rep(FALSE, length(player_list)), player_list))
  captain_state <- reactiveVal(setNames(rep(FALSE, length(player_list)), player_list))
  
  # Helper function: align selection states with current player list
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
    
    new_selected[new_captains] <- FALSE
    
    selected_players_state(new_selected)
    captain_state(new_captains)
  }
  
  # Check warning status
  update_captain_warning <- function() {
    if (length(teams()) == 0) {
      captain_warning(NULL)
      return()
    }
    
    team_data <- teams()
    available_captains <- captains_selected()
    
    selected_dropdown_captains <- sapply(seq_along(team_data), function(i) {
      val <- input[[paste0("captain_team_", i)]]
      if (is.null(val) || identical(val, "")) {
        if (length(team_data[[i]]) > 0) team_data[[i]][1] else ""
      } else {
        val
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
  
  # Rebuild teams internally after manual captain reassignment
  rebuild_teams_with_selected_captains <- function() {
    req(length(teams()) > 0)
    
    current_teams <- teams()
    available_captains <- captains_selected()
    
    if (length(available_captains) == 0) {
      return()
    }
    
    non_captain_members <- lapply(current_teams, function(team_vec) {
      setdiff(team_vec, available_captains)
    })
    
    selected_dropdown_captains <- sapply(seq_along(current_teams), function(i) {
      val <- input[[paste0("captain_team_", i)]]
      if (is.null(val) || identical(val, "")) {
        if (length(current_teams[[i]]) > 0) current_teams[[i]][1] else ""
      } else {
        val
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
  
  get_current_captains_for_export <- function() {
    if (length(teams()) == 0) {
      return(character(0))
    }
    
    sapply(teams(), function(team_vec) {
      if (length(team_vec) > 0) team_vec[1] else ""
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
    
    if (player_to_delete %in% captains_selected()) {
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
  
  # ------------------ LEFT SIDE: TEAM CREATION + CAPTAIN ------------------
  
  output$selection_h4 <- renderUI({
    selected_count <- sum(selected_players_state(), na.rm = TRUE) +
      sum(captain_state(), na.rm = TRUE)
    
    h4(paste0("Selection for team creation (", selected_count, " selected):"))
  })
  
  output$player_selection_ui <- renderUI({
    current_players <- players()
    selected_state <- selected_players_state()
    captain_vals <- captain_state()
    
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
            if (!isTRUE(captain_vals[player])) {
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
              value = isTRUE(captain_vals[player])
            )
          )
        )
      })
    )
  })
  
  observe({
    lapply(players(), function(player) {
      local({
        p <- player
        safe_name <- make.names(p)
        
        observeEvent(input[[paste0("captain_player_", safe_name)]], {
          current_captains <- captain_state()
          current_selected <- selected_players_state()
          
          is_captain_now <- isTRUE(input[[paste0("captain_player_", safe_name)]])
          current_captains[p] <- is_captain_now
          
          if (is_captain_now) {
            current_selected[p] <- TRUE
          }
          
          captain_state(current_captains)
          selected_players_state(current_selected)
        }, ignoreInit = TRUE)
        
        observeEvent(input[[paste0("select_player_", safe_name)]], {
          current_selected <- selected_players_state()
          
          if (!isTRUE(captain_state()[p])) {
            current_selected[p] <- isTRUE(input[[paste0("select_player_", safe_name)]])
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
      "Set all to present"
    }
    
    div(
      class = "center-button-wrap",
      actionButton("select_all_present", label)
    )
  })
  
  output$main_content_ui <- renderUI({
    req(length(teams()) > 0)
    
    tagList(
      # Teams
      div(
        id = "teams_section",
        class = "sidebar-section",
        div(class = "section-header", "📋 Teams"),
        div(
          class = "section-body",
          uiOutput("team_ui"),
          uiOutput("captain_warning_ui")
        )
      ),
      
      # Edit teams
      div(
        class = "sidebar-section",
        div(class = "section-header", "✏️ Edit teams"),
        div(
          class = "section-body",
          uiOutput("modify_teams_ui")
        )
      ),
      
      # Export
      div(
        class = "export-section",
        div(class = "section-header", "📤 Export"),
        div(
          class = "section-body",
          uiOutput("download_ui")
        )
      ),
      
      div(
        class = "app-footer",
        HTML("&copy; Team App")
      )
    )
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
        updateCheckboxInput(session,
                            paste0("captain_player_", make.names(player)),
                            value = FALSE)
        
        updateCheckboxInput(session,
                            paste0("select_player_", make.names(player)),
                            value = FALSE)
      })
      
    } else {
      
      new_selected <- setNames(rep(TRUE, length(current_players)), current_players)
      new_selected[current_captains] <- FALSE
      
      selected_players_state(new_selected)
      
      lapply(current_players, function(player) {
        if (!isTRUE(current_captains[player])) {
          updateCheckboxInput(session,
                              paste0("select_player_", make.names(player)),
                              value = TRUE)
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
      class = "export-buttons",
      # downloadButton("download_excel", "Download Excel"),
      downloadButton("download_pdf", "Download PDF")
    )
  })
  
  # ------------------ RANDOMIZATION ------------------
  
  observeEvent(input$randomize, {
    selected_state <- selected_players_state()
    captain_vals <- captain_state()
    
    random_players <- names(selected_state[selected_state])
    captains <- names(captain_vals[captain_vals])
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
      split_teams <- split(shuffled_names, rep(1:num_teams, length.out = length(shuffled_names)))
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
    
    for (i in seq_len(num_teams)) {
      full_teams[[i]] <- c(captains[i], full_teams[[i]])
    }
    
    team_list <- setNames(full_teams, paste0("Team ", seq_len(num_teams)))
    teams(team_list)
    captains_selected(captains)
    captain_warning(NULL)
    session$sendCustomMessage("scrollToTeams", list())
  }
  )
  
  # ------------------ TEAM OUTPUT ------------------
  
  output$team_ui <- renderUI({
    req(length(teams()) > 0)
    team_data <- teams()
    available_captains <- captains_selected()
    
    fluidRow(
      lapply(seq_along(team_data), function(i) {
        team <- names(team_data)[i]
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
        
        div(
          class = "col-12 col-md-6 col-lg-4",
          div(
            class = "team-card",
            
            h4(
              paste0(
                team, " – ",
                length(team_data[[team]]), " ",
                ifelse(length(team_data[[team]]) == 1, "person", "people")
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
  
  # Dropdown change should update teams internally
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
    available_captains <- captains_selected()
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
    available_captains <- captains_selected()
    
    if (player_to_remove %in% available_captains) {
      showModal(
        modalDialog(
          title = "Error",
          "Error: A captain cannot be removed manually from the team.",
          easyClose = TRUE,
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
