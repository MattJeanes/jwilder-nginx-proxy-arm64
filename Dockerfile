FROM arm64v8/nginx:1.19.3
LABEL maintainer="Jason Wilder mail@jasonwilder.com, Matt Jeanes mattjeanes23@gmail.com"

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    wget \
    git \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*


# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf

# Install Forego
RUN wget --quiet https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-arm64.tgz && \
	tar xvf forego-stable-linux-arm64.tgz -C /usr/local/bin && \
	chmod u+x /usr/local/bin/forego

RUN wget --quiet https://github.com/MattJeanes/jwilder-nginx-proxy-arm64/releases/download/docker-gen-4edc190f/docker-gen-arm64.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-arm64.tar.gz \
 && rm /docker-gen-arm64.tar.gz


ENV NGINX_PROXY_VERSION "0.8.0"
RUN git clone --branch ${NGINX_PROXY_VERSION} https://github.com/jwilder/nginx-proxy.git /app


WORKDIR /app/

RUN cp network_internal.conf /etc/nginx/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]