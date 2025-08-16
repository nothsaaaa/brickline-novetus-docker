#!/bin/bash

DIR="Launcher"

BLACKLIST=("data/clients")

# Join blacklist into a `find` exclude expression
EXCLUDE_EXPR=""
for blk in "${BLACKLIST[@]}"; do
    EXCLUDE_EXPR="$EXCLUDE_EXPR -path \"$DIR/$blk\" -prune -o"
done

# Evaluate the find command
eval find \"$DIR\" $EXCLUDE_EXPR -type f -print | while read -r file; do
    mimetype=$(file --mime-type -b "$file")
    case "$mimetype" in
        image/png|image/bmp|image/jpeg|audio/x-wav|audio/x-vorbis+ogg|audio/mpeg)
            echo "Deleting: $file ($mimetype)"
            rm -f "$file"
            ;;
    esac
done

# Remove redist, maps, models
echo "Removing other files we don't need..."
rm -rf Launcher/data/_CommonRedist Launcher/data/models Launcher/data/maps \
       Launcher/data/clients/2017L-Studio \
       Launcher/data/clients/2006S \
       Launcher/data/clients/2007E \
       Launcher/data/clients/2007M \
       Launcher/data/clients/2009E-HD

echo "Done cleaning"
