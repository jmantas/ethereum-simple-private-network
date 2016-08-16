#!/bin/sh


export RUST_BACKTRACE=1
export RUST_LOG=debug

NETID=88888
NETIDHEX=`printf %x ${NETID}`
DATAROOT=~/eth-data-dir-${NETID}
PORT=177
RPCPORT=188
PPROFPORT=606
DAPPSPORT=199
RPCADDRESS=127.0.0.1

GETH=`which geth`
GETHVERSION=`${GETH} version`
PARITY=`which parity`
PARITYVERSION=`${PARITY} --version`
CP=`which cp`
SED=`which sed`




checkDir() {

    NODEID=$1
    if [ ! -d "${DATAROOT}/${NODEID}" ] && [ $2 = '4init' ]
    then
    
        echo ""
        echo "Creating data diractory ${DATAROOT}/${NODEID}"
        echo ""

        mkdir -p ${DATAROOT}/${NODEID}
    
    elif [ ! -d "${DATAROOT}/${NODEID}" ] && [ $2 = '4bootup' ]
    then

        echo ""
        echo "Node does not exists. Need to run: ./eth-spn.sh initgeth $1"
        echo ""
    
        exit 1

    elif [ -d "${DATAROOT}/${NODEID}" ] && [ $2 = '4init' ]
    then

        echo ""
        echo "Node already exists, no need to initialize"
        echo ""

        exit 1

    fi

}

initNodeGeth() {
    
    NODEID=$1
    checkDir ${NODEID} 4init
    
    echo ""
    echo "Initializing GETH node $1 with private genesis block"
    
    echo ""
    echo "Creating new account"
    echo ""
    ${GETH} --datadir=${DATAROOT}/${NODEID} \
    --networkid ${NETID} --verbosity 6 account new 

    echo ""
    echo "Importing genesis block and starting initial node"
    echo ""
    ${GETH} --nat none --nodiscover \
    --datadir=${DATAROOT}/${NODEID} --networkid ${NETID} --verbosity 6 \
    init ./genesis-private-geth.json 

}


generateParityGenesisJSON() {

    ${CP} -p ./genesis-private-parity-null.json ./genesis-private-parity-${NETID}.json
    ${SED} -i -e "s/REPLACEMEWITHCORRECTNETIDINHEX/${NETIDHEX}/g" ./genesis-private-parity-${NETID}.json

}


initNodeParity() {

 
    NODEID=$1
    checkDir ${NODEID} 4init
    
    echo ""
    echo "Initializing PARITY node $1 with private genesis block"
    echo ""
    echo "Creating new account, importing genesis block"
    echo ""
    
    ${PARITY} --db-path ${DATAROOT}/${NODEID} --keys-path ${DATAROOT}/${NODEID}/keys \
    --dapps-path ${DATAROOT}/${NODEID}/dapps --signer-path ${DATAROOT}/${NODEID}/signer \
    --network-id ${NETID} --logging debug --chain ./genesis-private-parity-${NETID}.json account new  


}



bootupNodeParity() {

    NODEID=$1
    checkDir ${NODEID} 4bootup
    
    echo ""
    echo "Booting up PARITY node $1 ..."
    echo ""
    
    ${PARITY} --db-path ${DATAROOT}/${NODEID} --keys-path ${DATAROOT}/${NODEID}/keys \
    --dapps-path ${DATAROOT}/${NODEID}/dapps --signer-path ${DATAROOT}/${NODEID}/signer \
    --network-id ${NETIDHEX} --nat none --no-discovery \
    --chain ./genesis-private-parity-${NETID}.json \
    --ipc-path ${DATAROOT}/${NODEID}/jsonrpc${NETID}.ipc \
    --port ${PORT}${NODEID} --jsonrpc-port ${RPCPORT}${NODEID} 
    
}


bootupNodeGeth() {
    NODEID=$1
    checkDir ${NODEID} 4bootup
    
    echo ""
    echo "Booting up GETH node $1 ..."
    echo ""
   ${GETH} --datadir ${DATAROOT}/${NODEID} \
    --nat none --nodiscover --networkid ${NETID} \
    --verbosity 6 \
    --pprof --pprofport ${PPROFPORT}${NODEID} \
    --port ${PORT}${NODEID} --rpc --rpcaddr ${RPCADDRESS} --rpcport ${RPCPORT}${NODEID} \
    --mine --minerthreads 1 --extradata "Mined by node:"$1 \
    --shh console 2>> ${DATAROOT}/${NODEID}.log
}



case "$1" in
        initgeth)
        initNodeGeth $2
        ;;
        initparity)
        generateParityGenesisJSON
        initNodeParity $2
        ;;
        upgeth)
        bootupNodeGeth $2
        ;;
        upparity)
        bootupNodeParity $2
        ;;
        *)
        echo "Usage: $0 [ initgeth | upgeth ] [ initparity | upparity ] [ < node id > ]"
RETVAL=$?
esac
exit 0
