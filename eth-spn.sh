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
    
        echo ""
        echo "Creating data diractory ${DATAROOT}/${NETID}/${NODEID}"
        echo ""

        mkdir -p ${DATAROOT}/${NETID}/${NODEID}
    
    elif [ ! -d "${DATAROOT}/${NETID}/${NODEID}" ] && [ $2 = '4bootup' ]
    then

        echo ""
        echo "Node does not exists. Need to run: ./eth-spn.sh init $1"
        echo ""
    
        exit 1

    elif [ -d "${DATAROOT}/${NETID}/${NODEID}" ] && [ $2 = '4init' ]
    then

        echo ""
        echo "Node already exists, no need to initialize"
        echo ""

        exit 1

    fi

}

initNode() {

    NODEID=$1
    checkDir ${NODEID} 4init
    
    echo ""
    echo "Initializing node $1 with private genesis block"
    
    echo ""
    echo "Creating new account"
    echo ""
    ${GETH} --datadir=${DATAROOT}/${NETID}/${NODEID} \
    --networkid ${NETID} -verbosity 6 account new 

    echo ""
    echo "Importing genesis block and starting initial node"
    echo ""
    ${GETH} --genesis ./genesis-private.json --nat none --nodiscover \
    --datadir=${DATAROOT}/${NETID}/${NODEID} --networkid ${NETID} -verbosity 6 

}


bootupNode() {
    NODEID=$1
    checkDir ${NODEID} 4bootup
    
    echo ""
    echo "Booting up node $1 ..."
    echo ""

    ${GETH} --nat none --nodiscover \
    --datadir=${DATAROOT}/${NETID}/${NODEID} --networkid ${NETID} -verbosity 6 \
    --port ${PORT}${NODEID} --rpc --rpcaddr ${RPCADDRESS} 
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
