#!/bin/bash

# Mauro Emmanuel Rambo
#
# email: mauro.e.rambo@gmail.com
#

# Prerequisites installation

#prereq/prereq.sh

echo "####################################################### "
echo "#GENERATING CRYPTO KEYS# "
echo "####################################################### "

path=$PWD/config
sudo mkdir -p $HOME/blockchain/ && cd $HOME/blockchain/
cryptogen generate --config=$path/crypto-config.yaml

echo "####################################################### "
echo "#GENERATING GENESIS BLOCK TX# "
echo "####################################################### "

sudo mkdir -p artifacts
cd $path
PROFILEBLOCK="ThreeOrgsOrdererGenesis"
CHANNELID="system-channel"
configtxgen -profile $PROFILEBLOCK -channelID $CHANNELID -outputBlock $HOME/blockchain/artifacts/genesis.block

echo "####################################################### "
echo "#GENERATING CHANNEL TX# "
echo "####################################################### "

PROFILECHANNEL="ThreeOrgsChannel"
CHANNELNAME="marketplace"
configtxgen -profile $PROFILECHANNEL -channelID $CHANNELNAME -outputCreateChannelTx $HOME/blockchain/artifacts/channel.tx

