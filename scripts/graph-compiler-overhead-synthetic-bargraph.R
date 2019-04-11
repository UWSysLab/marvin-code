#!/usr/bin/Rscript

# This script is a work-in-progress script that I am using to test out making a
# bar graph version of the "compiler overhead synthetic" graph.

# This script expects as input a CSV file with the following columns:
# INT_OP_LOOPS_PER_ITER,Mean,Stddev,System

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-compiler-overhead-synthetic-bargraph.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

myData$stubFraction = 10 / (42 + 10 * myData$INT_OP_LOOPS_PER_ITER)
myData$stubFractionChar = format(myData$stubFraction, digits = 3)

pdf(outputFile)
ggplot(myData, aes(x = stubFractionChar, group = System)) +
    geom_col(aes(y = Mean, fill = System), position = "dodge") +
    geom_errorbar(aes(ymin = Mean - Stddev, ymax = Mean + Stddev),
                  width = 0.4,
                  position = position_dodge(width = 0.9)) +
    xlab("Fraction of DEX instructions with OAI") +
    ylab("Execution time (ms)") +
    theme_classic()
dev.off()
