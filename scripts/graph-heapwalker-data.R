#!/usr/bin/Rscript
#
# I referred to this StackOverflow question to learn how to force
# ggplot2 to avoid abbreviating axis labels:
# https://stackoverflow.com/questions/14563989/force-r-to-stop-plotting-abbreviated-axis-labels-e-g-1e00-in-ggplot2.
#
# I referred to this StackOverflow question to learn how to reorder the
# bars in a bar graph:
# https://stackoverflow.com/questions/25664007/reorder-bars-in-geom-bar-ggplot2.

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-heapwalker-data.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

pdf(outputFile)
ggplot(myData, aes(x=reorder(System, -Speed), y=Speed)) +
    geom_col() +
    xlab("") +
    ylab("Throughput (objects touched per second)") +
    theme_classic() +
    theme(axis.text = element_text(size=12), axis.title = element_text(size=16)) +
    scale_y_continuous(labels = scales::comma) +
    coord_fixed(ratio = 0.0000015)
dev.off()
