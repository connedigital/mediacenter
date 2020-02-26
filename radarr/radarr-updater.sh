#!/bin/bash
# radarr-updater by @connedigital

# Global value
user="radarr"
installdir="/opt/$user"

# working directory
cd $installdir || exit

# stop radarr first
service radarr stop

echo "Atualizando radarr. Por favor aguarde!"
wget -q "$( wget -qO- https://api.github.com/repos/Radarr/Radarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 )"
tar -xzf Radarr.develop.*.linux.tar.gz
rm -f Radarr.develop.*.linux.tar.gz
chown -R $user:$user Radarr

# start radarr now
service radarr start

echo "Atualizacao finalizada."
