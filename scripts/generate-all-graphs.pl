#!/usr/bin/perl

use warnings;
use strict;

system("Rscript graph-section-2-graph.R data/section-2-graph-data.csv graphs/section-2-graph.pdf");

system("Rscript graph-compiler-overhead-synthetic-variance.R data/compiler-synthetic-2019-4-12/processed-data.csv graphs/compiler-overhead-synthetic.pdf");

system("perl process-object-size-heap-frac-data.pl > data/heapfrac-data.txt");
system("Rscript graph-object-size-heap-frac-graph.R data/heapfrac-data.txt graphs/cumulative-heap-frac-vs-object-size.pdf");

system("perl process-parsed-allocatoractivity-logs.pl \\\
data/bookmarking-gc-2019-3-26/parsed-marvin.txt \"Marvin (4KB)\" \\\
data/bookmarking-gc-2019-3-26/parsed-android-swap.txt \"Android+swap (4KB)\" \\\
data/bookmarking-gc-2019-3-26/parsed-android-noswap.txt \"Android\" \\\
data/bookmarking-gc-2019-4-19/parsed-mix-marvin.txt \"Marvin (mix)\" \\\
data/bookmarking-gc-2019-4-19/parsed-mix-android-swap-2019-4-20-morning.txt \"Android+swap (mix)\" \\\
> data/bookmarking-gc-2019-4-19/processed-data-combined.csv");
system("Rscript graph-live-apps.R data/bookmarking-gc-2019-4-19/processed-data-combined.csv graphs/live-app-graph.pdf");

system("Rscript graph-pcmark-data.R data/pcmark-data.csv graphs/pcmark-graph.pdf");

# Use process-memory-data.pl to generate processed-data.csv
system("Rscript graph-memory-data.R data/marvin-memory-measurement-2019-4-4/processed-data.csv graphs/memory-graph.pdf");

system("Rscript graph-heapwalker-data.R data/heapwalker-data-nofaults-4kb-2019-4-2.csv data/heapwalker-data-faults-4kb-2019-4-2.csv graphs/heapwalker-graph");

system("Rscript graph-min-working-set.R data/working-set-data-2019-3-19/working-set-data-processed.csv data/working-set-data-2019-3-19/memory-footprint-data.csv graphs/min-working-set-graph.pdf");

# Use process-memory-data.pl to generate processed-data.csv
system("Rscript graph-android-allocation-data.R data/android-memory-allocation-2019-3-30/processed-data.csv graphs/android-allocation-graph.pdf");
