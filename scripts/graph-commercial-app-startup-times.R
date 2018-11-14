library(ggplot2)

myData = read.csv("commercial-app-startup-times.csv", header = TRUE)

pdf("commercial-app-startup-times.pdf")
ggplot(myData) +
    geom_col(mapping = aes(x = Name, y = Time, fill = System), position = "dodge") +
    xlab("App") +
    ylab("Average startup time (s)")
dev.off()
