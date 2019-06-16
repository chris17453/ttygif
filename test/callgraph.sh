#!/bin/bash

# TODO make this ... better

gprof2dot --show-samples  -f pstats $1 | dot -Tpng -o $2