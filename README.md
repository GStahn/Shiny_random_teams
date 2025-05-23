# Team Assignment App

This R Shiny app allows users to create, manage, and randomly assign players to teams with a persistent name list saved locally. It includes features for editing teams manually and exporting the team structure to an Excel file.

## Features

- Add and remove players to/from a persistent list (saved via RDS file)
- Random assignment of selected players to a configurable number of teams
- Drag-and-drop sorting of players within teams using `shinyjqui`
- Manual editing of teams (add/remove members per team)
- Export current teams to an `.xlsx` Excel file using `writexl`
- Responsive UI with live updates

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
- The following R packages:
  - `shiny`
  - `shinyjqui`
  - `writexl`

Install dependencies in R using:

```r
install.packages(c("shiny", "shinyjqui", "writexl"))
