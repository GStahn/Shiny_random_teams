# Team Assignment App

This R Shiny app allows users to create, manage, and randomly assign players to teams with a persistent name list saved externally. It includes features for editing teams manually and exporting the team structure.

## Features

- Add and remove players to/from a persistent list (saved via RDS file)
- Random assignment of selected players to a configurable number of teams
- Drag-and-drop sorting of players within teams using `shinyjqui`
- Manual editing of teams (add/remove members per team)
- Export current teams to an `.xlsx` Excel file using `writexl` (commented out since V 0.3.0) as well as an `.png` file
- Responsive UI with live updates
- Password protection using `shinymanager`

## Use Cases

This app can be helpful for a wide range of scenarios, including:

- **Conducting experiments**: Distribute subjects randomly to either treatment or control groups. (Completely randomized design)
- **University Seminars or Group Work**: Easily divide students into teams for projects or discussion groups.
- **Workshops and Trainings**: Randomly assign participants to breakout groups.
- **Sports and Hobby Groups**: Randomize players for weekly games or tournaments (e.g., soccer, volleyball, chess).
- **Hackathons and Ideation Events**: Ensure balanced, randomized teams for fair collaboration.
- **Language or Debate Clubs**: Organize rotating teams for practice rounds or friendly competitions.
- **Game Nights or Board Game Events**: Shuffle groups for casual or competitive gameplay.


## Requirements

- R (>= 4.0)

- The following R packages for shinyapp_set_deploy.R:
  - `rsconnect`
  - `shiny`
  - `shinymanager`
  - `writexl`
  - `gridExtra`
  - `grid`
  - `dplyr`
  - `bslib`
  
- The following R packages for shinyapp_set_deploy.R:
  - `shiny`
  - `shinymanager`
  - `gridExtra`
  - `grid`
  - `dplyr`
  - `bslib`

Optional packages for cloud storage integration via Google Drive:

  - `googlesheets4`
  - `googledrive`

Optional packages for Excel export: 
  - `writexl`
 
Example app is hosted via [shinyapps.io](https://docs.posit.co/shinyapps.io/guide/)

## Lates Update V 0.3.0
### Version 0.4.0 – 2026-04-05

#### Added
- Modernized UI using **Bootstrap 5 (`bslib`)** with a custom theme.
- Custom styling including colors, typography, spacing, and rounded UI components.
- Logo support on the authentication screen.
- Captain selection system for team creation.
- Separate player states for **Present** and **Captain**.
- Dynamic **Select all / Deselect all** functionality for player availability.
- Captain reassignment via dropdown menus for each team after team creation.
- Automatic team rebuilding when captain assignments change.
- Warning system if captains are not uniquely assigned across teams.
- Team cards displaying team name and number of members.
- Additional validation when editing teams.
- Safeguards preventing:
  - duplicate team assignments,
  - manual removal of captains from teams,
  - deletion of captains from the player list.
- Improved PDF export including captain labeling `(Captain)`.
- Compatibility fallback functions to allow the app to run without external storage.
- Extensive inline documentation regarding storage and deployment options.

#### Changed
- Application language updated from **German to English**.
- UI structure reorganized into clearer sections:
  - player list management
  - player selection
  - team creation
  - team editing
- Team generation rules now require:
  - the number of captains to match the number of teams,
  - at least one captain.
- Captains are automatically placed as the **first member of each team**.
- Error handling improved using **modal dialogs** instead of inline messages.
- Export section appears only when teams exist.
- Export formatting improved for readability.

#### Storage
- Removed default persistence via a local `.rds` file.
- Introduced a temporary **hardcoded player list** for development/testing.
- Added a fully documented template for **Google Sheets / Google Drive integration**.

#### Export
- PDF export improved and remains active.
- Excel export functionality is still present in the code, but commented out.

#### Internal
- Refactored reactive state management for players, captains, and teams.
- Added helper functions for:
  - synchronizing player states,
  - validating captain assignments,
  - rebuilding teams,
  - preparing export data.

---

## Update V 0.2.0
- Adds password protection
- No deselect others when someone new joins
- Displays number of selected names
- Fixes bad handling via smartphones
- Option of saving results as a PDF
