# time of day
tweets %>%
  filter(screen_name == "Wylie_H_Dallas") %>%
  ggplot(aes(x = hour)) +
  geom_histogram(bins = 24 * 6) +
  scale_x_continuous(breaks = seq(0, 24, 4)) +
  xlab("hour of day") +
  ylab("count of tweets") +
  ggtitle(paste(advocamentum_news_media[advocamentum_news_media$screen_name == i,]$name, "'s tweet time histogram", sep = ""))

# date
tweets %>%
  filter(screen_name == "JimSchutze") %>%
  ggplot(aes(x = created_at)) +
  geom_histogram() +
  xlab("date") +
  ylab("count of tweets") +
  ggtitle(paste(advocamentum_news_media[advocamentum_news_media$screen_name == i,]$name, "'s tweet time histogram", sep = ""))
