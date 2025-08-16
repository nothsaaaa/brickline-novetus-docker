#!/usr/bin/env bash

# --- Variables ---
export NOVETUS_BIN=/Launcher/data/bin
export PORT=${PORT:-53640}          # Novetus server port (default)
export MAP=${MAP:-"Z:\\default.rbxl"}
export MAXPLAYERS=${MAXPLAYERS:-12}
export CLIENT=${CLIENT:-"2012M"}

# New variables for masterScript
export SERVER_NAME=${SERVER_NAME:-"New Brickline Server | ${MAP} | ${CLIENT}"}
export BRICKLINE_IP=${BRICKLINE_IP:-""}
export BRICKLINE_PORT=${BRICKLINE_PORT:-0}

# --- Wine setup ---
export WINEPREFIX=/home/novetus/.wine
export WINEDEBUG=-all
export SDL_AUDIODRIVER=dummy
export XDG_RUNTIME_DIR=/tmp/sockets

wine reg add "HKCU\Software\Wine\Drivers" /v Audio /d "null" /f 1>/dev/null

# --- Update Novetus addons ---
sed -i '3s/.*/Addons = {"Utils", "URLSetup", "NDUtils", "masterScript"}/' /Launcher/data/addons/core/AddonLoader.lua

# --- Update masterScript.lua ---
MASTER_SCRIPT="/Launcher/data/addons/masterScript.lua"

# Set ServerName on line 26
sed -i "26s|.*|local ServerName = \"$SERVER_NAME\"|" "$MASTER_SCRIPT"

# Set REALIPADDR and REALIP_PORT on lines 24-25
sed -i "24s|.*|local REALIPADDR = \"$BRICKLINE_IP\"|" "$MASTER_SCRIPT"
sed -i "25s|.*|local REALIP_PORT = $BRICKLINE_PORT|" "$MASTER_SCRIPT"

# --- Clean logs ---
mkdir -p /home/novetus/.wine/drive_c/users/novetus/AppData/Local/Roblox/logs/ 1>/dev/null
rm -rf /home/novetus/.wine/drive_c/users/novetus/AppData/Local/Roblox/logs/* 1>/dev/null

echo "
-----------------------------------------------------
		    NOVETUSDOCKER		    
  Github: https://github.com/Mollomm1/NovetusDocker
-----------------------------------------------------
"

# --- Start services ---
cd /defaults
/defaults/forceloadserver.sh &
uvicorn server:app --host 0.0.0.0 --port 3000 --log-level critical > /dev/null 2>&1 &
wine $NOVETUS_BIN/Novetus.exe -cmdonly -load server -no3d -hostport $PORT -client $CLIENT -map $MAP -maxplayers $MAXPLAYERS &
/defaults/getlogs.sh
