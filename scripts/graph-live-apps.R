#!/usr/bin/Rscript

# This script expects as input a single file produced by
# process-parsed-microbenchmark-logs.pl.

# I used these links to learn how to remove the grid and background color:
#
# http://felixfan.github.io/ggplot2-remove-grid-background-margin/
# https://stackoverflow.com/q/10861773

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
    geom_line(mapping = aes(x = Time, y = NumLiveApps, linetype = Label, color = Label), size = 1) +
    xlab("Time (s)") +
    ylab("Num live apps") +
    labs(color = "", linetype = "") +
    theme_classic() +
    theme(axis.text = element_text(size=16), axis.title=element_text(size=16), legend.text = element_text(size=16)) +
    coord_fixed(30)
dev.off()
