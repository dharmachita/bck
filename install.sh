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

ANCHORPEER1=$workdir"/blockchain/artifacts/Org1MSP.tx"
ANCHORPEER2=$workdir"/blockchain/artifacts/Org2MSP.tx"
ANCHORPEER3=$workdir"/blockchain/artifacts/Org3MSP.tx"
configtxgen -profile $PROFILECHANNEL -outputAnchorPeersUpdate $ANCHORPEER1 -channelID $CHANNELNAME -asOrg Org1MSP
configtxgen -profile $PROFILECHANNEL -outputAnchorPeersUpdate $ANCHORPEER2 -channelID $CHANNELNAME -asOrg Org2MSP
configtxgen -profile $PROFILECHANNEL -outputAnchorPeersUpdate $ANCHORPEER3 -channelID $CHANNELNAME -asOrg Org3MSP



