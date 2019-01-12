#!/usr/bin/Rscript

# This script expects as input a CSV file with the following column names:
# Average, StdDev, Benchmark, System

# I used these links to figure out how to use tapply() to calculate statistics
# over the subsets of variables that share the same factor levels:
#
# https://stackoverflow.com/a/23395844
# https://stackoverflow.com/a/10220561
#
# I used this link to figure out how to add error bars:
#
# https://ggplot2.tidyverse.org/reference/position_dodge.html

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-pcmark-data.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

pdf(outputFile)
ggplot(myData, aes(x = Benchmark, group = System)) +
    geom_col(aes(y = Average, fill = System), position = "dodge") +
    geom_errorbar(aes(ymin = Average - StdDev, ymax = Average + StdDev), width = 0.4, position = position_dodge(width = 0.9)) +
    xlab("Benchmark") +
    ylab("Score") +
    labs(fill = "") +
    theme_classic() +
    theme(axis.text = element_text(size=16), axis.title = element_text(size=20), legend.text = element_text(size=20)) +
    coord_fixed(0.0004)
dev.off()
