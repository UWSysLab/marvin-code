#!/usr/bin/Rscript

# I referred to this StackOverflow answer to figure out how to rotate the
# x-axis labels: https://stackoverflow.com/a/1331400.
#
# I referred to this page to learn how to order the columns in a column chart:
# https://rstudio-pubs-static.s3.amazonaws.com/7433_4537ea5073dc4162950abb715f513469.html.
#
# I referred to this page to learn how to use command-line arguments in
# Rscript:
# https://www.r-bloggers.com/passing-arguments-to-an-r-script-from-command-lines/.

library(ggplot2)

args = commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
    stop("usage: ./graph-section-2-graph.R input-csv output-pdf")
}
inputFile = args[1]
outputFile = args[2]

myData = read.csv(inputFile, header = TRUE)

pdf(outputFile)
ggplot(myData) +
    geom_col(mapping = aes(x = Name, y = Time, fill = System), position = "dodge2") +
    xlab("") +
    ylab("App switch time (s)") +
    labs(fill = "") +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="top") +
    theme(plot.margin = margin(0, 0.2, 0, 1.2, "cm")) +
    theme(axis.text = element_text(size=14), axis.title = element_text(size=18), legend.text = element_text(size=18)) +
    coord_fixed(0.5)
dev.off()
