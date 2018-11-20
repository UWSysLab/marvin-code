#!/usr/bin/Rscript

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-compiler-overhead-synthetic.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

# See the Google Doc "Counting DEX instructions in WorkerRunnable's run method"
# in the folder "Android Memory Model/Data" for details on how I calculated
# this formula.
#
# This formula is valid for the MicroBenchmark app as of android-swap-code
# commit 226dea0.
ratioNonStubToStub = (32 + 10 * myData$INT_OP_LOOPS_PER_ITER) / 10

overhead = (myData$Marvin_Mean_Time / myData$Stock_Android_Mean_Time)

processedData = data.frame(ratioNonStubToStub, overhead)
pdf(outputFile)
ggplot(processedData, aes(x = ratioNonStubToStub, y = overhead)) +
    geom_point() +
    geom_line() +
    xlab("Ratio of Marvin-augmented DEX instructions to unmodified DEX instructions") +
    ylab("Marvin overhead") +
    coord_fixed(66)
dev.off()
