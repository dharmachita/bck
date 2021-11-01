#!/bin/bash

# Mauro Emmanuel Rambo
#
# email: mauro.e.rambo@gmail.com
#

echo ""
echo "####################################################### "
echo "#STARTING PORTAINER# "
echo "####################################################### "
echo ""

docker volume create portainer_data

docker run -d -p 8000:8000 -p 9000:9000 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

https://localhost:9000   

echo ""
echo "####################################################### "
echo "INICIAR LOCALHOST:9000 EN EL NAVEGADOR..."
echo "####################################################### "
echo ""

