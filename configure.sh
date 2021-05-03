#!/usr/bin/env bash

# Configures an existing container once the server is running, then restarts it


# Change default server name
export SERVER_NAME=`cat server_name.txt`
sudo docker exec -it tf2-dedicated sed -i 's/New "tf" Server/'$SERVER_NAME'/' /home/steam/tf-dedicated/tf/cfg/server.cfg

# Change default rcon password
export RCON_PASSWORD=`cat rcon_password.txt`
sudo docker exec -it tf2-dedicated sed -i 's/rcon_password changeme/rcon_password '$RCON_PASSWORD'/' /home/steam/tf-dedicated/tf/cfg/server.cfg

# Update the system
sudo docker exec -u root -it tf2-dedicated apt update
sudo docker exec -u root -it tf2-dedicated apt full-upgrade -y
# Install unzip
sudo docker exec -u root -it tf2-dedicated apt install unzip -y

# Copy in motd.txt and mapcycle.txt
cp -v motd.txt tf2-data/tf/cfg/motd_default.txt
cp -v mapcycle.txt tf2-data/tf/cfg/

# Append extra configurations
cat admins_simple.ini >>tf2-data/tf/addons/sourcemod/configs/admins_simple.ini
cat server.cfg >>tf2-data/tf/cfg/server.cfg

# Enable nominate/rtv
pushd tf2-data/tf/addons/sourcemod/plugins/disabled/
mv -v mapchooser.smx nominations.smx rockthevote.smx ..
popd

# Votescramble plugin, untested and decidedly unused
#wget --content-disposition https://forums.alliedmods.net/attachment.php?attachmentid=144208
#sudo docker cp gscramble_3.0.33.zip tf2-dedicated:/home/steam/tf-dedicated/tf/
#rm gscramble_3.0.33.zip
#sudo docker exec -it tf2-dedicated unzip -o /home/steam/tf-dedicated/tf/gscramble_3.0.33.zip -d /home/steam/tf-dedicated/tf/

# Addcond plugin
wget --content-disposition https://www.sourcemod.net/vbcompiler.php?file_id=76215
mv -v TF2\ Add\ Condition\ 1.1.smx tf2-data/tf/addons/sourcemod/plugins/

# Copy in workshop maps
cp -v workshop/* tf2-data/tf/maps/

# Link workshop maps to apache2 server
sudo mkdir -p /var/www/html/tf/maps
sudo ln --symbolic --target-directory=/var/www/html/tf/maps/ `pwd`/workshop/*

# Restart
sudo docker restart tf2-dedicated
