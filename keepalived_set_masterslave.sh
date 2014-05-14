#!/bin/bash

masterip=""

LOCAL_IP="$(ifconfig bond0 | grep -w inet | awk '{ print $2 }' | awk -F: '{ print $2 }')"
if [ "${LOCAL_IP}" == "localip" ]; then 
	REDIS_MASTER_IP="masterip";
elif [ "${LOCAL_IP}" == "localip" ];then
 	REDIS_MASTER_IP="masterip"
else
  echo "error"
  exit 1
fi

REDIS_PORT="6379"
REDIS_BIN_DIR="/usr/bin/"

chk_redis_alive () {
	alive=$(${REDIS_BIN_DIR}/redis-cli  -h 127.0.0.1 -p ${REDIS_PORT} ping)
	if [ "$alive" != "PONG" ]; then exit 1;fi
}

# parse argv moudle
for arg in "$@";do
        case $arg in
        -m) arg_m=true;;
        -s) arg_s=true;;
        *) exit 1;;
        esac
done

# log sub module 
log() {
 logger  -id "$*"
}

start_master() {
     for port in ${REDIS_PORT};do
         cmdsetmaster="${REDIS_BIN_DIR}/redis-cli -h "127.0.0.1" -p ${port} SLAVEOF no one"
         ${cmdsetmaster} >/dev/null ;
     done
}

start_slave() {
     for port in ${REDIS_PORT};do
        ${REDIS_BIN_DIR}/redis-cli -h "127.0.0.1" -p ${port}  SLAVEOF ${REDIS_MASTER_IP} ${port}
	[ $? -eq 0 ]&&log "Promoting redis-server to Slave on ${port} SUCESS" ||log "Promoting redis-server to Slave on ${port} Faild"
     done
}


if [ $arg_m ]; then
       # log "Promoting redis-server to MASTER"
        start_master
elif [ $arg_s ]; then
        #log "Promoting redis-server to SLAVE"
        start_slave
else
	log "some errors"
        exit 1
fi
