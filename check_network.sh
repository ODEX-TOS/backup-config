#!/bin/bash

while true; do
        if ! ping -c1 1.1.1.1 &>/dev/null; then
                echo "No network connection"

                # restarting network
                tos network restart
                sleep 15  # give some time to connect to the network
                # then restart sshd
                systemctl restart sshd
        fi
        echo "Sleeping..."
        sleep 60
done
