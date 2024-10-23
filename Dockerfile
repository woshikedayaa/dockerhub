FROM caddy:builder as builder
# Build with cloudflare DNS plugin

RUN xcaddy build --with github.com/caddy-dns/cloudflare

FROM caddy:latest
WORKDIR /app
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# http,dns,none
# use none to disable auto https.
ENV TLS_METHOD="http"
ENV TLS_EMAIL=""
ENV TLS_API_TOKEN=""
ENV UPSTREAM_REGISTRY="https://registry-1.docker.io"
ENV UPSTREAM_AUTH="https://auth.docker.io"
ENV UPSTREAM_PRODUCTION="https://production.cloudflare.docker.com"
# set up the downsteam domain, It should be your domain. without http or https scheme.
# e.g. example.org, example.com
ENV DOWNSTREAM=""
# if any value was be set in the below three environment variables, the DOWNSTREAM environment variable will be departeched.
ENV DOWNSTREAM_REGISTRY=""
ENV DOWNSTREAM_AUTH=""
ENV DOWNSTREAM_PRODUCTION=""

ENV LISTEN_ADDRESS=""

COPY Caddyfile /etc/caddy/Caddyfile

VOLUME /etc/caddy/Caddy

EXPOSE 80 443

CMD ["entry.sh"]
