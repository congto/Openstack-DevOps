#!/bin/bash
#author by keanlee on May 15th of 2017 
#wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

#useful
#echo -ne '[#####                     ](33%)\r'
#yum install tmux -y 1>/dev/null
#echo -ne '[#############             ](66%)\r'
#sleep 3
#echo -ne '[##########################](100%)\r'
#echo -ne '\n'


cd $(cd $(dirname $0); pwd)
source ./bin/common.sh

echo $GREEN This script will be deploy OpenStack on ${NO_COLOR}${YELLOW}$(cat /etc/redhat-release) $NO_COLOR

function help(){
cat 1>&2 <<__EOF__
$MAGENTA================================================================
            --------Usage as below ---------
             sh $0 controller
             sh $0 compute
             sh $0 network
             sh $0 check
             sh $0 controller-as-network-node
             sh $0 compute-as-network-node 
================================================================
$NO_COLOR
__EOF__
}

if [[ $# = 0 || $# -gt 1 ]]; then 
    which pv 1>/dev/null 2>&1 || rpm -ivh ./lib/pv* 1>/dev/null 2>&1
        debug "$?" "install pv failed "
    echo -e $CYAN $(cat ./README.txt) $NO_COLOR | pv -qL 30
    help
    exit 1
fi



#---------------compnment choose -----------
function support_service_common(){
yum_repos
initialize_env
ntp
dns_server
source ./bin/firewall.sh
}

function support_service_controller(){
rabbitmq_configuration
memcache
mysql_configuration
common_packages
}


case $1 in
controller)
    echo $BLUE Begin deploy controller on ${YELLOW}$(hostname)$NO_COLOR 
    support_service_common
    support_service_controller
    source ./bin/keystone.sh
    source ./bin/glance.sh
    source ./bin/nova.sh controller  
    source ./bin/neutron.sh controller 
    source ./bin/cinder.sh controller
    source ./bin/dashboard.sh
    ;;
compute)
    echo $BLUE Begin deploy compute on ${YELLOW}$(hostname)$NO_COLOR
    support_service_common
    source ./bin/nova.sh compute
    source ./bin/neutron.sh compute
    #source ./bin/cinder.sh  compute 
    ;;
network) 
    echo $BLUE Begin deploy network on ${YELLOW}$(hostname)$NO_COLOR
    support_service_common
    source ./bin/neutron.sh network
    ;;
controller-as-network-node)
    echo $BLUE Begin deploy controller as network node on ${YELLOW}$(hostname)$NO_COLOR
    support_service_common
    support_service_controller
    source ./bin/keystone.sh
    source ./bin/glance.sh
    source ./bin/nova.sh controller  
    source ./bin/neutron.sh controller-as-network-node
    source ./bin/cinder.sh controller
    source ./bin/dashboard.sh 
    #source ./bin/initial_network.sh
    ;;
compute-as-network-node)
    echo $BLUE Begin deploy compute as network node on ${YELLOW}$(hostname)$NO_COLOR
    support_service_common
    source ./bin/nova.sh compute
    source ./bin/neutron.sh compute
    source ./bin/neutron.sh compute-as-network-node
    #source ./bin/cinder.sh  compute 
    ;;
deploy-all-in-one)
    echo $BLUE Begin deploy compute as network node on ${YELLOW}$(hostname)$NO_COLOR
    support_service_common
    support_service_controller
    source ./bin/keystone.sh
    source ./bin/glance.sh
    source ./bin/nova.sh controller  
    ;;
check)
    source ./bin/system_info.sh
    ;;
*)
    help
    ;;
esac

