#!/usr/bin/Rscript

# This script expects as input a single file produced by
# process-parsed-microbenchmark-logs.pl.

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-live-apps.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

pdf(outputFile)
ggplot(myData) +
    geom_line(mapping = aes(x = Time, y = NumLiveApps, color = Label)) +
    xlab("Time (s)") +
    ylab("Num live apps") +
    coord_fixed(30)
dev.off()
