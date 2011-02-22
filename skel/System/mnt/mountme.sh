#!/bin/bash
# Script to sshfs mount dirs on remote systems
#
# It checks for a file called mnt.conf in this dir for mount info.
# If this file is nort found, it tries to mount the root filesystem of a remote
# machine with the same name as this local dir on the current local dir.
#
# The format of the mnt.conf file is a bash script that only contains the
# following variables (this file is sourced as a script):
#
# REMOTEHOST=hostname
# REMOTEDIR=/
#
# Both these variables are optional

# ### VARS ####
myDIR=$(realpath $(dirname $0))		# The path to this dir
conf="${myDIR}/mnt.conf"

# Do we have a config file?
if [ -r "$conf" ]; then
	source "$conf"
fi

# If we do not have a host form the config, we use the current dir name as host
REMOTEHOST=${REMOTEHOST:-$(basename "$myDIR")}

# If we do not have a remote dir name form the config, we use the remote root '/'
REMOTEDIR=${REMOTEDIR:-"/"}

# Mount it
sshfs -o nonempty -o uid=$(id -u) -o gid=$(id -g) ${REMOTEHOST}:${REMOTEDIR} "$myDIR"

