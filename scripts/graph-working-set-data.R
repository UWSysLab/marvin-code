#!/usr/bin/Rscript

# This script expects as input a CSV file generated by
# process-working-set-data.pl.
#
# I used this StackOverflow answer to learn how to create a new data frame that
# includes only those rows from the original data frame with a specific value
# in one of the columns: https://stackoverflow.com/a/21309261.
#
# I used this link to learn how to match more than one value when creating a
# subset: https://www.statmethods.net/management/subset.html.
#
# I used these links to learn how to manually change the labels on the legend:
# https://stackoverflow.com/q/23635662
# https://ggplot2.tidyverse.org/reference/guide_legend.html

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-working-set-data.R input-csv output-prefix")
}
inputFile = args[1]
outputPrefix = args[2]

myData = read.csv(inputFile, header = TRUE)

# Convert to MB
myData$Value = myData$Value / 1048576;

activeFgData = subset(myData, Type == "active_fg_read_max" | Type == "active_fg_read_min")
activeFgOutputFile = paste0(outputPrefix, "-active-fg.pdf")
pdf(activeFgOutputFile)
ggplot(activeFgData, aes(x = App)) +
    geom_col(aes(y = Value, fill = Type)) +
    xlab("App") +
    ylab("Read working set (MB)") +
    labs(fill = "") +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    theme(axis.text = element_text(size=14), axis.title = element_text(size=16)) +
    scale_fill_discrete(breaks = c("active_fg_read_max", "active_fg_read_min"), labels = c("Max", "Min")) +
    coord_fixed(0.05)
dev.off()

idleFgData = subset(myData, Type == "idle_fg_read")
idleFgOutputFile = paste0(outputPrefix, "-idle-fg.pdf")
pdf(idleFgOutputFile)
ggplot(idleFgData, aes(x = App, y = Value)) +
    geom_col() +
    xlab("App") +
    ylab("Read working set (MB)") +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    theme(axis.text = element_text(size=14), axis.title = element_text(size=16)) +
    coord_fixed(1.5)
dev.off()

bgData = subset(myData, Type == "bg_read")
bgOutputFile = paste0(outputPrefix, "-bg.pdf")
pdf(bgOutputFile)
ggplot(bgData, aes(x = App, y = Value)) +
    geom_col() +
    xlab("App") +
    ylab("Read working set (MB)") +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    theme(axis.text = element_text(size=14), axis.title = element_text(size=16)) +
    coord_fixed(1.5)
dev.off()
