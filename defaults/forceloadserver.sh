#!/bin/bash

#
# This script exist to pass the "Loading..." popup that some clients get stuck on.
#

# Make sure errors don't stop the script
set +e

while true; do
    # Get all window IDs with "Server" in their title
    window_ids=$(xdotool search --name "Server" 2>/dev/null || true)
	for win in $window_ids; do
		# Focus the window
		(xdotool windowactivate "$win" 2>/dev/null) || true
		sleep 0.2

		# Get geometry
		geometry=$(xdotool getwindowgeometry --shell "$win" 2>/dev/null)
		if [ -n "$geometry" ]; then
			eval "$geometry"
			offset_x=$(( (RANDOM % 41) - 20 ))
			offset_y=$(( (RANDOM % 41) - 20 ))
			center_x=$((X + WIDTH / 2 + offset_x))
			center_y=$((Y + HEIGHT / 2 + offset_y))
			(xdotool mousemove "$center_x" "$center_y" 2>/dev/null) || true
			sleep 0.1
		fi
	done
    
    # Wait 2 seconds before next round
    sleep 2
done

