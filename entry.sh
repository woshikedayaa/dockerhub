#!/bin/sh

if [ -z ${TLS_METHOD} ];then
	${TLS_METHOD} = http;
fi

if [ ${TLS_METHOD} != http ] && [ ${TLS_METHOD} != dns ] && [ ${TLS_METHOD} != none ];then
	echo "Unknown TLS_METHOD. Only supported http,dns and none.";
	exit 1;
fi;


if [  -n ${DOWNSTREAM_REGISTRY} ] || [ -n ${DOWNSTREAM_AUTH} ] || [ -n ${DOWNSTREAM_PRODUCTION} ];then
	export DOWNSTREAM="";
else [ -n ${DOWNSTREAM} ];then
	export DOWNSTREAM_REGISTRY=${DOWNSTREAM};
	export DOWNSTREAM_AUTH=auth.${DOWNSTREAM};
	export DOWNSTREAM_PRODUCTION=production.${DOWNSTREAM};
else
	if [ ${TLS_METHOD} != none ];then
		echo "You must set the DOWNSTEAM domain if you want to use Auto-https.";
		exit 1;
	fi;
fi;
export SCHEME="https"

# Check TLS_METHOD
if [ ${TLS_METHOD} = dns ] && [ -z ${TLS_API_TOKEN} ];then
	echo "You must set TLS_API_TOKEN if you want to use DNS-Challeng method."
	exit 1;
fi;


# Start Caddy....
exec /usr/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile;
