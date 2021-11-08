#!/bin/bash

# Mauro Emmanuel Rambo
#
# email: mauro.e.rambo@gmail.com
#

#utils
sudo apt-get install curl
sudo zypper install curl


echo ""
echo "####################################################### "
echo "              #INICIANDO PORTAINER# "
echo "####################################################### "
echo ""

docker volume create portainer_data

docker run -d -p 8000:8000 -p 9000:9000 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest



echo ""
echo "####################################################### "
echo "               #ABRIR NAVEGADOR#"
echo "####################################################### "
echo ""

prip="$(curl ifconfig.me)"
echo "Iniciar en el navegador http://localhost:9000 ó http://"$prip":9000 para setear las credenciales y acceder al dashboard."
