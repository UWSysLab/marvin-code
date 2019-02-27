#!/usr/bin/perl

use warnings;
use strict;

system("./graph-section-2-graph.R data/section-2-graph-data.csv graphs/section-2-graph.pdf");

system("./graph-compiler-overhead-synthetic.R data/compiler-overhead-synthetic.csv graphs/compiler-overhead-synthetic.pdf");

system("./process-object-size-heap-frac-data.pl > data/heapfrac-data.txt");
system("./graph-object-size-heap-frac-graph.R data/heapfrac-data.txt graphs/cumulative-heap-frac-vs-object-size.pdf");

system("./process-parsed-microbenchmark-logs.pl \\\
data/live-app-parsed-500mb-marvin-ws-10-percent.txt \"Marvin (50MB WS)\" \\\
data/live-app-parsed-500mb-marvin-ws-5-percent.txt \"Marvin (25MB WS)\" \\\
data/live-app-parsed-500mb-stock-android.txt Android \\\
> data/live-app-data.csv");
system("Rscript graph-live-apps.R data/live-app-data.csv graphs/live-app-graph.pdf");

system("Rscript graph-pcmark-data.R data/pcmark-data.csv graphs/pcmark-graph.pdf");

# Use process-memory-data.pl to generate memory-data-processed.csv
system("Rscript graph-memory-data.R data/memory-data-processed.csv graphs/memory-graph.pdf");

system("Rscript graph-heapwalker-data.R data/heapwalker-data-nofaults-4kb.csv data/heapwalker-data-faults-4kb.csv graphs/heapwalker-graph");
