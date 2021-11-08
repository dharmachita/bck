#!/bin/bash

echo ""
echo "          ####################################################### "
echo "                      #LEVANTANDO RED BLOCKCHAIN# "
echo "          ####################################################### "
echo ""

export CHANNEL_NAME=marketplace
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem
export CORE_PEER_MSPCONFIGPATH_ORG2=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/users/Admin@org2.acme.com/msp 
export CORE_PEER_TLS_ROOTCERT_FILE_ORG2=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH_ORG3=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/users/Admin@org3.acme.com/msp 
export CORE_PEER_TLS_ROOTCERT_FILE_ORG3=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt


echo ""
echo "          ####################################################### "
echo "                      #CREANDO CANAL Y BLOQUE GENESIS# "
echo "          ####################################################### "
echo ""

#Crear el canal
peer channel create \
    -o orderer.acme.com:7050 \
    -c $CHANNEL_NAME \
    -f ./channel-artifacts/channel.tx \
    --tls true --cafile $ORDERER_CA

sleep 10

echo ""
echo "          ####################################################### "
echo "                      #AGREGANDO PEERS AL CANAL# "
echo "          ####################################################### "
echo ""

#Agergar al peer 0 de la org1 al canal
peer channel join -b marketplace.block

#Agergar al peer 0 de la org2 al canal
CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH_ORG2 \
    CORE_PEER_ADDRESS=peer0.org2.acme.com:7051 \
    CORE_PEER_LOCALMSPID="Org2MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE_ORG2 \
    peer channel join -b marketplace.block

#Agergar al peer 0 de la org3 al canal
CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH_ORG3 \
    CORE_PEER_ADDRESS=peer0.org3.acme.com:7051 \
    CORE_PEER_LOCALMSPID="Org3MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE_ORG3 \
    peer channel join -b marketplace.block


echo ""
echo "          ####################################################### "
echo "                      #ESTABLECIENDO ANCHOR PEERS# "
echo "          ####################################################### "
echo ""

#Definir anchorpeer para Org1
peer channel update \
    -o orderer.acme.com:7050 \
    -c $CHANNEL_NAME \
    -f ./channel-artifacts/Org1MSPanchors.tx \
    --tls --cafile $ORDERER_CA

#Definir anchorpeer para Org2
CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH_ORG2 \
    CORE_PEER_ADDRESS=peer0.org2.acme.com:7051 \
    CORE_PEER_LOCALMSPID="Org2MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE_ORG2 \
    peer channel update \
        -o orderer.acme.com:7050 \
        -c $CHANNEL_NAME \
        -f ./channel-artifacts/Org2MSPanchors.tx \
        --tls --cafile $ORDERER_CA

#Definir anchorpeer para Org3
CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH_ORG3 \
    CORE_PEER_ADDRESS=peer0.org3.acme.com:7051 \
    CORE_PEER_LOCALMSPID="Org3MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE_ORG3 \
    peer channel update \
        -o orderer.acme.com:7050 \
        -c $CHANNEL_NAME \
        -f ./channel-artifacts/Org3MSPanchors.tx \
        --tls --cafile $ORDERER_CA

echo ""
echo "          ####################################################### "
echo "                        #CONFIGURACION DE RED COMPLETA# "
echo "          ####################################################### "
echo ""

/opt/gopath/src/github.com/chaincode/foodcontrol_installer.sh