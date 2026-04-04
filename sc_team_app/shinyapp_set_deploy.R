## ---------------------------
##
## Script name: shinyapp_set_deploy
##
## Purpose of script: Set Account and deploy app
##
## Author: Gerrit Stahn
##
## Date Created: 2025-05-07
## Last Update: 2025-10-09
##
## Copyright (c) Gerrit Stahn, 2025
## Email: gerrit.stahn@wiwi.uni-halle.de
##

## -----------------------------------------------------------------------------
## Start
## -----------------------------------------------------------------------------

### Install packages (uncomment as required) ###
# install.packages('rsconnect')

### Load add-on packages ### 
library(rsconnect)    # For hosting via shinyapps.io
library(shiny)

# ------------------ Set Account Info  And Deploy ---------------------
setAccountInfo(name='gstahn',
                          token='DB1DFDB75D35637DD11DEB8AB2EB7DC6',
                          secret='P5qKk2Hb5ns1ESCAurQaHPTbeCLPK8Zm9LiOah/A')

# Test app #
# runApp("R_file_V3.R")

# Version 0.2.0
deployApp(appDir= "/Users/apxww/Library/Mobile Documents/com~apple~CloudDocs/GitHub/Shiny_random_teams/V0_2_0_shinyapp_io", appName = "SC261_Teams", appTitle = "SC261 Teams")

terminateApp("SC261_Teams")
## -----------------------------------------------------------------------------