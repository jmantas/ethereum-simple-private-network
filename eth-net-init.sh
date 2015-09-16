#!/bin/sh

. ./parameters.conf

NODEID=$1

if [ ! -d "${DATAROOT}/${NETID}/${NODEID}" ]; then
	mkdir -p ${DATAROOT}/${NETID}/${NODEID}
fi


echo "Initializing node $1 with private genesis block"

${GETH} --genesis ./genesis-private.json --nat none --nodiscover --maxpeers 1 \
--datadir=${DATAROOT}/${NETID}/${NODEID} --networkid ${NETID} -verbosity 6 \
--port ${PORT}${NODEID} --rpcaddr ${RPCADDRESS} --rpcport ${RPCPORT}${NODEID} \
console 2>> ${DATAROOT}/${NETID}/${NODEID}.log
