#!/bin/bash

# always use trailing slashed as that is how rsync uses it
BACKUP_LOC="Sync/borg/"
PORTABLE_DRIVE="portable_sync"
PORTABLE_DRIVE_LOC="portable_sync/Sync/borg/"

# Change this UUID to match the portable drive of our backup system
# When you don't mount it automatically this will mount it for you (If detected)
P_UUID="7a2549cd-fc12-451e-bf82-0e5a17492f4b"

if [[ ! -d "$BACKUP_LOC" ]]; then
        echo "Our backup drive is not mounted to $BACKUP_LOC"
        echo "Please mount it, alternitivly, call this script from the correct location"
        exit 1
fi

if [[ ! -d "$PORTABLE_DRIVE_LOC" ]]; then
    echo "Our portable backup drive is not mounted to $PORTABLE_DRIVE_LOC"
    echo "Please mount it"
    echo "Trying portable uuid: $P_UUID"
    
    mount /dev/disk/by-uuid/"$P_UUID" "$PORTABLE_DRIVE" || exit 1
    echo "Mounting successful"

    echo "Rerunning as backup user"
    sudo -H -u backup bash "$0"
    exit 0
fi

rsync -al --progress "$BACKUP_LOC" "$PORTABLE_DRIVE_LOC"

