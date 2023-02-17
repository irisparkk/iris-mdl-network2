#!/bin/bash

# peer, orderer, ca의 network ip 설정이 돼 있는지 확인
# /etc/hosts 에 설정된 네트워크를 참고하여 실행 시 호스트 이름을 반환

MDL_NETWORK_TYPE=$2
: ${MDL_NETWORK_TYPE:="local"}

if [ ${MDL_NETWORK_TYPE} == "local" ];then
    array_orderer=("orderer0")
    array_peer=("peer0")
    array_ca=("ca")
    IPADDRESS="192.168.99.77"
else
    array_orderer=("orderer0" "orderer1" "orderer2")
    array_peer=("peer0" "peer1" "peer2")
    array_ca=("ca")
    IPADDRESS="192.168.99.77"
fi

function checkHostIp(){
	for list in ${!1}
	do
        ab=`cat /etc/hosts | grep " ${list} " |cut -d' ' -f1 | egrep -v '^[[:space:]]*(#.*)?$'`
        if [ "${ab}" == "" ];then
            echo "${list} is not set in \`/etc/hosts\`. Please check again."
            exit 100
        fi
	done
}

function getHostIp(){
	for list in ${!1}
	do
        ab=`cat /etc/hosts | grep " ${list} " |cut -d' ' -f1 | egrep -v '^[[:space:]]*(#.*)?$'`
        if [ "${IPADDRESS}" == "${ab}" ];then
            echo $list
            exit 0
        fi
	done
	echo "my ip address is not set in \`/etc/hosts\`. Please check again."
        exit 100
}


checkHostIp array_orderer[@]
checkHostIp array_peer[@]
checkHostIp array_ca[@]

getHostIp array_$1[@]




