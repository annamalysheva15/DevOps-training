#!/bin/zsh

default_threshold=10

if [ "$#" -eq 0 ]; then
    threshold=$default_threshold
else
    threshold=$1
fi

while true; do
    free_space=$((100 - $(df -h / | awk 'NR==2 {print $(NF-4)}' | tr -d '%')))

    if [ "$free_space" -lt "$threshold" ]; then
        echo "The disk free space is low! Current free space is $free_space%"
    else
        echo "You're good to go!"
    fi

    sleep 300
done
