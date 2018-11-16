# I referred to this StackOverflow answer to figure out how to rotate the
# x-axis labels: https://stackoverflow.com/a/1331400.
#
# I referred to this page to learn how to order the columns in a column chart:
# https://rstudio-pubs-static.s3.amazonaws.com/7433_4537ea5073dc4162950abb715f513469.html.

library(ggplot2)

myData = read.csv("section-2-graph-data.csv", header = TRUE)

# Make the column chart order the columns in order of decreasing startup time.
myData$Name = factor(myData$Name, levels = myData$Name[order(myData$Time, decreasing = TRUE)])

pdf("section-2-graph.pdf")
ggplot(myData) +
    geom_col(mapping = aes(x = Name, y = Time, fill = System)) +
    xlab("App") +
    ylab("Average startup time (s)") +
    labs(fill = "") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    coord_fixed(0.5)
dev.off()
