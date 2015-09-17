#!/bin/sh

DATAROOT=~/eth-data-dir/
NETID=99999
PORT=177
RPCPORT=188
RPCADDRESS=127.0.0.1
GETH=`which geth`


checkDir() {
	NODEID=$1
	if [ ! -d "${DATAROOT}/${NETID}/${NODEID}" ] && [ $2 = '4init' ]
	then
		echo "Creating data diractory ${DATAROOT}/${NETID}/${NODEID}"
		mkdir -p ${DATAROOT}/${NETID}/${NODEID}
	
	elif [ ! -d "${DATAROOT}/${NETID}/${NODEID}" ] && [ $2 = '4bootup' ]
	then
		echo "Node does not exists. Need to run: ./eth-spn.sh init $1"
		exit 1	

	fi


}

initNode() {
	NODEID=$1
	checkDir ${NODEID} 4init
	echo "Initializing node $1 with private genesis block"

	${GETH} --genesis ./genesis-private.json --nat none --nodiscover --maxpeers 1 \
	--datadir=${DATAROOT}/${NETID}/${NODEID} --networkid ${NETID} -verbosity 6 \
	--port ${PORT}${NODEID} --rpcaddr ${RPCADDRESS} --rpcport ${RPCPORT}${NODEID} \
	console 2>> ${DATAROOT}/${NETID}/${NODEID}.log

}


bootupNode() {
	NODEID=$1
	checkDir ${NODEID} 4bootup
	echo "Booting up node $1 ..."

	${GETH} --nat none --nodiscover --maxpeers 1 \
	--datadir=${DATAROOT}/${NETID}/${NODEID} --networkid ${NETID} -verbosity 6 \
	--port ${PORT}${NODEID} --rpc --rpcaddr ${RPCADDRESS} \
	--rpcport ${RPCPORT}${NODEID} console 2>> ${DATAROOT}/${NETID}/${NODEID}.log

}

case "$1" in
        init)
		initNode $2
                ;;
        up)
		bootupNode $2
                ;;
        *)
        echo "Usage: $0 [ init | up ] [ < node id > ]"
RETVAL=$?
esac
exit 0
