# Backuping of the TOS servers

## Backup server

On the backup server all you need is borg
It is preferred to create an account on the server without any privileges.
Allow ssh access from your to backup computer to the server eg:

```bash
pacman -S borg # the only dependency on the server (and ssh)

useradd backup
sudo mkdir /home/backup
sudo chown backup: /home/backup
sudo su backup

mkdir .ssh
touch authorized_keys # add your public key here
```

## Backup client

Clone this repository in `~/.config/emborg`
Install emborg `yay -S emborg` it is in the `AUR`, alternatively use `makepkg`
Or on other system using `pip install emborg`

> NOTE: if you use `pip install emborg` don't forget to install the borg tool (as emborg depends on it)

Now update the permission of `~/.config/emborg/settings` to `600` as it will contain sensitive data
`chmod 600 ~/.config/emborg/settings`

Next edit the settings and change the following line:

```conf
passphrase = ''              # passphrase for encryption key,
```

To the passphrase of you repo

Next use one of the configurations found in `~/.config/emborg`
If it doesn't exist on the server use `emborg -c <your_configuration> init`
Then to create an archive is as easy as `emborg -c <your_configuration> create`

### systemd timer

If you want to run the backup periodically (using systemd timer) you can do so using the `create-backup-timer.sh` file
Simply run the script (from the `~/.config/emborg` directory) and it will create the required service files with the required configuration

### Telegram notify

Run the `bash ./create-backup-timer.sh -t` to setup the telegram notifier. It will ad a global script called `notify-telegram`
That can be used to send information to telegram.

Example:

```bash
notify-telegram --title "Our title" --text "This is the telegram body"
```

### Multiple drives

In the case of TOS, we have 2 drives, a network drive and a drive that is offline.
The offline drive sync's from the network drive.
The `sync_drives.sh` script provides this functionality. It simply syncs the different borg scripts.
Open the script and edit these variables:

- `BACKUP_LOC` Is the location to the network drive
- `PORTABLE_DRIVE_LOC` This is the portable drive that is not connected over the network
