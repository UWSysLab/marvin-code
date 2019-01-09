#!/usr/bin/Rscript

# I used these links to figure out how to use tapply() to calculate statistics
# over the subsets of variables that share the same factor levels:
#
# https://stackoverflow.com/a/23395844
# https://stackoverflow.com/a/10220561

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-pcmark-data.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

averageMatrix = with(myData, tapply(Score, list(Benchmark, System), mean))
stdDevMatrix = with(myData, tapply(Score, list(Benchmark, System), sd))

# TODO: is there a cleaner and more automated way to do this?
averageVector = c(averageMatrix["Data Manipulation", "Android"], averageMatrix["Data Manipulation", "Marvin"], averageMatrix["Writing 2.0", "Android"], averageMatrix["Writing 2.0", "Marvin"])
stdDevVector = c(stdDevMatrix["Data Manipulation", "Android"], stdDevMatrix["Data Manipulation", "Marvin"], stdDevMatrix["Writing 2.0", "Android"], stdDevMatrix["Writing 2.0", "Marvin"])
benchmarkVector = c("Data Manipulation", "Data Manipulation", "Writing 2.0", "Writing 2.0")
systemVector = c("Android", "Marvin", "Android", "Marvin")

processedData = data.frame(averageVector, stdDevVector, benchmarkVector, systemVector)
colnames(processedData) = c("Average", "StdDev", "Benchmark", "System")

pdf(outputFile)
ggplot(processedData) +
    geom_col(mapping = aes(x = Benchmark, y = Average, fill = System), position = "dodge") +
    xlab("Benchmark") +
    ylab("Score") +
    labs(fill = "")
dev.off()
