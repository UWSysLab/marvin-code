#!/usr/bin/perl

use warnings;
use strict;

system("./graph-section-2-graph.R section-2-graph-data.csv section-2-graph.pdf");
system("./graph-commercial-app-startup-times.R commercial-app-startup-times.csv commercial-app-startup-times.pdf");
system("./graph-compiler-overhead-synthetic.R compiler-overhead-synthetic.csv compiler-overhead-synthetic.pdf");

system("./process-object-size-heap-frac-data.pl > heapfrac-data.txt");
system("./graph-object-size-heap-frac-graph.R heapfrac-data.txt cumulative-heap-frac-vs-object-size.pdf");

system("./process-parsed-microbenchmark-logs.pl parsed-log-marvin-ws50-20clones-45sec.txt \"Marvin (working set 50%)\" parsed-log-stock-android-ws50-20clones-45sec.txt Android > live-app-data.csv");
system("Rscript graph-live-apps.R live-app-data.csv live-app-graph.pdf");
