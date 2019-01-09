#!/usr/bin/Rscript

# This script expects as input a single file produced by
# process-object-size-heap-frac-data.pl containing per-app heap fraction vs
# object size "CDFs."

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
    geom_point(mapping = aes(x = Size, y = HeapFrac, color = AppName)) +
    xlab("Object size (bytes, log scale)") +
    ylab("Fraction of heap made up of objects of that size or smaller") +
    scale_x_continuous(trans='log10') +
    coord_fixed(ratio=4.5)
dev.off()