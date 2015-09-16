#!/bin/sh

. ./parameters.conf

NODEID=$1

if [ ! -d "${DATAROOT}/${NETID}/${NODEID}" ]; then
	echo "Node does not exists. Need to run: ./eth-net-init.sh $1"
	exit 1	
fi


echo "Booting up node $1 ..."

${GETH} --nat none --nodiscover --maxpeers 1 \
--datadir=${DATAROOT}/${NETID}/${NODEID} --networkid ${NETID} -verbosity 6 \
--port ${PORT}${NODEID} --rpc --rpcaddr ${RPCADDRESS} --rpcport ${RPCPORT}${NODEID} \
console 2>> ${DATAROOT}/${NETID}/${NODEID}.log
