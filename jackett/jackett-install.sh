#!/bin/bash
# jackett-installer by @connedigital

# Global value
user="jackett"
installdir="/opt/$user"

# check if installed
if [[ -e $installdir/Jackett/JackettConsole.exe ]]; then
	echo "Jackett is already installed."
	echo "You should run update script."
	exit
fi

# install mono if not exist
hash mono 2>/dev/null || wget https://raw.githubusercontent.com/sayem314/pirates-mediaserver/master/mono.sh -O - -o /dev/null|bash

# Creating non-root user
[[ -d $installdir ]] || mkdir -p $installdir
echo "Creating user '$user'"
if id -u $user >/dev/null 2>&1; then
	echo "User '$user' already exists. Skipped!"
else
	useradd -r -d $installdir -s /bin/false $user
	chown -R $user:$user $installdir
fi

# working directory
cd $installdir || exit

echo "Installing jackett. Please wait!"
wget -q "$( wget -qO- https://api.github.com/repos/Jackett/Jackett/releases | grep Jackett.Binaries.Mono.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 )"
tar -xzf Jackett.Binaries.Mono.tar.gz
rm -f Jackett.Binaries.Mono.tar.gz
chown -R $user:$user Jackett

# Create startup service
init=$(cat /proc/1/comm)
if [ "$init" == "systemd" ]; then
	echo "Creating systemd service"
	echo "[Unit]
Description=Jackett Daemon
After=network.target
[Service]
WorkingDirectory=$installdir/Jackett
Type=simple
User=$user
ExecStart=/usr/bin/mono JackettConsole.exe --NoRestart
Restart=always
RestartSec=2
TimeoutStopSec=5
[Install]
WantedBy=multi-user.target
"> /etc/systemd/system/jackett.service
	chmod 0644 /etc/systemd/system/jackett.service
	systemctl daemon-reload
	systemctl enable jackett
	service jackett start
fi

echo "Install finished. Default port is 9117"
