#!/bin/bash

LOG_LEVEL=debug
export HOME=$(dirname $(readlink -f $0))
TYPE="$1"
CONSENSUS="$2"
: ${TYPE:="m"}
: ${CONSENSUS:="local"}

usage(){
    echo "Usage:"
    echo -e "\tInput orderer number and process type. ex)sudo ./orderer.sh m raft"
    echo -e "\tThe second parameter is process type. [f|m] The default is m."
    echo -e "\tThe third parameter is network type. [solo|raft|local] The default is raft."
    exit 1
}

cleanOrderer(){
    PROCESS=`pgrep orderer`
    if [ -n "$PROCESS" ]; then
        echo "kill $PROCESS"
        kill -9 $PROCESS
    fi
    rm -rf ./production/orderer/orderer$ORDERERNUM
    echo "Orderer is clean"
}

[ "${1}" == "HELP" ] && usage

########### Network Check ###########
########### Orderer Number Setting ###########
result=`./getHostName.sh orderer $CONSENSUS`
if [ ${?} != 0 ]; then
    echo $result
    exit $?
fi
ORDERERNUM=`echo ${result: -1}`

[ "${1}" == "CLEAN" ] && cleanOrderer ${2} && exit 0
cleanOrderer ${1}

########### Network Setting ###########
if [ "$CONSENSUS" == "raft" ];then
        TLS_ENABLED=true
elif [ "$CONSENSUS" == "solo" ];then
        TLS_ENABLED=false
elif [ "$CONSENSUS" == "local" ];then
        TLS_ENABLED=true
else
	echo "ERROR : The third parameter is network type. [solo|raft|local] The default is raft."
	exit 1
fi

############ MDL or Fabric setting ############
if [ "$TYPE" == "m" ]; then
    echo "MDL Fabric Orderer${ORDERERNUM} Start"
    export CONFIGTX_ORDERER_BATCHTIMEOUT="2s"
    export CONFIGTX_ORDERER_BATCHSIZE_MAXMESSAGECOUNT="1500"
    export CONFIGTX_ORDERER_BATCHSIZE_ABSOLUTEMAXBYTES="98 MB"
    export CONFIGTX_ORDERER_BATCHSIZE_PREFERREDMAXBYTES="512 KB"
    
    export CORE_MDL_MXP=true

    export GRPC_VERBOSITY=error
    export GRPC_LOG_SEVERITY_LEVEL=error
    export GRPC_GO_GRPC_VERBOSITY=error
    export GRPC_GO_LOG_SEVERITY_LEVEL=error

elif [ "$TYPE" == "f" ]; then
    export CORE_MDL_PEER_MXP=false
    echo "Fabric Orderer${ORDERERNUM} Start"
else
    echo "ERROR : The second parameter is process type. [f|m] The default is m."
    exit 1
fi

############ Orderer Vasic Setting ############
export FABRIC_CFG_PATH=${HOME}
export FABRIC_LOGGING_SPEC="${LOG_LEVEL}"
export ORDERER_GENERAL_LOGLEVEL="{$LOG_LEVEL}"

############## TLS SETTING ###################
export ORDERER_GENERAL_TLS_ENABLED=${TLS_ENABLED}

############ Start Orderer ############
./bin/orderer
