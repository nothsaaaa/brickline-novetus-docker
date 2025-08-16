#!/bin/bash

WATCH_DIR="/home/novetus/.wine/drive_c/users/novetus/AppData/Local/Roblox/logs"  # or your log directory
PATTERNS=("log_*.txt" "log_*TaskScheduler*.txt")

# Track already-tailed files
declare -A tailed_files

# Function to start tailing a file
tail_file() {
    local file="$1"
    if [[ ! -v tailed_files["$file"] ]]; then
        tail -F "$file" | awk '
        /^[0-9]{2}\.[0-9]{2}\.[0-9]{4}/ {date=$1; time=$2; next}
        /^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]+/ {print date " " $0; fflush()}
        ' &
        tailed_files["$file"]=1
    fi
}

# Tail existing files
for pattern in "${PATTERNS[@]}"; do
    for file in $WATCH_DIR/$pattern; do
        [[ -f "$file" ]] && tail_file "$file"
    done
done

# Monitor directory for new files
inotifywait -m -e create "$WATCH_DIR" --format '%f' | while read NEWFILE; do
    for pattern in "${PATTERNS[@]}"; do
        if [[ "$NEWFILE" == ${pattern} ]]; then
            tail_file "$WATCH_DIR/$NEWFILE"
        fi
    done
done
