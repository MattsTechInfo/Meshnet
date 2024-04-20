FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy
LABEL maintainer="Matts Bos - MattsTechInfo"

# Configure the NordVPN client version to install at build
ARG NORDVPN_CLIENT_VERSION=3.17.4

# Avoid interactions during build process
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies, get the NordVPN Repo, install NordVPN client, cleanup and set executables
RUN echo "**** Get NordVPN Repo ****" && \
    curl https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb --output /tmp/nordvpnrepo.deb && \
    apt-get install -y /tmp/nordvpnrepo.deb && \
    apt-get update -y && \
    echo "**** Install NordVPN client ****" && \
    apt-get install -y nordvpn${NORDVPN_CLIENT_VERSION:+=$NORDVPN_CLIENT_VERSION} && \
    echo "**** Cleanup ****" && \
    apt-get remove -y nordvpn-release && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf \
		/tmp/* \
		/var/cache/apt/archives/* \
		/var/lib/apt/lists/* \
		/var/tmp/* && \
    echo "**** Finished software setup ****"

# Copy all the files we need in the container
COPY /fs /

# Make sure NordVPN service is running before logging in and launching Meshnet
ENV S6_CMD_WAIT_FOR_SERVICES=1
CMD nordvpn_login && meshnet_config && meshnet_watch