#!/usr/bin/env bash
# This script changes the refresh rate of the framework laptop screen.
# It uses kscreen-doctor and therefore is intended to be used with KDE.

# The script can be called with a refresh rate as an argument, e.g. hz.sh 60
# If no argument is given, the script will list all available refresh rates for the current resolution and ask the user to choose one.
# If the script is called with a refresh rate as an argument, it will check if the desired refresh rate is available for the current resolution and apply it.

# The script can also be called with a refresh rate in the script name, e.g. hz60.sh
# So you can just link to the script with the desired refresh rate, e.g. ln -s hz.sh hz60.sh

# Dependencies: jq kscreen-doctor

# Check if the dependencies are installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed"
    exit 1
fi
if ! command -v kscreen-doctor &> /dev/null; then
    echo "kscreen-doctor is not installed"
    exit 1
fi

# Get the desired refresh rate from the script name take into account the file extension
DESIRED_REFRESH_RATE=$(basename $0 | sed 's/[^0-9]//g')

# If it is empty get the current refresh rate from kscreen-doctor
CURRENT_MODE=$(kscreen-doctor -j | jq -r '.outputs[] | select(.name == "eDP-1") | .currentModeId')

if [ "x$1" == "x" ]; then
    # get current refresh rate from current mode
    REFRESH_RATE=$(kscreen-doctor -j | jq -r '.outputs[] | select(.name == "eDP-1") | .modes[] | select(.id == "'$CURRENT_MODE'") | .refreshRate')
else
    DESIRED_REFRESH_RATE=$1
fi

# Get all mode names for eDP-1
MODES=$(kscreen-doctor -j | jq -r '.outputs[] | select(.name == "eDP-1") | .modes[] | .name')

# Get the current resoultion
CURRENT_MODE_NAME=$(kscreen-doctor -j | jq -r '.outputs[] | select(.name == "eDP-1") | .modes[] | select(.id == "'$CURRENT_MODE'") | .name')

# Get only the resolution without the refresh rate
CURRENT_RESOLUTION=$(echo $CURRENT_MODE_NAME | sed 's/@.*//')

# Get all modes with the same resolution as the current mode but different refresh rates
MODES=$(echo "$MODES" | grep "$CURRENT_RESOLUTION")

# deduplicate
MODES=$(echo "$MODES" | sort | uniq)

# If the desired refresh rate is in the list, check if it is in the list and apply it
if [ "x$DESIRED_REFRESH_RATE" != "x" ]; then
    if [ $(echo "$MODES" | grep -c "$CURRENT_RESOLUTION@$DESIRED_REFRESH_RATE") -eq 1 ]; then
        kscreen-doctor output.eDP-1.mode.$CURRENT_RESOLUTION@$DESIRED_REFRESH_RATE
        exit 0
    else 
        echo "The desired refresh rate is not available for the current resolution"
        # cut the resolution from the modes so that only the refresh rates are shown
        MODES=$(echo "$MODES" | sed 's/.*@//')
        
        echo "Available refresh rates for the current resolution:"
        echo "$MODES"

        exit 1
    fi
else 

    # Remove the current mode from the list
    MODES=$(echo "$MODES" | grep -v "$CURRENT_MODE_NAME")

    # If it is only one, apply it
    if [ $(echo "$MODES" | wc -l) -eq 1 ]; then
        MODE=$(echo "$MODES" | head -n 1)
        kscreen-doctor output.eDP-1.mode.$MODE
        exit 0
    fi

    # If it is more than one, ask the user
    echo "Choose a mode:"
    select MODE in $MODES; do
        if [ "x$MODE" != "x" ]; then
            kscreen-doctor output.eDP-1.mode.$MODE
            break
        fi
    done
fi



