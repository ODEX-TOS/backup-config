#!/bin/bash

echo "Script to create systemd timers for you server"

if [[ "$(id -u)" != "0" ]]; then
    echo "This script is only supported for servers (must be ran as root)"
    exit 1
fi

if [[ ! $(command -v emborg) ]]; then
    echo "emborg doesn't seem to be installed, install it first"
    exit 1
fi

emborg_location="$(command -v emborg)"

echo -e "\nValid configurations"
find "$HOME"/.config/emborg -type f -not -iname "settings" | awk -F'/' '{print "- " $NF}'
echo ""
read -p "What configuration do you want to use? " config

if [[ ! -f "$HOME/.config/emborg/$config" ]]; then
    echo "Did not find $HOME/.config/emborg/$config"
    echo "Config is invalid"
    exit 1
fi

valid_dates=("minutely" "hourly" "daily" "monthly" "weekly" "yearly" "quarterly" "semiannyally" )

echo -e "\nValid trigger dates:"
for date in "${valid_dates[@]}"; do
    echo "- $date"
done

echo
read -p "How often should the backup take place? " date

# validate the date
found="0"
for valid_data in "${valid_dates[@]}"; do
   if [[ "$valid_data" == "$match" ]]; then
        found="1"
   fi
done

if [[ "$found" == "0" ]]; then
    echo "$date is not a valid date"
    exit 1
fi


# now we have validated the date and configuration let's populate the timers
cp services/emborg-backup.service services/emborg-backup-"$config".service 
cp services/emborg-backup.timer services/emborg-backup-"$config".timer


_date_match="@@DATE@@"
_config_match="@@CONFIG@@"
_emborg_match="@@EXEC@@"

# fill in the required data
sed -i 's/'$_config_match'/'$config'/g' services/emborg-backup-"$config".service
sed -i 's/'$_emborg_match'/'$emborg_location'/g' services/emborg-backup-"$config".service 

sed -i 's/'$_date_match'/'$date'/g' services/emborg-backup-"$config".timer 

echo "Setting up the services"
mv services/emborg-backup-"$config".service  /lib/systemd/system
mv services/emborg-backup-"$config".timer  /lib/systemd/system

echo "Reloading systemd daemon"
systemctl daemon-reload

echo "Enabling timer"
systemctl enable --now emborg-backup-"$config".timer