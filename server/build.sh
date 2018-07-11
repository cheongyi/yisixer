#!/bin/sh
# ./rebar g-d
cp -r /home/git/deps .
if [ $# -ge 1 ]; then
    cd ebin
    for var in $*; do
        erl -noshell -s make files ../$var -s init stop
    done
else
    ./rebar compile
fi
