#!/bin/sh
cd ./ebin
if [ $# -gt 0 ]; then
    if [ $# == 1 ]; then
    # if [ $# -eq 1 ]; then
        erl -noshell -s make files ../$1 -s init stop
    else
        for i in $*;
        do erl -noshell -s make files ../$i -s init stop;
        done
    fi
else
    erl -noshell -s make all -s init stop
fi



