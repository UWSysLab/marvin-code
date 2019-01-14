#!/usr/bin/Rscript

# This script expects as input a single file produced by
# process-object-size-heap-frac-data.pl containing per-app heap fraction vs
# object size "CDFs."

# I used this StackOverflow answer to learn how to graph more than six
# different lines with unique point shapes:
# https://stackoverflow.com/a/26224549.

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-object-size-heap-frac-graph.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

pdf(outputFile)
ggplot(myData) +
    geom_line(mapping = aes(x = Size, y = HeapFrac, color = AppName)) +
    geom_point(mapping = aes(x = Size, y = HeapFrac, color = AppName, shape = AppName), size = 2) +
    xlab("Object size (bytes, log scale)") +
    ylab("Cumulative fraction of heap") +
    labs(color = "App", shape = "App") +
    scale_x_continuous(trans='log10') +
    scale_shape_manual(values=1:nlevels(myData$AppName)) +
    theme_classic() +
    theme(axis.text = element_text(size=16), axis.title = element_text(size=16), legend.text = element_text(size=16), legend.title = element_text(size=16)) +
    coord_fixed(ratio=4.5)
dev.off()
