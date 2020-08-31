df_test <- tibble(a=rnorm(100), b=rnorm(100), c=rnorm(100), d=rnorm(100))
ggplot(df_test, aes(x=a, y=b))+
  geom_bar(stat="identity", position = "identity", alpha=1) +
  annotate("text", x = 1, y = 1, label = paste(d[3], "Loads"))
