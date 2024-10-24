#!/bin/sh

set -e;

if [ "$1" = "--debug" ];then
    shift 1;
    export ENABLE_DEBUG="true";
fi;

debug()
{
    if [ "${ENABLE_DEBUG}" == "true" ];then
        echo "Debug: $@";
    fi
}

source /config/.env

debug $(cat /config/.env)

if [ -z ${TLS_METHOD} ];then
	export TLS_METHOD=http;
fi

if [ "${TLS_METHOD}" != "http" ] && [ "${TLS_METHOD}" != "dns" ] && [ "${TLS_METHOD}" != "none" ];then
	echo "Unknown TLS_METHOD. Only supported http,dns and none.";
	exit 1;
fi;


if [ -n "${DOWNSTREAM_REGISTRY}" ] || [ -n "${DOWNSTREAM_AUTH}" ] || [ -n "${DOWNSTREAM_PRODUCTION}" ];then
	export DOWNSTREAM="";
	debug "Use user-defined domain.";
elif [ -n "${DOWNSTREAM}" ];then
    debug "Use auto-generated domain.";
	export DOWNSTREAM_REGISTRY=${DOWNSTREAM};
	export DOWNSTREAM_AUTH=auth.${DOWNSTREAM};
	export DOWNSTREAM_PRODUCTION=production.${DOWNSTREAM};
else
	if [ "${TLS_METHOD}" != "none" ];then
	    debug "Disable TLS";
		echo "You must set the DOWNSTEAM domain if you want to use Auto-https.";
		exit 1;
	fi;
fi;

# Using the Scheme to enforce the client's use of https.
# Using HTTP protocol in a public network is so dangerous.
export SCHEME="https"

# Check TLS_METHOD
if [ "${TLS_METHOD}" = "dns" ] && [ -z "${TLS_API_TOKEN}" ];then
	echo "You must set TLS_API_TOKEN if you want to use DNS-Challeng method."
	exit 1;
fi;

debug "TLS_METHOD=${TLS_METHOD}"
debug "DOWNSTREAM=${DOWNSTREAM}"
debug "DOWNSTREAM_REGISTRY=${DOWNSTREAM_REGISTRY}"
debug "DOWNSTREAM_AUTH=${DOWNSTREAM_AUTH}"
debug "DOWNSTREAM_PRODUCTION=${DOWNSTREAM_PRODUCTION}"
debug "TLS_API_TOKEN=${TLS_API_TOKEN}"

TLS_CONFIG_PATH=/caddy.tls.config

if [ "${TLS_METHOD}" = "http" ];then
    if [ -n "${TLS_EMAIL}" ];then
        cat<<HERE >> ${TLS_CONFIG_PATH}
tls ${TLS_EMAIL}
HERE
    else
        # do nothing
        :
    fi
elif [ "${TLS_METHOD}" = "dns" ];then
    cat<<HERE >> ${TLS_CONFIG_PATH};
tls {
    dns cloudflare {$TLS_API_TOKEN}
}
HERE
elif [ "${TLS_METHOD}" = "none" ];then
    cat<<HERE >> ${TLS_CONFIG_PATH}
auto_https off
HERE
fi

TLS_CONFIG=$(cat ${TLS_CONFIG_PATH})
rm -f ${TLS_CONFIG_PATH}

debug "TLS_CONFIG=${TLS_CONFIG}"
sed -i "s/__TLS_CONFIGURE/${TLS_CONFIG}/g" /etc/caddy/Caddyfile

# Export environments to make sure the caddy can read these environments
export UPSTREAM_REGISTRY
export DOWNSTREAM_REGISTRY
export UPSTREAM_PRODUCTION
export DOWNSTREAM_PRODUCTION
export UPSTREAM_AUTH
export DOWNSTREAM_AUTH
export SCHEME

# Start Caddy....
exec /usr/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile $@;
