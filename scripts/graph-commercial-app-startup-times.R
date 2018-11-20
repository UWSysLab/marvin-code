#!/usr/bin/Rscript

# I referred to this StackOverflow answer to figure out how to rotate the
# x-axis labels: https://stackoverflow.com/a/1331400.
#
# I referred to this page to learn how to use command-line arguments in
# Rscript:
# https://www.r-bloggers.com/passing-arguments-to-an-r-script-from-command-lines/.

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-commercial-app-startup-times.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

pdf(outputFile)
ggplot(myData) +
    geom_col(mapping = aes(x = Name, y = Time, fill = System), position = "dodge") +
    xlab("App") +
    ylab("Average startup time (s)") +
    labs(fill = "") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    coord_fixed(0.5)
dev.off()
