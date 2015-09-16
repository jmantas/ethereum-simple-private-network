#!/bin/sh

. ./parameters.conf

if [ ! -d "${DATAROOT}/${NETID}/${NODEID}" ]; then
	mkdir -p ${DATAROOT}/${NETID}/${NODEID}
fi

${GETH} --genesis ./genesis-private.json --nat none --nodiscover --maxpeers 1 --datadir=${DATAROOT}/${NETID}/${NODEID} --networkid ${NETID} -verbosity 6 --port ${PORT} --rpcaddr ${RPCADDRESS} --rpcport ${RPCPORT} console 2> ${DATAROOT}/${NETID}/${NODEID}.log
