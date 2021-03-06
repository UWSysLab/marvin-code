#!/usr/bin/Rscript

# This script expects as input a single file produced by
# process-parsed-microbenchmark-logs.pl.

# I used these links to learn how to remove the grid and background color:
#
# http://felixfan.github.io/ggplot2-remove-grid-background-margin/
# https://stackoverflow.com/q/10861773
#
# The six-color palette is a modified version of the colorblind-friendly
# palette from here:
# http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-live-apps.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

threeColorPalette = c("#ff9999", "#33aa33", "#0000aa")
cbbPalette = c("#000000", "#E69F00", "#009E73", "#0072B2", "#D55E00", "#CC79A7")

pdf(outputFile)
ggplot(myData) +
    geom_line(mapping = aes(x = Time, y = NumLiveApps, color = Label), size = 1) +
    xlab("Time (s)") +
    ylab("Num active apps") +
    labs(color = "", linetype = "") +
    theme_classic() +
    theme(axis.text = element_text(size=16), axis.title=element_text(size=16), legend.text = element_text(size=16)) +
    scale_color_manual(values = cbbPalette) +
    coord_fixed(600)
dev.off()
