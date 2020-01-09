#!/usr/bin/Rscript

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-compiler-overhead-synthetic-variance.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

# See the Google Doc "Counting DEX instructions in MICROBENCHMARK TWO"
# in the folder "Android Memory Model/Data" for details on how I calculated
# this formula.
#
# This formula is valid for the MicroBenchmarkTwo app as of android-swap-code
# commit 078af71.
myData$totalDEX = 7 + 100000 * (16 + 8 * myData$INT_OP_LOOPS_PER_ITER + 9 * myData$OBJ_OP_LOOPS_PER_ITER)
myData$totalOAI = 100000 * (2 + 4 * myData$OBJ_OP_LOOPS_PER_ITER)
myData$fracOAI = myData$totalOAI / myData$totalDEX

# Add a mocked-up data point at (0, 0)
newData = data.frame(NA, NA, 0, NA, NA, NA, 0)
names(newData) = c("INT_OP_LOOPS_PER_ITER", "OBJ_OP_LOOPS_PER_ITER", "Mean", "Stddev", "totalDEX", "totalOAI", "fracOAI")
myData = rbind(myData, newData)

pdf(outputFile)
ggplot(myData, aes(x = fracOAI, y = Mean)) +
    geom_point(size = 2) +
    geom_line(size = 1) +
    geom_errorbar(aes(ymin = Mean - Stddev, ymax = Mean + Stddev), width = 0.015) +
    xlab("Fraction of DEX instructions with OAI") +
    ylab("Marvin overhead") +
    theme_classic() +
    theme(axis.text = element_text(size=18), axis.title = element_text(size=20)) +
    coord_fixed(0.035)
dev.off()
