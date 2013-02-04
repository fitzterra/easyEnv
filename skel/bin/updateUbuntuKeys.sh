#!/bin/bash

# Shell script to find any missing public keys from an Ubuntu type host (usually
# after a new PPA was added via approx) and get them from the Ubuntu key server.

# Do a repo update and dump errors to a temp file
sudo aptitude update 2>/tmp/NO_PUBKEY

# Find any missing pub keys
MK=$(grep NO_PUBKEY /tmp/NO_PUBKEY | awk '{print $NF;}' | sort | uniq)

if [ -n "$MK" ]; then
	for k in "$MK"; do
		echo "Adding missing public keys for signature: $k"
		echo
		sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $k
	done
fi

sudo rm -f /tmp/NO_PUBKEY

