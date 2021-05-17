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
Install emborg `yay -S emborg python-llfuse` it is in the `AUR`, alternatively use `makepkg`
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

## Reverting a backup

You can either mount an archive to an existing directory, copy over the required files or restore a given directory

### Restore a given directory

The requirement here is that the directory needs to exist and has the correct permissions (Otherwise the copying won't work properly)
```bash
emborg extract bin # extract the bin directory

emborg --archive 'tos-2021-03-13T11:54:36' bin # extract bin from a given archive (snapshot)
```

### Mount an archive (as a local directory)

You need to have `python-llfuse` installed on your system for this to work.
`yay -S python-llfuse`

```bash
emborg mount ~/archive # mount the last archive to the directory ~/archive

emborg --archive 'tos-2021-03-13T11:54:36' ~/archive # mount a given archive to the directory ~/archive
```
### Extra information

When using the `--archive` option you need to supply a valid archive.
To get a list of archives use the following option:
```bash
emborg list
```

You can also list the files/directories available in a given archive by the following command
```bash
emborg manifest
emborg --archive 'tos-2021-03-13T11:54:36' manifest
```

## Reverting a backup on another compute

Firstly you will need to configure your `~/.config/emborg/settings` file to use to correct data.
Alter the following lines:
```py
passphrase = '' # your passphrase here of the repository to backup
repository = 'backup:/home/backup/Sync/borg/tos-zeus-home' # change the last directory to match the name of the repository you want to revert
```

If you don't know the name of the backup you want to make you can execute the following command (substitute the ssh host to match your host)
```bash
ssh backup 'ls Sync/borg'
```

To verify that your backup reverting is going to work execute the following:
```
emborg list # if this returns a list of archives you can revert the backup
```

Now you can follow the details at [Reverting a backup](#reverting-a-backup)

