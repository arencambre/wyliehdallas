library(tidyverse)
library(tidytext)
library(rvest)
library(drlib)
library(rtweet)
library(httpuv)
# install.packages("devtools")
# library(devtools)
# install_github("dgrtwo/drlib")
library(drlib)
library(widyr)

# token <- create_token(
#   app = "rtweet_token",
#   consumer_key = "7LgQuKz4SLgYGRyrjDE7Wvcrv",
#   consumer_secret = "0IlOj4SEZF4ewjqtvkJQpI2WC5Umb4pRqainUMYFVAggOH32vN",
#   access_token = "355116443-DZN0eHCdJsRKUptWALuGpjTs0RW6lNTtCcUGUVV4",
#   access_secret = "SBI16aiiqFYU94KSHkPVCNUdFyxaUXvJlBOvxKm3CgHht")

# this is my own
token <- create_token(
  app = "Cambre R research",
  consumer_key = "mkWNTQ1fxAUsubsndN5KWgg9Z",
  consumer_secret = "DZNEbDCzcHxdhfrUTUJY2RV3SwhUoUfjqFrzOV0RVlmhCy9JP1",
  access_token = "24486921-AwuNh3AjJcF3ZQRw9Dle0NfCCcHmYj5ZqrGbJazda",
  access_secret = "Oney2PPAHZs0Gi5TirhwvuvKtMzHZcZmBnoYeGAta1g6D")

#token <- create_token(
#  app = "token",
#  consumer_key = "yqoymTNrS9ZDGsBnlFhIuw",
#  consumer_secret = "OMai1whT3sT3XMskI7DZ7xiju5i5rAYJnxSEHaKYvEs")

# list of prominent Dallas media members
# from https://twitter.com/advocamentum/lists/news-media/members
advocamentum_news_media <- lists_members(owner_user = "Advocamentum", slug = "news-media")

# add Wylie to advocamentum's list
advocamentum_news_media <- advocamentum_news_media %>%
  add_row(name = "Wylie H. Dallas",
          screen_name = "Wylie_H_Dallas") %>%
  add_row(name = "Philip Kingston",
          screen_name = "PhilipTKingston")

# Download ~3200 from each account
tweets <- map_df(advocamentum_news_media$screen_name,
                get_timeline,
                n = 3200)

wylie_tweets <- get_timeline("Wylie_H_Dallas", n = 3200)

save(tweets, file="tweets_20190507.Rda")
save(wylie_tweets, file="wylie_tweets_20190507.Rda")

kingston_tweets <- get_timeline("PhilipTKingston", n = 3200)
tweets <- tweets %>%
  bind_rows(kingston_tweets)

load(file = "tweets.Rda")
load(file = "wylie_tweets.Rda")

# merge data frames together
tweets <- bind_rows(tweets, wylie_tweets)

# create plot showing time of day when everyone tweets

# first get the hour
tweets$hour <- as.numeric(strftime(tweets$created_at, format = "%H")) +
  as.numeric(strftime(tweets$created_at, format = "%M")) / 60

tweets %>%
  filter(screen_name %in% c("JimSchutze",
                            "Wylie_H_Dallas",
                            "RobertWilonsky")) %>%
  ggplot(aes(x = hour)) +
  geom_histogram(bins = 24 * 6) +
  facet_grid(~screen_name)

# let's do the above on everyone individually
for (i in unique(tweets$screen_name)) {
  tweets %>%
    filter(screen_name == i |
             screen_name == "Wylie_H_Dallas") %>%
    ggplot(data = .[screen_name == i,], aes(x = hour)) +
    geom_histogram(bins = 24 * 6) +
    xlim(0, 24) +
    xlab("hour of day") +
    ylab("count of tweets") +
    ggtitle(paste(advocamentum_news_media[advocamentum_news_media$screen_name == i,]$name, "'s tweet time histogram", sep = ""))
  ggsave(paste(i, ".png"))
}

i = "PhilipTKingston"
tweets %>%
  filter(screen_name == i) %>%
  ggplot(aes(x = hour)) +
  geom_histogram(bins = 24 * 6) +
  xlim(0, 24) +
  xlab("hour of day") +
  ylab("count of tweets") +
  ggtitle(paste(advocamentum_news_media[advocamentum_news_media$screen_name == i,]$name, "'s tweet time histogram", sep = ""))


tweets %>%
  filter(screen_name == i |
           screen_name == "Wylie_H_Dallas") %>%
  ggplot(data = .[.$screen_name == i,], aes(x = hour)) +
  geom_histogram(bins = 24 * 6) +
  xlim(0, 24) +
  xlab("hour of day") +
  ylab("count of tweets") +
  ggtitle(paste(advocamentum_news_media[advocamentum_news_media$screen_name == i,]$name, "'s tweet time histogram", sep = ""))
ggsave(paste(i, ".png"))

# do word analysis
reg <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"

tweet_words <- tweets %>%
  filter(!is_retweet) %>%
  arrange(created_at) %>%
  distinct(text, .keep_all = TRUE) %>%
  select(screen_name, status_id, text) %>%
  mutate(text = str_replace_all(text, "https?://t.co/[A-Za-z\\d]+|&amp;", "")) %>%
  unnest_tokens(word, text, token = "regex", pattern = reg) %>%
  filter(str_detect(word, "[a-z]")) %>%
  filter(!word %in% stop_words$word)

tweet_words %>%
  filter(!word %in% stop_words$word) %>%
  count(word, sort = TRUE) %>%
  head(16) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  coord_flip() +
  labs(y = "# of uses among staff Twitter accounts")

word_counts <- tweet_words %>%
  count(screen_name, word, sort = TRUE)

# Compute TF-IDF using "word" as term and "screen_name" as document
word_tf_idf <- word_counts %>%
  bind_tf_idf(word, screen_name, n) %>%
  arrange(desc(tf_idf))

similarity <- word_tf_idf %>%
  pairwise_similarity(screen_name, word, tf_idf, upper = FALSE, sort = TRUE) %>%
  filter(item1 == "Wylie_H_Dallas" |
           item2 == "Wylie_H_Dallas")

# get technology data
tweets_datefiltered %>%
  group_by(screen_name, source) %>%
  summarize(count = n()) %>%
  ungroup() %>%
  pairwise_similarity(screen_name, source, count, upper = FALSE, sort = TRUE) %>%
  filter(item1 == "Wylie_H_Dallas" |
           item2 == "Wylie_H_Dallas")

# pairwise similarity by hour
hour_matches <- tweets_datefiltered %>%
  mutate(hour_number = as.numeric(strftime(tweets_datefiltered$created_at, format = "%H"))) %>%
  group_by(screen_name, hour_number) %>%
  summarize(count = n()) %>%
  ungroup() %>%
  pairwise_similarity(screen_name, hour_number, count, upper = FALSE, sort = TRUE) %>%
  filter(item1 == "Wylie_H_Dallas" |
         item2 == "Wylie_H_Dallas")

# pairwise similarity by date
date_matches <- tweets_datefiltered %>%
  mutate(date_string = as.Date(tweets_datefiltered$created_at)) %>%
  group_by(screen_name, date_string) %>%
  summarize(count = n()) %>%
  ungroup() %>%
  pairwise_similarity(screen_name, date_string, count, upper = FALSE, sort = TRUE) %>%
  filter(item1 == "Wylie_H_Dallas" |
           item2 == "Wylie_H_Dallas")

