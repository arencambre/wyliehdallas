if (!require('knitr')) {install.packages("knitr")}
if (!require('devtools')) {install.packages("devtools")}
if (!require('RWordPress')) {devtools::install_github(c("duncantl/XMLRPC", "duncantl/RWordPress"))}

library(knitr)
library(RWordPress)

options(WordpressLogin = c(`Aren Cambre` = 'tQ3djsKK'),
        WordpressURL = 'https://arencambre.com/xmlrpc.php')

knit2wp('index.RmD',
        title = 'Who is Wylie H. Dallas?',
        publish = FALSE,
        action = "newPost")
