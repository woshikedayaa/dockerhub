# dockerhub
dockerhub reverser proxy image.

# Usage
## Build image.
```bash
$ git clone https://github.com/woshikedayaa/dockerhub.git --depth=1 --branch=main
$ cd dockerhub
$ docker build -t dockerhub:latest -f Dockerfile .
```

## Setup three DNS recode to your docker server
In the demo. We will use example.com to show you how to setup the DNS recode.
### Your need to add three DNS recode.
```text
A/AAAA  example.com -> $YOUR_IP_ADDRESS // $YOUR_DOMAIN
CNAME   auth.example.com -> example.com // $YOUR_AUTH_DOMAIN
CNAME   production.example.com -> example.com // $YOUR_PRODUCTION_DOMAIN
```
In the next steps, you  need to replace to $YOUR_DOMAIN
## Quick Start.
```bash
$ docker run -d --name=dockerhub-reverse-proxy \
-p 443:443 -p 80:80 \
-e DOWNSTREAM=$YOUR_DOMAIN \
-v ${HOME}/caddy-data:/data \
dockerhub:latest
```
If your 443 and 80 ports are already occupied and you cannot apply for an automatic HTTPS certificate,
you can use the built-in Cloudflare DNS to apply for a HTTPS certificate
(only supports Cloudflare DNS, you can modify the Dockerfile if you need others).
```bash
$ echo "TLS_API_TOKEN=$YOUR_TOKEN" >> /path/to/.env
# /path/to/.env should be a regular file

$ docker run -d --name=dockerhub-reverse-proxy \
-p HTTPS_PORT:443 -p HTTP_PORT:80 \
-e DOWNSTREAM=$YOUR_DOMAIN \
-e TLS_METHOD=dns  \
-v ${HOME}/caddy-data:/data \
-v /path/to/.env:/config/.env \
dockerhub:latest
```

## Advance
### Use your own configured domain name instead of an automatically generated one.
In the Dockerfile
```Dockerfile
# set up the downsteam domain, It should be your domain. without http or https schemes.
# e.g. example.org, example.com
ENV DOWNSTREAM=""
# if any value was be set in the below three environment variables,
# the DOWNSTREAM environment variable will be departeched.
ENV DOWNSTREAM_REGISTRY=""
ENV DOWNSTREAM_AUTH=""
ENV DOWNSTREAM_PRODUCTION=""
```
If you want to configure your domain name in this way,
you need to fill in all three environment variables.
```Dockerfile
ENV DOWNSTREAM_REGISTRY=""
ENV DOWNSTREAM_AUTH=""
ENV DOWNSTREAM_PRODUCTION=""
```
```bash
$ docker run -d --name=dockerhub-reverse-proxy \
-p 443:443 -p 80:80 \
-e DOWNSTREAM_REGISTRY="$YOUR_REGISTRY_DOMAIN" \
-e DOWNSTREAM_AUTH="$YOUR_AUTH_DOMAIN" \
-e DOWNSTREAM_PRODUCTION="$YOUR_PRODUCTION_DOMAIN" \
-v ${HOME}/caddy-data:/data \
-v /path/to/.env:/config/.env \
dockerhub:latest
```
### Custom Dockerhub upstream.
It is useful when you reach the dockerhub rate limit and deploy a dockerhub-reverse-proxy cloudflare worker
```bash
-p 443:443 -p 80:80 \
-e DOWNSTREAM="$YOUR_DMIAN" \
-e UPSTREAM_REGISTRY="$UPSTREAM_REGISTRY_DOMAIN_WITH_HTTPS_SCHEME" \
-e UPSTREAM_AUTH="$UPSTREAM_AUTH_DOMAIN_WITH_HTTPS_SCHEME" \
-e UPSTREAM_PRODUCTION="$UPSTREAM_PRODUCTION_DOMAIN_WITH_HTTPS_SCHEME" \
-v ${HOME}/caddy-data:/data \
-v /path/to/.env:/config/.env \
dockerhub:latest
```
# Contribute
If you find any issues or have suggestions for improvements, please open an issue or pull request.
