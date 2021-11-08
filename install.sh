#!/bin/bash

# Mauro Emmanuel Rambo
#
# email: mauro.e.rambo@gmail.com
#

# Instalación de Dependencias

#sudo chmod +x prereq/prereq.sh && prereq/prereq.sh

echo 'export PATH=$PATH:$HOME/hyperledger/fabric/fabric-samples/bin' >> ~/.profile
source ~/.profile

#Directorio de instalación
workdir=$PWD
sudo mkdir blockchain 
sudo chown $USER blockchain
cd blockchain

echo ""
echo "          ####################################################### "
echo "                      #GENERANDO CLAVES CRIPTOGRAFICAS# "
echo "          ####################################################### "
echo ""

cryptogen generate --config=$workdir/config/crypto-config.yaml

echo ""
echo "          ####################################################### "
echo "                          #GENERANDO GENESIS BLOCK TX# "
echo "          ####################################################### "
echo ""

sudo mkdir -p artifacts 
sudo chown $USER artifacts
PROFILEBLOCK="ThreeOrgsOrdererGenesis"
CHANNELID="system-channel"
CONFIGPATH=$workdir"/config/"
OUTPUT=$workdir"/blockchain/artifacts/genesis.block"
configtxgen -profile $PROFILEBLOCK -channelID $CHANNELID -outputBlock $OUTPUT -configPath $CONFIGPATH

echo ""
echo "          ####################################################### "
echo "                            #GENERANDO CHANNEL TX# "
echo "          ####################################################### "
echo ""

PROFILECHANNEL="ThreeOrgsChannel"
CHANNELNAME="marketplace"
OUTPUT=$workdir"/blockchain/artifacts/channel.tx"
configtxgen -profile $PROFILECHANNEL -channelID $CHANNELNAME -outputCreateChannelTx $OUTPUT -configPath $CONFIGPATH

echo ""
echo "          ####################################################### "
echo "                          #GENERANDO ANCHOR PEERS TX# "
echo "          ####################################################### "
echo ""

anchor_array=($workdir"/blockchain/artifacts/Org1MSPanchors.tx" $workdir"/blockchain/artifacts/Org2MSPanchors.tx" $workdir"/blockchain/artifacts/Org3MSPanchors.tx")
for ((i = 0; i < ${#anchor_array[@]}; ++i)); do
    configtxgen -profile $PROFILECHANNEL -outputAnchorPeersUpdate ${anchor_array[i]} -channelID $CHANNELNAME -asOrg Org$((i+1))MSP -configPath $CONFIGPATH
done

echo ""
echo "          ####################################################### "
echo "                      #LEVANTANDO RED DE CONTENEDORES# "
echo "          ####################################################### "
echo ""

docker rm -vf $(docker ps -a -q) && docker rmi -f $(docker images -a -q)

export VERBOSE=false
export FABRIC_CFG_PATH=$workdir

CHANNEL_NAME=$CHANNELNAME docker-compose -f $workdir/docker-base/docker-compose-cli-couchdb.yaml up -d

#docker exec cli chmod +x scripts/up.sh
#docker exec cli scripts/up.sh

