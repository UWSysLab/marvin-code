#!/usr/bin/Rscript

# I referred to this StackOverflow answer to figure out how to rotate the
# x-axis labels: https://stackoverflow.com/a/1331400.
#
# I referred to this page to learn how to order the columns in a column chart:
# https://rstudio-pubs-static.s3.amazonaws.com/7433_4537ea5073dc4162950abb715f513469.html.
#
# I referred to this page to learn how to use command-line arguments in
# Rscript:
# https://www.r-bloggers.com/passing-arguments-to-an-r-script-from-command-lines/.

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-section-2-graph.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

# Make the column chart order the columns in order of decreasing startup time.
myData$Name = factor(myData$Name, levels = myData$Name[order(myData$Time, decreasing = TRUE)])

pdf(outputFile)
ggplot(myData) +
    geom_col(mapping = aes(x = Name, y = Time, fill = System)) +
    xlab("") +
    ylab("App switch time (s)") +
    labs(fill = "") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="top") +
    coord_fixed(0.5)
dev.off()
