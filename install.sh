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

cryptopath=$PWD/config/crypto-config.yaml
sudo mkdir -p $HOME/blockchain/ && cd $HOME/blockchain/
cryptogen generate --config=$cryptopath


echo "####################################################### "
echo "#GENERATING GENESIS BLOCK TX# "
echo "####################################################### "

configpath=$PWD/config/configtx.yaml
PROFILEBLOCK="ThreeOrgsOrdererGenesis"
CHANNELID="system_channel"
configtxgen -profile $PROFILE -channelID $CHANNELID -outputBlock $HOME/blockchain/genesis.block


echo "####################################################### "
echo "#GENERATING CHANNEL TX# "
echo "####################################################### "

PROFILECHANNEL="ThreeOrgsChannel"
CHANNELNAME="marketplace"
configtxgen -profile $PROFILE -channelID $CHANNELNAME -outputCreateChannelTx $HOME/blockchain/channel.tx

