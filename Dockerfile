FROM caddy:latest AS production
# http,none
# use none to disable auto https.
ENV TLS_METHOD="http"
ENV TLS_EMAIL=""

ENV UPSTREAM_REGISTRY="https://registry-1.docker.io"
ENV UPSTREAM_AUTH="https://auth.docker.io"
ENV UPSTREAM_PRODUCTION="https://production.cloudflare.docker.com"

# set up the downsteam domain, It should be your domain. without http or https scheme.
# e.g. example.org, example.com
ENV DOWNSTREAM=""
# if any value was be set in the below three environment variables,
# the DOWNSTREAM environment variable will be departeched.
ENV DOWNSTREAM_REGISTRY=""
ENV DOWNSTREAM_AUTH=""
ENV DOWNSTREAM_PRODUCTION=""

COPY Caddyfile /etc/caddy/Caddyfile
COPY entry.sh /entry.sh
RUN <<EOF
/bin/chmod +x /entry.sh
EOF
VOLUME /etc/caddy
VOLUME /data
VOLUME /config
EXPOSE 80 443

ENTRYPOINT ["/entry.sh"]
