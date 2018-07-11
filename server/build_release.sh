#!/bin/bash
sed -ie "s/.*debug.*//g" rebar.config
rm -rf rebar.confige
# ./rebar g-d
cp -rf /Volumes/data/deps .
if [ $# -ge 1 ]; then
    cd ebin
    for var in $*; do
        erl -noshell -s make files ../$var -s init stop
    done
else
    ./rebar compile
    cd ebin
fi
