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
sudo docker cp server-resources-updater.zip tf2-dedicated_rgl:/home/steam/
rm server-resources-updater.zip
sudo docker exec -it tf2-dedicated_rgl unzip -o /home/steam/server-resources-updater.zip -d /home/steam/tf-dedicated/tf/

# Install SOAP DM plugin
git clone https://github.com/sapphonie/SOAP-TF2DM
pushd SOAP-TF2DM
cp -vr addons cfg ../tf2-data_rgl/tf/
popd
rm -rf SOAP-TF2DM

# Install F2's competitive plugins
wget http://sourcemod.krus.dk/f2-sourcemod-plugins.zip
sudo docker cp f2-sourcemod-plugins.zip tf2-dedicated_rgl:/home/steam/
rm f2-sourcemod-plugins.zip
sudo docker exec -it tf2-dedicated_rgl unzip -o /home/steam/f2-sourcemod-plugins.zip -d /home/steam/tf-dedicated/tf/addons/sourcemod/plugins/

# Install cURL dependency for F2's logs.tf plugin
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/sourcemod-curl-extension/curl_1.3.0.0_linux.zip
sudo docker cp curl_1.3.0.0_linux.zip tf2-dedicated_rgl:/home/steam/
rm curl_1.3.0.0_linux.zip
sudo docker exec -it tf2-dedicated_rgl unzip -o /home/steam/curl_1.3.0.0_linux.zip -d /home/steam/tf-dedicated/tf/addons/sourcemod/
echo logstf_apikey `cat logstf_apikey.txt` >>tf2-data_rgl/tf/cfg/server.cfg

# Install demos.tf plugin and cURL dependency
wget https://github.com/demostf/plugin/raw/master/demostf.smx
mv -v demostf.smx tf2-data_rgl/tf/addons/sourcemod/
echo sm_demostf_apikey `cat demostf_apikey.txt` >>tf2-data_rgl/tf/cfg/server.cfg
wget https://github.com/spiretf/docker-comp-server/raw/master/curl.ext.so --directory-prefix tf2-data_rgl/tf/addons/sourcemod/extensions/

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
