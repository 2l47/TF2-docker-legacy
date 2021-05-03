#!/usr/bin/env bash


# Enable rtv early
sudo docker exec -it tf2-dedicated sed -i 's/sm_rtv_initialdelay "30.0"/sm_rtv_initialdelay "1.0"/' /home/steam/tf-dedicated/tf/cfg/sourcemod/rtv.cfg

# Enable calling rtv more often
sudo docker exec -it tf2-dedicated sed -i 's/sm_rtv_interval "240.0"/sm_rtv_interval "1.0"/' /home/steam/tf-dedicated/tf/cfg/sourcemod/rtv.cfg

# Restart if successful
if [[ $? -eq 0 ]]; then
	sudo docker restart tf2-dedicated
fi
