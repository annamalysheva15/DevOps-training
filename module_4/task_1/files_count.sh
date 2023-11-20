#!/bin/zsh

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 directory1 [directory2 ...]"
    exit 1
fi

for dir in "$@"; do
    if [ -d "$dir" ]; then
        file_count=$(find "$dir" -type f | wc -l)
        echo "Directory: $dir, Number of files: $file_count"
    else
        echo "Directory '$dir' does not exist."
    fi
done
