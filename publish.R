if (!require('knitr')) {install.packages("knitr")}
if (!require('devtools')) {install.packages("devtools")}
if (!require('RWordPress')) {devtools::install_github(c("duncantl/XMLRPC", "duncantl/RWordPress"))}

library(knitr)
library(RWordPress)
library(keyring)

#' Before the below commands will work, you need to run both of these from
#' the console to set the username and password:
#' key_set("blog_password")

options(WordpressLogin = c("Aren Cambre" = key_get("blog_password")),
        WordpressURL = 'https://www.arencambre.com/xmlrpc.php')

knit2wp('index.Rmd',
        title = 'Who is Wylie H. Dallas?',
        publish = FALSE,
        action = "editPost",
        postid = 2818)
