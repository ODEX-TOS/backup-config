#!/bin/bash

# always use trailing slashed as that is how rsync uses it
BACKUP_LOC="$HOME/Sync/borg/"
PORTABLE_DRIVE_LOC="$HOME/portable_sync/Sync/borg/"

if [[ ! -d "$BACKUP_LOC" ]]; then
        echo "Our backup drive is not mounted to $BACKUP_LOC"
        echo "Please mount it"
        exit 1
fi

if [[ ! -d "$PORTABLE_DRIVE_LOC" ]]; then
        echo "Our portable backup drive is not mounted to $PORTABLE_DRIVE_LOC"
        echo "Please mount it"
        exit 1
fi

rsync -rl --progress "$BACKUP_LOC" "$PORTABLE_DRIVE_LOC"
