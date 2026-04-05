## ---------------------------
##
## Script name: shinyapp_set_deploy
##
##
## Purpose of script: Set Account and deploy app
##
## Author: Gerrit Stahn
##
## Date Created: 2026-04-04
## Last Update: 2025-04-04
##
## Copyright (c) Gerrit Stahn, 2026
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
# consult: https://docs.posit.co/shinyapps.io/guide/getting_started/
setAccountInfo(name='YOUR NAME',
                          token='YOUR TOKEN',
                          secret='YOUR SECRET')

# Deploys the app
deployApp(appDir= "YOUR LOCAL PATH", appName = "APP_NAME", appTitle = "APP TITLE")

# Uncomment and execute if you want to terminate the app
# terminateApp("APP_NAME")
## -----------------------------------------------------------------------------