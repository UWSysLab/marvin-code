# I referred to this StackOverflow answer to figure out how to rotate the
# x-axis labels: https://stackoverflow.com/a/1331400.

library(ggplot2)

myData = read.csv("commercial-app-startup-times.csv", header = TRUE)

pdf("commercial-app-startup-times.pdf")
ggplot(myData) +
    geom_col(mapping = aes(x = Name, y = Time, fill = System), position = "dodge") +
    xlab("App") +
    ylab("Average startup time (s)") +
    labs(fill = "") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    coord_fixed(0.5)
dev.off()
