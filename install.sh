#!/bin/bash

# Mauro Emmanuel Rambo
#
# email: mauro.e.rambo@gmail.com
#

# Dependencies Installation

#prereq/prereq.sh

#Instalation directory
workdir=$PWD
sudo mkdir blockchain && cd blockchain

echo "####################################################### "
echo "#GENERATING CRYPTO KEYS# "
echo "####################################################### "

cryptogen generate --config=$workdir/config/crypto-config.yaml

echo "####################################################### "
echo "#GENERATING GENESIS BLOCK TX# "
echo "####################################################### "

sudo mkdir -p artifacts
PROFILEBLOCK="ThreeOrgsOrdererGenesis"
CHANNELID="system-channel"
CONFIGPATH=$workdir+"/config/configtx.yaml"
OUTPUT=$workdir+"/blockchain/artifacts/genesis.block"
configtxgen -profile $PROFILEBLOCK -channelID $CHANNELID -outputBlock $OUTPUT -configPath $CONFIGPATH

echo "####################################################### "
echo "#GENERATING CHANNEL TX# "
echo "####################################################### "

PROFILECHANNEL="ThreeOrgsChannel"
CHANNELNAME="marketplace"
OUTPUT=$workdir+"/blockchain/artifacts/channel.tx"
configtxgen -profile $PROFILECHANNEL -channelID $CHANNELNAME -outputCreateChannelTx $OUTPUT -configPath $CONFIGPATH

