#!/bin/sh
a=$(($RANDOM % 100 + 1))
# echo $a
if [ "$a" -ge "20" ]; then
    echo "🍺\033[42m"
    echo "Go home !!! I'll take care of you."
else
    echo "\033[42m"
    echo "I'm Sorry ! It's not the time yet."
fi
echo "\033[0m"