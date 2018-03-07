#!/bin/sh

set -e

signal_handler() {
    # stop the appserver and adminserver
    echo "Stopping asbroker1 appserver"
    asbman -stop -name asbroker1
    echo "Stopping admin server"
    proadsv -stop

    # graceful shutdown so exit with 0
    exit 0
}
# trap SIGTERM and call the handler to cleanup processes
trap 'kill ${!}; signal_handler' SIGTERM SIGINT

# first start the admin server
echo "Starting admin server"
proadsv -start

# next start asbroker1
echo "Starting appserver"
asbman -start -name asbroker1

# wait for db to be serving 
# while true
# do
#   echo "Checking db status..."
#   proutil ${openedge_db} -C holder || dbstatus=$? && true
#   if [ ${dbstatus} -eq 16 ]
#   then
#     break
#   fi
#   sleep 1
# done
# # get db server pid 
# pid=`ps aux|grep '[_]aspro'|awk '{print $2}'`
# echo "Server running as pid: ${pid}"

# keep tailing log file until db server process exits
tail --pid=${pid} -f asbroker1.server.log & wait ${!}

# things didn't go well
exit 1
