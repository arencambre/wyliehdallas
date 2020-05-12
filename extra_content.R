**This is where this page gets rough. I am not sure the below plots mean much of anything, plus I need to figure out how not to display all plots in sequence.**
  
  The first interesting pattern is how many tweets Wylie creates at each hour of the day. First, I need to convert the time to a decimal representation. For example, 8:15 AM--one quarter into the 8 AM hour--will be converted to 8.25:
  ```{r}
# first, merge the two filtered datasets of tweets
tweets_filtered <- bind_rows(tweets_20181225_filtered, tweets_20190507_filtered, tweets_20200511_filtered)

tweets_filtered$hour <- as.numeric(strftime(tweets_filtered$created_at, format = "%H")) +
  as.numeric(strftime(tweets_filtered$created_at, format = "%M")) / 60
```
Pretty plots:
  ```{r}
for (i in unique(sort(tweets_filtered$screen_name))) {
  plot <- tweets_filtered %>%
    filter(screen_name == i) %>%
    ggplot(aes(x = hour)) +
    geom_histogram(bins = 24 * 6) +
    scale_x_continuous(breaks = seq(0, 24, 4)) +
    xlab("hour of day") +
    ylab("count of tweets") +
    ggtitle(paste(advocamentum_news_media[advocamentum_news_media$screen_name == i,]$screen_name, "'s tweet time histogram", sep = ""))
  print(plot)
  ggsave(paste0(i, ".png"))
}
```


