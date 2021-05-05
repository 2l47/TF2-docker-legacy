#!/usr/bin/env bash

# Configures an existing container once the server is running, then restarts it


# Change default server name
export SERVER_NAME=`cat server_name.txt`
sudo docker exec -it tf2-dedicated_rgl sed -i 's/New "tf" Server/'$SERVER_NAME'/' /home/steam/tf-dedicated/tf/cfg/server.cfg

# Change default rcon password
export RCON_PASSWORD=`cat rcon_password.txt`
sudo docker exec -it tf2-dedicated_rgl sed -i 's/rcon_password changeme/rcon_password '$RCON_PASSWORD'/' /home/steam/tf-dedicated/tf/cfg/server.cfg

# Update the system
sudo docker exec -u root -it tf2-dedicated_rgl apt update
sudo docker exec -u root -it tf2-dedicated_rgl apt full-upgrade -y
# Install unzip
sudo docker exec -u root -it tf2-dedicated_rgl apt install unzip -y

# Install RGL updater plugin
wget https://github.com/RGLgg/server-resources-updater/releases/latest/download/server-resources-updater.zip
sudo docker cp server-resources-updater.zip tf2-dedicated_rgl:/home/steam/tf-dedicated/tf/
rm server-resources-updater.zip
sudo docker exec -it tf2-dedicated_rgl unzip -o /home/steam/tf-dedicated/tf/server-resources-updater.zip -d /home/steam/tf-dedicated/tf/

# Install SOAP DM plugin
git clone https://github.com/sapphonie/SOAP-TF2DM
pushd SOAP-TF2DM
cp -vr addons cfg ../tf2-data_rgl/tf/
popd
rm -rf SOAP-TF2DM

# Copy in motd_rgl.txt and mapcycle_rgl.txt
cp -v motd_rgl.txt tf2-data_rgl/tf/cfg/motd_default.txt
cp -v mapcycle_rgl.txt tf2-data_rgl/tf/cfg/

# Append extra configurations
cat admins_simple.ini >>tf2-data_rgl/tf/addons/sourcemod/configs/admins_simple.ini
cat server_rgl.cfg >>tf2-data_rgl/tf/cfg/server.cfg

# Download RGL custom competitive maps
./download-rgl-maps.sh

# Install RGL maps
cp -v rgl_maps/* tf2-data_rgl/tf/maps/

# Link RGL maps to apache2 server
sudo mkdir -p /var/www/html/tf/maps
sudo ln --symbolic --target-directory=/var/www/html/tf/maps/ `pwd`/rgl_maps/*

# Restart
sudo docker restart tf2-dedicated_rgl
