FROM node:22

ARG S6_OVERLAY_VERSION=3.2.1.0
ARG Ngrok
ARG Password
ARG NGROK_DOMAIN
ENV Password=${Password}
ENV Ngrok=${Ngrok}
ENV NGROK_DOMAIN=${NGROK_DOMAIN}

RUN useradd -m -d /volume/devbox -s /bin/bash -G sudo devbox
RUN echo root:${Password}|chpasswd
RUN echo devbox:${Password}|chpasswd

# install ssh and other tools
RUN apt-get update && apt-get -y install
RUN apt-get install -y ssh wget unzip xz-utils

RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config 
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# start ssh to init the run directory
RUN service ssh start

# install ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip
RUN unzip ngrok.zip

# install bun
RUN npm install -g bun

# install s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

COPY etc/s6-overlay/ /etc/s6-overlay

ENTRYPOINT ["/init"]
