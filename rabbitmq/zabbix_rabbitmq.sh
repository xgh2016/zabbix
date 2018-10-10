#!/bin/bash
RMQ_HOME=/opt/appl/rabbitmq/rmq
PATH=$PATH:$HOME/bin:$RMQ_HOME/sbin
ERLANG_HOME=/usr/local/erlang
PATH=$PATH:$ERLANG_HOME/bin
export PATH

RMQ_COMMAND=$1
QUEUE=$2   
function list_queues_status {
       /opt/appl/olrmq/rabbitmq/sbin/rabbitmqctl list_queues |grep  "$QUEUE"|grep -v List |awk '{print $2}'
}
  
function list_queues {
       /opt/appl/olrmq/rabbitmq/sbin/rabbitmqctl list_queues |grep -v List |wc -l
         }
  
function list_consumers {
       /opt/appl/olrmq/rabbitmq/sbin/rabbitmqctl list_consumers |grep -v List |wc -l
}

function list_channels_state {
       /opt/appl/olrmq/rabbitmq/sbin/rabbitmqctl list_channels state |grep -v List |wc -l
}
  
function list_connections_state {
        /opt/appl/olrmq/rabbitmq/sbin/rabbitmqctl list_connections state |grep -v List |wc -l
}
function list_connections_name {
        /opt/appl/olrmq/rabbitmq/sbin/rabbitmqctl list_connections name state |grep -v List |wc -l
}
function disk_free {
        /opt/appl/olrmq/rabbitmq/sbin/rabbitmqctl status|grep -A1 disk |grep "disk_free,"|awk -F [{,\}] '{print $3/1024/1024/1024}'|awk '{print int($1+0.5)}'
}

function memory_free {
         limt=`/opt/appl/olrmq/rabbitmq/sbin/rabbitmqctl status|grep -A1 memory |grep "vm_memory_limit"|awk -F [{,\}] '{print $3}'`
	 free=`/opt/appl/olrmq/rabbitmq/sbin/rabbitmqctl status|grep -A1 memory |grep "total,"|awk -F [{,\}] '{print $3}'`
	 echo "$free $limt"|awk '{printf("%0.2f\n",$1/$2*100)}'
#	 echo 100 
}

function health_check {
        /opt/appl/olrmq/rabbitmq/sbin/rabbitmqctl node_health_check 2>&1 |grep "Health check passed" 2>&1 >/dev/null
	if [ $? -ne 0 ];then
	echo "1"
	else
	echo "0"
	fi
}

case $RMQ_COMMAND in
    ram_status)
        list_queues_status ;;
    check_queues)
        list_queues ;;
    check_consumers)
        list_consumers ;;
    check_channels)
        list_channels_state ;;
    check_connections)
        list_connections_name ;;
    check_disk) 
        disk_free ;;
    check_memory)
        memory_free ;;
    check_health)
        health_check ;;
    *)
    echo -e "Usage: $0 [ram_status key| check_queues|check_consumers |check_channels |check_connections|check_disk|check_memory|check_health] "
esac
