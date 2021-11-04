#!/bin/bash

export CHANNEL_NAME=marketplace
export CHAINCODE_NAME=foodcontrol
export CHAINCODE_VERSION=1
export CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/$CHAINCODE_NAME/"
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem
peer channel create -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls true --cafile $ORDERER_CA

#agergar al peer 0 de la org1 al canal
peer channel join -b marketplace.block

#agergar al peer 0 de la org2 al canal
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/users/Admin@org2.acme.com/msp CORE_PEER_ADDRESS=peer0.org2.acme.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt peer channel join -b marketplace.block

#agergar al peer 0 de la org3 al canal
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/users/Admin@org3.acme.com/msp CORE_PEER_ADDRESS=peer0.org3.acme.com:7051 CORE_PEER_LOCALMSPID="Org3MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt peer channel join -b marketplace.block

#Definir anchorpeer para Org1
peer channel update -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx --tls true --cafile $ORDERER_CA

#Definir anchorpeer para Org2
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/users/Admin@org2.acme.com/msp CORE_PEER_ADDRESS=peer0.org2.acme.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt peer channel update -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx --tls true --cafile $ORDERER_CA

#Definir anchorpeer para Org3
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/users/Admin@org3.acme.com/msp CORE_PEER_ADDRESS=peer0.org3.acme.com:7051 CORE_PEER_LOCALMSPID="Org3MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt peer channel update -o orderer.acme.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org3MSPanchors.tx --tls true --cafile $ORDERER_CA

#github.com/cucumber/godog@v0.8.0/go.mod: checksum mismatch
#        downloaded: h1:Cp3tEV1LRAyH/RuCThcxHS/+9ORZ+FMzPva2AZ5Ki+A=
#        go.sum:     h1:FQ2MobPXycdSajAK3inNgLSAKGFmZqbE4S/CExz41Ys=

#Empaquetar los smart contracts
peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path $CC_SRC_PATH --lang golang --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION} >&log.txt

#Instalar smart contracts en los peers
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz
#ver de obtener el valor del package id como salida del siguiente comando
#peer lifecycle chaincode queryinstalled --peerAddresses peer0.org1.example.com:7051

##CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/users/Admin@org2.acme.com/msp CORE_PEER_ADDRESS=peer0.org2.acme.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz
#CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/users/Admin@org3.acme.com/msp CORE_PEER_ADDRESS=peer0.org3.acme.com:7051 CORE_PEER_LOCALMSPID="Org3MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

#Definir políticas de endorsamiento (primera y segunda org pueden recibir transacciones)
#peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence 1 --tls true --cafile $ORDERER_CA --waitForEvent --signature-policy "OR ('Org1MSP.member','Org3MSP.member')" --package-id (lo que se copia)
#CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/users/Admin@org3.acme.com/msp CORE_PEER_ADDRESS=peer0.org3.acme.com:7051 CORE_PEER_LOCALMSPID="Org3MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence 1 --tls true --cafile $ORDERER_CA --waitForEvent --signature-policy "OR ('Org1MSP.member','Org3MSP.member')" --package-id (lo que se copia)

#Comitear los cambios
#peer lifecycle chaincode commit -o orderer.acme.com:7050 --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence 1 --tls true --cafile $ORDERER_CA --waitForEvent --peerAddresses peer0.org1.acme.com:7051 --peerAddresses peer0.org2.acme.com:7051 --peerAddresses peer0.org3.acme.com:7051 --signature-policy "OR ('Org1MSP.member','Org2MSP.member','Org3MSP.member')" --output json --init-required

#peer chaincode invoke -o orderer.acme.com:7050 --tls true --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CHAINCODE_NAME} -c '{"Args":["initLedger"]}'