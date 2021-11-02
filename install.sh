#!/bin/bash

# Mauro Emmanuel Rambo
#
# email: mauro.e.rambo@gmail.com
#

# Dependencies Installation

#prereq/prereq.sh

#Instalation directory
workdir=$PWD
sudo mkdir blockchain 
sudo chown $USER blockchain
cd blockchain

echo ""
echo "####################################################### "
echo "#GENERATING CRYPTO KEYS# "
echo "####################################################### "
echo ""

cryptogen generate --config=$workdir/config/crypto-config.yaml

echo ""
echo "####################################################### "
echo "#GENERATING GENESIS BLOCK TX# "
echo "####################################################### "
echo ""

sudo mkdir -p artifacts 
sudo chown $USER artifacts
PROFILEBLOCK="ThreeOrgsOrdererGenesis"
CHANNELID="system-channel"
CONFIGPATH=$workdir"/config/"
OUTPUT=$workdir"/blockchain/artifacts/genesis.block"
configtxgen -profile $PROFILEBLOCK -channelID $CHANNELID -outputBlock $OUTPUT -configPath $CONFIGPATH

echo ""
echo "####################################################### "
echo "#GENERATING CHANNEL TX# "
echo "####################################################### "
echo ""

PROFILECHANNEL="ThreeOrgsChannel"
CHANNELNAME="marketplace"
OUTPUT=$workdir"/blockchain/artifacts/channel.tx"
configtxgen -profile $PROFILECHANNEL -channelID $CHANNELNAME -outputCreateChannelTx $OUTPUT -configPath $CONFIGPATH

echo ""
echo "####################################################### "
echo "#ANCHOR PEERS TX# "
echo "####################################################### "
echo ""

anchor_array=($workdir"/blockchain/artifacts/Org1MSPanchors.tx" $workdir"/blockchain/artifacts/Org2MSPanchors.tx" $workdir"/blockchain/artifacts/Org3MSPanchors.tx")
for ((i = 0; i < ${#anchor_array[@]}; ++i)); do
    configtxgen -profile $PROFILECHANNEL -outputAnchorPeersUpdate ${anchor_array[i]} -channelID $CHANNELNAME -asOrg Org${i+1}MSP -configPath $CONFIGPATH
done

echo ""
echo "####################################################### "
echo "#STARTING NETWORK# "
echo "####################################################### "
echo ""

export VERBOSE=false
export FABRIC_CFG_PATH=$workdir

CHANNEL_NAME=$CHANNELNAME docker-compose -f $workdir/docker-compose-cli-couchdb.yaml up -d

