#!/usr/bin/Rscript

# This script expects as input a single file produced by
# process-memory-data.pl.

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-memory-data.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

pdf(outputFile)
ggplot(myData) +
    geom_line(mapping = aes(x = TranslatedTimestamp, y = TranslatedRSSMB, color = WorkingSet, linetype = WorkingSet), size = 1) +
    xlab("Time (ms)") +
    ylab("RSS (MB, relative to baseline)") +
    labs(color = "Working set", linetype = "Working set") +
    theme_classic() +
    theme(axis.text = element_text(size=16), axis.title = element_text(size=16), legend.text = element_text(size=16), legend.title = element_text(size=16)) +
    coord_fixed(1)
dev.off()
