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

docker rm -vf $(docker ps -a -q) && docker rmi -f $(docker images -a -q)

export VERBOSE=false
export FABRIC_CFG_PATH=$workdir

CHANNEL_NAME=$CHANNELNAME docker-compose -f $workdir/docker-base/docker-compose-cli-couchdb.yaml up -d


echo ""
echo "####################################################### "
echo "#DENTRO DEL CLI# "
echo "####################################################### "
echo "" 

docker exec -it cli bash
export CHANNEL_NAME=marketplace
peer channel create -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem

#agergar al peer 0 de la org1 al canal
peer channel join -b marketplace.block

#agergar al peer 0 de la org2 al canal
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/users/Admin@org2.acme.com/msp CORE_PEER_ADDRESS=peer0.org2.acme.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt peer channel join -b marketplace.block

#agergar al peer 0 de la org3 al canal
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/users/Admin@org3.acme.com/msp CORE_PEER_ADDRESS=peer0.org3.acme.com:7051 CORE_PEER_LOCALMSPID="Org3MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt peer channel join -b marketplace.block

#Definir anchorpeer para Org1
peer channel update -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem

#Definir anchorpeer para Org2
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/users/Admin@org2.acme.com/msp CORE_PEER_ADDRESS=peer0.org2.acme.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt peer channel update -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem

#Definir anchorpeer para Org3
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/users/Admin@org3.acme.com/msp CORE_PEER_ADDRESS=peer0.org3.acme.com:7051 CORE_PEER_LOCALMSPID="Org3MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt peer channel update -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org3MSPanchors.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem

#PROBAR DE HACERLO DENTRO DE CONTENEDOR CLI Y VER SI FUNCIONA. 
#ERROR-->Error: got unexpected status: BAD_REQUEST -- error applying config update to existing channel 'marketplace': error authorizing update: error validating ReadSet: proposed update requires that key [Group]  /Channel/Application/Org1MSP be at version 0, but it is currently at version 1