#!/bin/bash

HOME=$(dirname $(dirname $(readlink -f $0)))

BIN_DIR=$HOME/bin
LOG_DIR=$HOME/log
CHANNEL_NAME=mdl
CHAINCODE_NAME=mdl
MAX_RETRY="5"

USER="$1"
: ${USER:="Admin"}
FUNCTION="$2"
: ${FUNCTION:="mint"}
ARGS="$3"
: ${ARGS:="\"50\""}

export FABRIC_CFG_PATH=${HOME}
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA="${HOME}/crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE="${HOME}/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"
export CORE_PEER_MSPCONFIGPATH="${HOME}/crypto-config/peerOrganizations/org1.example.com/users/${USER}@org1.example.com/msp"
export CORE_PEER_ADDRESS="peer0.org1.example.com:7051"
PEER_CONN_PARMS="${PEER_CONN_PARMS} --peerAddresses ${CORE_PEER_ADDRESS}"
TLSINFO=$(eval echo "--tlsRootCertFiles \$CORE_PEER_TLS_ROOTCERT_FILE")
PEER_CONN_PARMS="${PEER_CONN_PARMS} ${TLSINFO}"

function invoke() {
    CC_INIT_FCN=$1
    CC_ARGS="$2"
    set -x
    
    # fcn_call='{"function":"'${CC_INIT_FCN}'","Args":['${CC_ARGS}']}'
    fcn_call='{"Args":["'${CC_INIT_FCN}'",'${CC_ARGS}']}'
    echo "invoke fcn call:${fcn_call}"
    echo "invoke peer connection parameters:${PEER_CONN_PARMS[@]}"
    ${BIN_DIR}/peer chaincode invoke -o orderer0.example.com:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile "$ORDERER_CA" -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} ${PEER_CONN_PARMS[@]} -c ${fcn_call} >> ${LOG_DIR}/${CC_INIT_FCN}.log 2>&1
    #  ${BIN_DIR}/peer chaincode query -o orderer0.example.com:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile "$ORDERER_CA" -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} ${PEER_CONN_PARMS[@]} -c ${fcn_call} >> ${LOG_DIR}/${CC_INIT_FCN}.log 2>&1

    # Init
    #init,,50000,0x15d7b4c55f177267f699857a9fef5e4a7d263f13,,
    # ${BIN_DIR}/peer chaincode invoke -o orderer0.example.com:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile "$ORDERER_CA" -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} ${PEER_CONN_PARMS[@]} -c '{"Args":["init","0xabcde,50000,0xabcde,10,5"]}' >> ${LOG_DIR}/${CC_INIT_FCN}.log 2>&1

    { set +x; } 2>/dev/null
    # cat ${LOG_DIR}/${CC_INIT_FCN}.log
    echo "Invoke transaction successful on peer0 on channel '${CHANNEL_NAME}'"
}

function main() {
    invoke ${FUNCTION} ${ARGS}
}

main
