#!/usr/bin/Rscript
#
# I referred to this StackOverflow question to learn how to force
# ggplot2 to avoid abbreviating axis labels:
# https://stackoverflow.com/questions/14563989/force-r-to-stop-plotting-abbreviated-axis-labels-e-g-1e00-in-ggplot2.
#
# I referred to this StackOverflow question to learn how to reorder the
# bars in a bar graph:
# https://stackoverflow.com/questions/25664007/reorder-bars-in-geom-bar-ggplot2.

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-heapwalker-data.R nofaults-input-csv faults-input-csv output-prefix")
}

noFaultsInputFile = args[1]
noFaultsOutputFile = paste0(args[3], "-nofaults.pdf")

noFaultsData = read.csv(noFaultsInputFile, header = TRUE)

pdf(noFaultsOutputFile)
ggplot(noFaultsData, aes(x=reorder(System, -AvgSpeed), y=AvgSpeed)) +
    geom_col(fill = "#2ab248") +
    geom_errorbar(aes(ymin = AvgSpeed - StddevSpeed, ymax = AvgSpeed + StddevSpeed), width = 0.4) +
    xlab("") +
    ylab("Speed (objects touched/sec)") +
    theme_classic() +
    theme(axis.text.x = element_text(angle=45,hjust=1)) +
    theme(axis.text.x = element_text(size=24), axis.text.y = element_text(size=20), axis.title = element_text(size=26)) +
    scale_y_continuous(labels = scales::comma) +
    coord_fixed(ratio = 0.0000040)
dev.off()

faultsInputFile = args[2]
faultsOutputFile = paste0(args[3], "-faults.pdf")

faultsData = read.csv(faultsInputFile, header = TRUE)

pdf(faultsOutputFile)
ggplot(faultsData, aes(x=reorder(System, -AvgSpeed), y=AvgSpeed)) +
    geom_col(fill = "#2ab248") +
    geom_errorbar(aes(ymin = AvgSpeed - StddevSpeed, ymax = AvgSpeed + StddevSpeed), width = 0.4) +
    xlab("") +
    ylab("Speed (objects touched/sec)") +
    theme_classic() +
    theme(axis.text.x = element_text(size=16), axis.text.y = element_text(size=16), axis.title = element_text(size=20)) +
    scale_y_continuous(labels = scales::comma) +
    coord_fixed(ratio = 0.000008)
dev.off()
