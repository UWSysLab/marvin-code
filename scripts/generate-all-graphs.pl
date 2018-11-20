#!/usr/bin/perl

use warnings;
use strict;

system("./graph-section-2-graph.R section-2-graph-data.csv section-2-graph.pdf");
system("./graph-commercial-app-startup-times.R commercial-app-startup-times.csv commercial-app-startup-times.pdf");
system("./graph-compiler-overhead-synthetic.R compiler-overhead-synthetic.csv compiler-overhead-synthetic.pdf");
