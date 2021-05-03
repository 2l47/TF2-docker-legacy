#!/usr/bin/env bash


# Install prerequisites
sudo apt install docker docker-compose -y

# Delete existing container
sudo docker stop tf2-dedicated_rgl
sudo docker rm tf2-dedicated_rgl
./housekeeping.sh

# Set up new container, configure it, and restart it
mkdir -p $(pwd)/tf2-data_rgl
chmod 777 $(pwd)/tf2-data_rgl # Makes sure the directory is writeable by the unprivileged container user
sudo docker run -d --net=host -v $(pwd)/tf2-data_rgl:/home/steam/tf-dedicated/ --name=tf2-dedicated_rgl -e SRCDS_TOKEN=`cat srcds_token.txt` -e SRCDS_PORT=27015 -e SRCDS_PW="`cat server_password_rgl.txt`" -e SRCDS_MAXPLAYERS=16 -e SRCDS_STARTMAP="koth_product_rcx" cm2network/tf2:sourcemod

echo Please run configure-rgl.sh once CPU load has normalized.
echo Use \"sudo docker stats\" to monitor load.
