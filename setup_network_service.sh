echo "This is a simple script for computers that often lose network connections, crashes etc"

cp services/network_uptime.service  /lib/systemd/system || exit 1

cp check_network.sh /bin/check_network

echo "Reloading systemd daemon"
systemctl daemon-reload

echo "Enabeling the service"
systemctl enable --now network_uptime.service