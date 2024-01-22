# Meshnet
[![Discord](https://img.shields.io/discord/1013430695860908062?logo=discord&label=Discord&color=7289DA&logoColor=FFFFFF&style=for-the-badge)](https://discord.gg/v8Bwbnb3xe)

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/MattsTechInfo/Meshnet?style=for-the-badge)](https://github.com/MattsTechInfo/Meshnet/releases) 
[![GitHub](https://img.shields.io/github/license/MattsTechInfo/Meshnet?style=for-the-badge)](https://github.com/MattsTechInfo/Meshnet/blob/master/LICENSE) 
![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/MattsTechInfo/Meshnet/docker-image.yml?style=for-the-badge)

This (Docker) container provides the official NordVPN client configured for Meshnet VPN usage. Easily deploy fully configurable Meshnet nodes that automatically join your Meshnet network. This project is in not a supported/official container image by NordVPN and is in no way endorsed by the company NordVPN.

> Note: I've created this container for my personal needs, which is to run Meshnet nodes at different locations to be used as outgoing gateways. If you have another use for this container, feel free to let me know or help add functionality if what you are trying to do doesn't work as expected. 

## General Meshnet information
Meshnet is a free self hosted VPN network connecting multiple nodes together. It's functionality, provided with the NordVPN application, is available on most platforms, including Android/Google TV. This could potentially make for an excellent Netflix password sharing workaround and viewing your own country's content when abroad, but obviously I would never recommend to do anything against the rules now would I.
Read more about Meshnet over here: https://meshnet.nordvpn.com/

## Installation and configuration
Deploying this container is quite easy as it does not require specific ports to function as a gateway node, initial traffic is outgoing. Other uses may require different configurations.

### Preparations
A (free) NordVPN is required to enable Meshnet and use the services.
This container requires an `Access token` to log on the NordVPN client. Follow the following steps to generate a new `Access token`:
- Login to https://my.nordaccount.com/
- Scroll down to "NordVPN Meshnet Free"
- Click "View details"
- Scroll down to "Manual setup"
- Press the "Setup NordVPN manually" button
- Enter the verification code from e-mail
- Scroll down to "Access token"
- Press the "Generate new token" button
- Set the desired time to live

### iptables requirement
The NordVPN client makes use of iptables to route and block traffic. The underlying host OS is required to have iptables libraries installed before this container can enable Meshnet. Next to the default iptables functionality, it also requires several iptables modules.

### Environment variables
A `.env` file is supplied with the `docker-compose.yml` file for configuration purposes, this file already contains quite some commentary. A `configMap` is supplied for Kubernetes deployments.

#### General config
- `NORDVPN_TOKEN` - Supply your `Access token` to be able to login. If you want to use a file or secret instead, please leave this ENV blank or comment it out.
- `NORDVPN_TOKENFILE` - Load the `Access token` from a file mounted in the container. Make sure nothing else but the token is inside. Please leave this blank if you are using `NORDVPN_TOKEN` or comment it out.
- `NORDVPN_MESHNET_DEBUG` - Enable debug mode, anything non-empty will ENABLE. Use this if you need more verbose error logging for troubleshooting.
- `NORDVPN_HEALTHCHECK_INTERVAL` - Set the interval to verify connectivity to the set URL, defaults to 300 (seconds).
- `NORDVPN_HEALTHCHECK_URL` - An address to verify if connectivity is available. Choose something depending on what connectivity you want to verify, defaults to www.google.com. Please keep in mind, if the healthcheck fails the container will be killed.

#### Meshnet Permissions
In this version of NordVPN, permissions must be configured directly on the client. NordVPN currently ALLOWS all peers connected to Meshnet by default for Fileshare and Remote access services and DENIES Routing and Local network services. Configuring peer permissions through the NordVPN account website is still in development and not currently available.

This container will run DENY configuration first, followed by ALLOW. ALLOW will overwrite the DENY! Entering a peer in both DENY and ALLOW will first DENY the peer and then overwrite it with an ALLOW.

Peers must be entered with their FQDN/Name assigned by Meshnet, comma separated, example: `peer-atlas.nord,peer-fuji.nord`

- `NORDVPN_DENY_PEER_ROUTING` - Block peers from using this node as a router.
- `NORDVPN_DENY_PEER_LOCAL` - Block peers from accessing the local network of this node.
- `NORDVPN_DENY_PEER_FILESHARE` - Block peers from sharing files with this node.
- `NORDVPN_DENY_PEER_REMOTE` - Block peers from remote access to this node.


- `NORDVPN_ALLOW_PEER_ROUTING` - Allow peers to use this node as a router.
- `NORDVPN_ALLOW_PEER_LOCAL` - Allow peers to access the local network of this node (ROUTING permissions required!).
- `NORDVPN_ALLOW_PEER_FILESHARE` - Allow peers to  sharing files with this node.
- `NORDVPN_ALLOW_PEER_REMOTE` = Allow peers to use remote access on this node.

### Deployment - docker-compose
An example `docker-compose.yml` has been supplied to easily deploy the Meshnet node. There is one specific piece of configuration, which is the `hostname`. Without configuring a `hostname`, every restart of the container will show as a new node within the Meshnet. Having a `hostname` configured will make sure the node is remembered/recognized.

NordVPN and Meshnet functionality require permissions to create a tunnel interface within the container. The container will require both capabilities `NET_ADMIN` and `NET_RAW`.

Make sure you have the `.env` file next to the `docker-compose.yml` and run `docker-compose up -d` to start the container. The node/peer should show up in your Meshnet within a few seconds.

### Deployment - Kubernetes
Kubernetes examples are supplied to easily deploy the Meshnet node on a Kubernetes cluster. There are two files, `meshnet-deployment.yaml` and `meshnet-env.yaml`. In the `meshnet-deployment.yaml`, please make sure the `hostname` is not empty. Without configuring a `hostname`, every restart of the container will show as a new node within the Meshnet. Having a `hostname` configured will make sure the node is remembered/recognized.

NordVPN and Meshnet functionality require permissions to create a tunnel interface within the container. The container will require both capabilities `NET_ADMIN` and `NET_RAW`.

Make sure you have the `meshnet-env.yaml` file configured and run `kubectl apply -f <meshnet_folder> -n <namespace>` to start the container. The node/peer should show up in your Meshnet within a few seconds.

## ARM64
Next to the default AMD64 platform this container is also built for ARM64. This will allow for easy deployment on Ampere based K8s nodes or VM's in, for example, the Free-Tier Oracle Cloud Infrastructure. At this moment, specific OKE images seem to miss some iptables modules, running `sudo modprobe iptable_filter` on your worker nodes will fix this.

## Synology
A few users have had some problems with certain Synology devices as these do not come with the correct iptables modules, a manual will be added to the documentation when I have time to do this. For now, please join the Discord as the solution is posted to the support channel there.

## Credits
Starting this image has been based on the excellent work of https://github.com/bubuntux/nordvpn with their NordVPN client implementation in Docker.
