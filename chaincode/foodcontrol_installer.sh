#!/bin/bash

echo ""
echo "          ####################################################### "
echo "                    #INSTALACION DE CHAINCODE FOODCONTROL# "
echo "          ####################################################### "
echo ""

export CHANNEL_NAME=marketplace
export CHAINCODE_NAME=foodcontrol
export CHAINCODE_VERSION=1
export CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/$CHAINCODE_NAME/"
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/acme.com/orderers/orderer.acme.com/msp/tlscacerts/tlsca.acme.com-cert.pem

#Empaquetar los smart contracts
peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz \
    --path $CC_SRC_PATH \
    --lang golang \
    --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION} >&log.txt

#Instalar smart contracts en los peers
peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/users/Admin@org2.acme.com/msp \
    CORE_PEER_ADDRESS=peer0.org2.acme.com:7051 \
    CORE_PEER_LOCALMSPID="Org2MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt \
    peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/users/Admin@org3.acme.com/msp \
    CORE_PEER_ADDRESS=peer0.org3.acme.com:7051 \
    CORE_PEER_LOCALMSPID="Org3MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt \
    peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

#Definir políticas de endorsamiento (primera y segunda org pueden recibir transacciones)
peer lifecycle chaincode approveformyorg \
    --channelID $CHANNEL_NAME \
    --name ${CHAINCODE_NAME} \
    --version ${CHAINCODE_VERSION} \
    --sequence 1 --tls true --cafile $ORDERER_CA --waitForEvent \
    --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" --package-id $CC_PACKAGE_ID

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/users/Admin@org3.acme.com/msp \
    CORE_PEER_ADDRESS=peer0.org3.acme.com:7051 \
    CORE_PEER_LOCALMSPID="Org3MSP" \
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt \
    peer lifecycle chaincode approveformyorg \
    --channelID $CHANNEL_NAME \
    --name ${CHAINCODE_NAME} \
    --version ${CHAINCODE_VERSION} \
    --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent \
    --signature-policy "OR ('Org1MSP.peer','Org3MSP.peer')" --package-id $CC_PACKAGE_ID

#Comitear los cambios
peer lifecycle chaincode commit -o orderer.acme.com:7050 \
    --channelID $CHANNEL_NAME \
    --name ${CHAINCODE_NAME} \
    --version ${CHAINCODE_VERSION} \
    --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent \
    --peerAddresses peer0.org1.acme.com:7051 \
    --peerAddresses peer0.org2.acme.com:7051 \
    --peerAddresses peer0.org3.acme.com:7051 \
    --signature-policy "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')" \
    --output json --init-required

peer chaincode invoke -o orderer.acme.com:7050 --tls true --cafile $ORDERER_CA \
    -C $CHANNEL_NAME -n ${CHAINCODE_NAME} -c '{"Args":["initLedger"]}'