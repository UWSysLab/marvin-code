#!/usr/bin/Rscript

# This script expects as input a single file produced by
# process-memory-data.pl.
#
# I used this StackOverflow answer to learn how to remove the legend title from
# a graph: https://stackoverflow.com/a/14771584.

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-android-allocation-data.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

pdf(outputFile)
ggplot(myData) +
    geom_line(mapping = aes(x = TranslatedTimestamp, y = TranslatedRSSMB, color = WorkingSet, linetype = WorkingSet), size = 1) +
    xlab("Time (ms)") +
    ylab("Memory allocated (MB)") +
    theme_classic() +
    theme(axis.text = element_text(size=16), axis.title = element_text(size=16), legend.text = element_text(size=16), legend.title = element_blank()) +
    theme(legend.position = c(0.7,0.3)) +
    coord_fixed(6)
dev.off()
