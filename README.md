# Team Assignment App

This R Shiny app allows users to manage a player list, define captains, and randomly generate teams in a modern, password-protected interface. Teams can be adjusted manually after creation and exported as a PDF. The current local development version uses a predefined player list, while optional cloud storage via Google Sheets / Google Drive is prepared in the code.

## Features

- Password-protected access using `shinymanager`
- Modern responsive UI based on **Bootstrap 5** via `bslib`
- Custom theme with improved styling, cards, section layouts, and mobile-friendly behavior
- Help system:
  - help button on the login screen
  - help button inside the app
  - structured in-app guidance for all major functions
- Add and remove players from the player list
- Select players as **present**
- Define specific players as **captains**
- Bulk action to **set all players as present** or **deselect all**
- Random assignment of selected players to a configurable number of teams
- Validation that the **number of captains matches the number of teams**
- Automatic placement of captains at the **top of each team**
- Manual captain reassignment via dropdown after team creation
- Automatic validation and warning if captains are not assigned uniquely across teams
- Manual editing of teams:
  - add members to existing teams
  - remove non-captain members from teams
- Safeguards preventing:
  - duplicate team assignments
  - manual removal of captains from teams
  - deletion of active captains from the player list
- Automatic scroll to the team section after generating teams
- PDF export with captains clearly marked as `(Captain)`
- Optional, documented Google Sheets / Google Drive integration for persistent shared storage
- Compatibility fallback so the app still runs when external storage is disabled

## Use Cases

This app can be helpful for a wide range of scenarios, including:

- **Conducting experiments**: Randomly distribute participants into treatment and control groups
- **University seminars or group work**: Divide students into teams for projects or discussion groups
- **Workshops and trainings**: Assign participants to breakout groups
- **Sports and hobby groups**: Randomize players for weekly games or tournaments
- **Hackathons and ideation events**: Create balanced random teams quickly
- **Language or debate clubs**: Organize rotating teams for practice rounds
- **Game nights or board game events**: Shuffle groups for casual or competitive play

## Requirements

- R (>= 4.0)

### Core packages for the current app version

- `shiny`
- `shinymanager`
- `gridExtra`
- `grid`
- `dplyr`
- `bslib`

### Optional packages

For Google Drive / Google Sheets integration:

- `googlesheets4`
- `googledrive`

For Excel export (currently still in the code, but commented out):

- `writexl`

For deployment setup scripts:

- `rsconnect`

Example deployment can be done via [shinyapps.io](https://docs.posit.co/shinyapps.io/guide/)

The example app can be assessed via [https://gstahn.shinyapps.io/Teams_randomizer/](https://gstahn.shinyapps.io/Teams_randomizer/). Use **admin** as the User and **change_me_1** as the password.

## Latest Update

### Version 0.4.0 – 2026-04-23

#### Added

- Fully redesigned UI with a cleaner card-based layout
- Responsive styling improvements for desktop and mobile devices
- New help system with:
  - login-screen help overlay
  - in-app help modal
  - structured usage instructions
- New app header with title, subtitle, and help button
- Automatic scroll-to-teams behavior after team generation
- Dedicated content sections for:
  - player list
  - player management
  - random team generation
  - team display
  - team editing
  - export
- Improved login area with logo placeholder and help access
- Footer shown after team generation

#### Improved captain workflow

- Clear distinction between **present players** and **captains**
- Captains are automatically treated as selected for team creation
- Captains are inserted as the first member of each team
- Captains can be reassigned after randomization through dropdown menus
- Automatic validation checks whether captains remain uniquely assigned across teams
- Warning message displayed if captain assignment becomes inconsistent

#### Improved team workflow

- Teams are shown only after they have been created
- Team display is now organized in styled team cards
- Team cards show both team name and current team size
- Team editing remains possible after generation
- Manual edits automatically preserve captain logic

#### Improved security and usability

- Password protection remains active through `shinymanager`
- Credentials updated to placeholder admin/guest accounts for safer template usage
- Inactivity logout timing adjusted in the JavaScript timer logic
- Better modal styling for error and help dialogs

#### Export

- PDF export remains active
- Captains are explicitly labeled as `(Captain)` in the export
- Export section is shown only when teams are available
- Excel export is still included in the source code, but remains commented out

#### Storage

- Current version continues to use a **local predefined player list** for development/testing
- Google Sheets / Google Drive integration remains prepared in the source code
- Compatibility helper functions ensure the app runs without active cloud storage

#### Changed

- App structure was reorganized into a more guided single-page flow
- Labels and button texts were refined for clarity
- Default number of teams changed to `3`
- Team section is now visually highlighted after generation
- UI elements are more consistent in wording and appearance

#### Internal

- Server logic cleaned up and reorganized
- Help content modularized into reusable UI helper functions
- Improved separation between:
  - shared help content
  - main app UI
  - secure login wrapper
- Custom JavaScript added for smooth scrolling to the teams section

---

## Previous Updates

### Version 0.3.0

- Modernized UI using **Bootstrap 5 (`bslib`)** with a custom theme
- Captain selection system for team creation
- Separate player states for **Present** and **Captain**
- Dynamic **Select all / Deselect all** functionality
- Captain reassignment via dropdown menus after team creation
- Automatic team rebuilding when captain assignments change
- Warning system for invalid captain assignments
- Improved PDF export including captain labeling
- Compatibility fallback functions for disabled external storage
- Extensive inline documentation for storage and deployment options

### Version 0.2.0

- Added password protection
- Prevented deselecting others when someone new joins
- Displayed number of selected names
- Improved handling on smartphones
- Added option to save results as a PDF

## Notes on Storage

The current app version uses a hardcoded player list for local testing and development.

For production or multi-user deployment, the code already contains a prepared template for external persistence via:

- Google Sheets
- Google Drive
