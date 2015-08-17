#!/bin/bash

# TODO: paths -----
SEQ=/usr/bin/seq
PING=/bin/ping
SLEEP=/bin/sleep
IPSEC=/etc/init.d/ipsec
LOGGER=/usr/bin/logger

# Consts -----
LOGGER_PRIORITY="daemon.notice"
PROC_NAME="ipsec-mon"
DST_IP=10.66.20.5
DELAY=120
declare -i RETRIES=10 

# Auxiliary functions -----

ipsec_stop() {
	${IPSEC} stop
}

ipsec_start() {
	${IPSEC} start
}

ipsec_restart() {
	${IPSEC} restart
}

syslog() {	
	MESG=$1
	${LOGGER} -p ${LOGGER_PRIORITY} -t ${PROC_NAME} ${MESG}
}

ping() {
	ip=$1
	${PING} -W 1 -c 3 ${ip} > /dev/null; v=$?
	return $v
}

wait() {
	${SLEEP} ${DELAY}
}

ip_check() {
 	declare -i failures=0
	for i in $(${SEQ} 1 ${RETRIES}); do
  		ping ${DST_IP}; status=$?
		if [ ${status} -ne 0 ]; then
			failures=$failures+1
		fi
		wait
	done
	if [ ${failures} -ge ${RETRIES} ]; then
		v=1
	fi
 	return $v
}

keep_running() {
	syslog "checking ipsec health"
	ip_check; status=$?
	if [ ${status} -ne 0 ]; then
		syslog "ipsec has failed, restarting!"
		ipsec_restart
	fi
}

# Main -----
main() {
	keep_running 
}



# Calling main -----
main
