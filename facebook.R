# based on https://api.rpubs.com/danbooth/facebook_api

library(httr)
library(jsonlite)
library(dplyr)
library(lubridate)

# Define keys
app_id = '451524665391845'
app_secret = '583485cc5c8372a601520369f0a39403'

# Define the app
fb_app <- oauth_app(appname = "facebook",
                    key = app_id,
                    secret = app_secret)

# Get OAuth user access token
fb_token <- oauth2.0_token(oauth_endpoints("facebook"),
                           fb_app,
                           scope = 'public_profile',
                           type = "application/x-www-form-urlencoded",
                           cache = FALSE)

# GET request for your user information
response <- GET("https://graph.facebook.com",
                path = "/681877972",
                config = config(token = fb_token))

# Show content returned
content(response)
