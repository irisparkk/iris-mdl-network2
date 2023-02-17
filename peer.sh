#!/bin/bash

LOG_LEVEL=info
export HOME=$(dirname $(readlink -f $0))
TYPE="$1"
CONSENSUS="$2"
: ${TYPE:="m"}
: ${CONSENSUS:="local"}

usage(){
    echo "Usage:"
    echo -e "\tInput peer number and process type. ex)sudo ./peer.sh m raft"
    echo -e "\tThe second parameter is process type. [f|m] The default is m."
    echo -e "\tThe third parameter is network type. [solo|raft|local] The default is raft."
    exit 1
}

cleanPeer(){
    ############ Process initialization ############
    PROCESS=`pgrep peer`
    if [ -n "$PROCESS" ]; then
        echo "kill $PROCESS"
        kill -9 $PROCESS
    fi
    
    rm -rf ./production/peer/peer$PEERNUM
}

[ "${1}" == "HELP" ] && usage

########### Network Check ###########
########### Peer Number Setting ###########
result=`./getHostName.sh peer $CONSENSUS`
if [ ${?} != 0 ]; then
    echo $result
    exit $?
fi
PEERNUM=`echo ${result: -1}`


[ "${1}" == "CLEAN" ] && echo cleanPeer ${2} && exit 1
cleanPeer ${1}


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
    echo "MDL Fabric Peer$PEERNUM Start"
    export GRPC_VERBOSITY=error
    export GRPC_LOG_SEVERITY_LEVEL=error
    export GRPC_GO_GRPC_VERBOSITY=error
    export GRPC_GO_LOG_SEVERITY_LEVEL=error

    export CORE_MDL_MXP=true 

    export CORE_LEDGER_STATE_LEVELDBCONFIG_BLOCKCACHECAPACITY=128
    export CORE_LEDGER_STATE_LEVELDBCONFIG_WRITEBUFFER=64
    export CORE_LEDGER_STATE_LEVELDBCONFIG_BLOCKSIZE=
    export CORE_LEDGER_STATE_LEVELDBCONFIG_OPENFILESCACHECAPACITY=
    export CORE_LEDGER_STORAGE_MAXBLOCKFILESIZE=64
elif [ "$TYPE" == "f" ]; then
    export CORE_MDL_PEER_MXP=false
    echo "Fabric Peer$PEERNUM Start"
else
    echo "ERROR : The second parameter is process type. [f|m] The default is m."
    exit 1
fi

############ Set core.yaml ############
export FABRIC_CFG_PATH=${HOME}

############ Peer Vasic Setting ############
export FABRIC_LOGGING_SPEC="$LOG_LEVEL"
export CORE_CHAINCODE_LOGGING_LEVEL="$LOG_LEVEL"

############## TLS SETTING ###################
export CORE_PEER_TLS_ENABLED=$TLS_ENABLED

############ Start Peer ############
./bin/peer node start
