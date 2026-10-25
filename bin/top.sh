#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

PID=$1

if [ "$PID" != "" ]; then

    if [[ "$PID" =~ ^[0-9]+$ ]] && [ "$PID" -gt 0 ]; then
        ParentID=$(ps -o ppid= -p "$PID" 2>/dev/null)
        # Remove possible leading/trailing whitespace
        ParentID=$(echo "$ParentID" | xargs)

        # Validate ParentID similarly
        if [[ "$ParentID" =~ ^[0-9]+$ ]] && [ "$ParentID" -gt 0 ]; then
            CMD=$(ps -p "$ParentID" -o cmd --no-headers 2>/dev/null)
            echo "$PID|$CMD"
        else
            echo "$PID|(parent process not found or invalid)" >&2
        fi

    fi

else

    PIDs=$(top -b -n 1 | awk '/^ *[0-9]/ {print $1}' | head -10)

    for PID in $PIDs; do

        if [[ "$PID" =~ ^[0-9]+$ ]] && [ "$PID" -gt 0 ]; then
            ParentID=$(ps -o ppid= -p "$PID" 2>/dev/null)
            # Remove possible leading/trailing whitespace
            ParentID=$(echo "$ParentID" | xargs)

            # Validate ParentID similarly
            if [[ "$ParentID" =~ ^[0-9]+$ ]] && [ "$ParentID" -gt 0 ]; then
                CMD=$(ps -p "$ParentID" -o cmd --no-headers 2>/dev/null)
                echo "$PID|$CMD"
            else
                echo "$PID|(parent process not found or invalid)" >&2
            fi

        fi

    done

fi
