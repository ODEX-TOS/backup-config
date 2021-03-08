#!/bin/bash

if [[ "$(id -u)" != "0" ]]; then
    echo "This script is only supported for servers (must be ran as root)"
    exit 1
fi

if [[ "$1" == "" ]]; then
    echo "Script to create systemd timers for you server"


    if [[ ! $(command -v emborg) ]]; then
        echo "emborg doesn't seem to be installed, install it first"
        exit 1
    fi

    emborg_location="$(command -v emborg)"

    echo -e "\nValid configurations"
    find "$HOME"/.config/emborg -type f -maxdepth 1 -not -iname "settings" | awk -F'/' '{print "- " $NF}'
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
        if [[ "$valid_data" == "$date" ]]; then
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
    sed -i 's;'$_config_match';'$config';g' services/emborg-backup-"$config".service || exit 1
    sed -i 's;'$_emborg_match';'$emborg_location';g' services/emborg-backup-"$config".service || exit 1

    sed -i 's;'$_date_match';'$date';g' services/emborg-backup-"$config".timer  || exit 1

    echo "Setting up the services"
    mv services/emborg-backup-"$config".service  /lib/systemd/system || exit 1
    mv services/emborg-backup-"$config".timer  /lib/systemd/system || exit 1

    echo "Creating the remote borg repo"
    emborg -c "$config" init || exit 1

    echo "Reloading systemd daemon"
    systemctl daemon-reload

    echo "Enabling timer"
    systemctl enable --now emborg-backup-"$config".timer
elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "USAGE:"
    echo -e "$0\t\tSetup systemd services and telegram notifications for errors"
    echo -e "$0 -t\tSetup the telegram notification (notify-telegram) script"
    exit 0
fi

echo "Setting up telegram notification client"

_api_key_match="@@T_API_KEY@@"
_chat_id_match="@@USER_ID@@"

while true; do
    read -p "What is the api key of the telegram bot? " api_key
    read -p "What is the Chat_ID or Channel ID to send notification to? " chat_id

    sed 's;'$_api_key_match';'$api_key';g' notify-telegram > notify-telegram.sh || exit 1
    sed -i 's;'$_chat_id_match';'$chat_id';g' notify-telegram.sh || exit 1
    
    bash ./notify-telegram.sh --title "Test setup" --text "This is a test message coming from $(hostname)"
    
    read -p "Did you receive a message on telegram (might take a minute?) (y/N)" answer
    if [[ "$answer" == "y" || "$answer" == "Y" || "$answer" == "yes" || "$answer" == "Yes" ]]; then
        chmod +x ./notify-telegram.sh
        mv ./notify-telegram.sh /bin/notify-telegram
        exit 0
    else
        echo "Your api key or chat id is wrong, please re-enter the credentials"
    fi
done
