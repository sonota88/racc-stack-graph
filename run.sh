#!/bin/bash

rm_if_exists() {
  local target="$1"
  if [ -e $target ]; then
    rm $target
  fi
}

set -o errexit

rm_if_exists debug.log
rm_if_exists stack.log

racc -t -o parser.rb "$1"

ruby parser.rb "$2"

ruby stack_graph.rb stack.log > stack_graph.html
