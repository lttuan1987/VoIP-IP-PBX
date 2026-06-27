# vim:set ft=dockerfile:
ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION} AS build

ARG DEBIAN_VERSION

# Add signalwire-freeswitch-repo
RUN apt-get -qq update \
    && apt-get install -y \
    git build-essential cmake autoconf automake libtool pkg-config  \
    libssl-dev \
    zlib1g-dev \
    libdb-dev \
    unixodbc-dev \
    libncurses5-dev \
    libexpat1-dev \
    libgnutls28-dev \
    libtiff5-dev \
    uuid-dev \
    libpcre3-dev \
    libedit-dev \
    libsqlite3-dev \
    libcurl4-openssl-dev \
    nasm \
    yasm \
    libogg-dev \
    libvorbis-dev \
    libperl-dev \
    libgdbm-dev \
    libdb-dev \
    python3-dev \
    liblua5.2-dev \
    libtpl-dev \
    libtiff5-dev \
    libopus-dev \
    libspeex-dev \
    libspeexdsp-dev \
    libldns-dev \
    libedit-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge -y --auto-remove \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create working directory
RUN mkdir -p /usr/local/src

WORKDIR /usr/local/src

RUN --mount=type=secret,id=GITHUB_TOKEN,required \
    GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) \
    && git clone https://${GITHUB_TOKEN}@github.com/freeswitch/sofia-sip \
    && git clone https://${GITHUB_TOKEN}@github.com/freeswitch/spandsp \
    && git clone https://${GITHUB_TOKEN}@github.com/signalwire/freeswitch.git \
    && git clone --branch debug/audio-model-crash https://${GITHUB_TOKEN}@github.com/halomelabs/freeswitch-mod-apn.git

# Copy mod_apn to freeswitch source
RUN cp -a freeswitch-mod-apn/mod_apn freeswitch/src/mod/endpoints/

# Build sofia-sip
WORKDIR /usr/local/src/sofia-sip

RUN ./bootstrap.sh
RUN ./configure
RUN make && make install

# Build spandsp
WORKDIR /usr/local/src/spandsp

RUN ./bootstrap.sh
RUN ./configure
RUN make && make install

WORKDIR /usr/local/src/freeswitch

RUN ./bootstrap.sh

# Start building
# IMPORTANT: ONLY BUILD mod_apn
RUN echo 'endpoints/mod_apn' > modules.conf
RUN sed -i '/src\/mod\/endpoints\/mod_sofia\/Makefile/a src\/mod\/endpoints\/mod_apn\/Makefile' configure.ac
RUN ./configure
RUN make && make install

# Create output directory to copy files out
RUN mkdir -p /output

RUN cp -r /usr/local/freeswitch/mod/mod_apn.so /output

RUN ls /output

ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION} AS runtime

# ARGs are cleared after every FROM
# see: https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG DEBIAN_VERSION
# ARG TOKEN # Old way to pass the token, now using secrets

# By default, install the full set of FreeSWITCH packages.  Specify an alternative with:
#   --build-arg="FS_META_PACKAGE=freeswitch-meta-vanilla"
# alternatives include:
#   freeswitch-meta-bare
#   freeswitch-meta-vanilla
#   freeswitch-meta-sorbet
#   freeswitch-meta-all-dbg
ARG FS_META_PACKAGE=freeswitch-meta-all

# Source Dockerfile:
# https://github.com/docker-library/postgres/blob/master/9.4/Dockerfile

# explicitly set user/group IDs
ARG FREESWITCH_UID=499
ARG FREESWITCH_GID=499
RUN groupadd -r freeswitch --gid=${FREESWITCH_GID} && useradd -r -g freeswitch --uid=${FREESWITCH_UID} freeswitch

# make the "en_US.UTF-8" locale so freeswitch will be utf-8 enabled by default
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends ca-certificates gnupg2 gosu locales wget sngrep bash inetutils-ping \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8

# https://freeswitch.org/confluence/display/FREESWITCH/Debian
# https://developer.signalwire.com/freeswitch/FreeSWITCH-Explained/Installation/Linux/Debian_67240088/

RUN --mount=type=secret,id=SIGNALWIRE_TOKEN \
    wget --no-verbose --http-user=signalwire --http-password=$(cat /run/secrets/SIGNALWIRE_TOKEN) \
      -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg \
      https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg \
    && echo "machine freeswitch.signalwire.com login signalwire password $(cat /run/secrets/SIGNALWIRE_TOKEN)" > /etc/apt/auth.conf \
    && echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ ${DEBIAN_VERSION} main" > /etc/apt/sources.list.d/freeswitch.list \
    && apt-get -qq update \
    && apt-get install -y ${FS_META_PACKAGE} \
    && apt-get purge -y --auto-remove \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /
# Add anything else here

## Ports
# Document ports used by this container
### 8021 fs_cli, 5060 5061 5080 5081 sip and sips, 5066 ws, 7443 wss, 8081 8082 verto, 16384-32768, 64535-65535 rtp
EXPOSE 8021/tcp
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
EXPOSE 5061/tcp 5061/udp 5081/tcp 5081/udp
EXPOSE 5066/tcp
EXPOSE 7443/tcp
EXPOSE 8081/tcp 8082/tcp
EXPOSE 64535-65535/udp
EXPOSE 16384-32768/udp

# Volumes
## Freeswitch Configuration
VOLUME ["/etc/freeswitch"]
VOLUME ["/var/log/freeswitch"]
## Tmp so we can get core dumps out
VOLUME ["/tmp"]

# Limits Configuration
COPY  build/freeswitch.limits.conf /etc/security/limits.d/

# Copy mod_apn from build pharse
COPY --from=build /output/* /usr/lib/freeswitch/mod/

RUN ls /usr/lib/freeswitch/mod/

# Healthcheck to make sure the service is running
SHELL       ["/bin/bash", "-c"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD  fs_cli -x status | grep -q ^UP || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["freeswitch"]
