#!/bin/bash

rm_if_exists() {
  local target="$1"
  if [ -e $target ]; then
    rm $target
  fi
}

set -o errexit

if [ $# -lt 2 ]; then
  cat <<__USAGE
Two arguments are required.
  arg1: .y file
  arg2: input string
__USAGE

  exit 1
fi

rm_if_exists debug.log
rm_if_exists stack.log

racc -t -o parser.rb "$1"

ruby parser.rb "$2"

ruby stack_graph.rb stack.log > stack_graph.html
