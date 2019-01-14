#!/usr/bin/perl

use warnings;
use strict;

system("./graph-section-2-graph.R section-2-graph-data.csv section-2-graph.pdf");

system("./graph-compiler-overhead-synthetic.R compiler-overhead-synthetic.csv compiler-overhead-synthetic.pdf");

system("./process-object-size-heap-frac-data.pl > heapfrac-data.txt");
system("./graph-object-size-heap-frac-graph.R heapfrac-data.txt cumulative-heap-frac-vs-object-size.pdf");

system("./process-parsed-microbenchmark-logs.pl \\\
live-app-parsed-marvin-ws25.txt \"Marvin (50MB WS)\" \\\
live-app-parsed-marvin-ws50.txt \"Marvin (100MB WS)\" \\\
live-app-parsed-stock-android.txt Android \\\
> live-app-data.csv");
system("Rscript graph-live-apps.R live-app-data.csv live-app-graph.pdf");

system("Rscript graph-pcmark-data.R pcmark-data.csv pcmark-graph.pdf");

# Use process-memory-data.pl to generate memory-data-processed.csv
system("Rscript graph-memory-data.R memory-data-processed.csv memory-graph.pdf");
