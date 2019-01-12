#!/usr/bin/perl

use warnings;
use strict;

system("./graph-section-2-graph.R section-2-graph-data.csv section-2-graph.pdf");

#system("./graph-commercial-app-startup-times.R commercial-app-startup-times.csv commercial-app-startup-times.pdf");

system("./graph-compiler-overhead-synthetic.R compiler-overhead-synthetic.csv compiler-overhead-synthetic.pdf");

system("./process-object-size-heap-frac-data.pl > heapfrac-data.txt");
system("./graph-object-size-heap-frac-graph.R heapfrac-data.txt cumulative-heap-frac-vs-object-size.pdf");

system("./process-parsed-microbenchmark-logs.pl \\\
parsed-marvin-ws25.txt \"Marvin (50MB WS)\" \\\
parsed-marvin-ws50.txt \"Marvin (100MB WS)\" \\\
parsed-stock-android.txt Android \\\
> live-app-data.csv");
system("Rscript graph-live-apps.R live-app-data.csv live-app-graph.pdf");

system("Rscript graph-pcmark-data.R pcmark-data.csv pcmark-graph.pdf");

# TODO: add preprocessing step that generates memory-data-processed.csv to this script
system("Rscript graph-memory-data.R memory-data-processed.csv memory-graph.pdf");
