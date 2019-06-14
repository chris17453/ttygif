#!/bin/bash

# TODO make this ... better

gprof2dot --show-samples -n0 -e0 -f pstats $1 | dot -Tpng -o $2