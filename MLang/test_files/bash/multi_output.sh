#!/usr/bin/env bash

# prints to STDOUT, STDERR, and has an exit code of 5

echo "STDOUT TEXT"
>&2 echo "STDERR TEXT"
exit 5
