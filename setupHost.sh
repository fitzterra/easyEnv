#!/bin/bash
#
# This script sets up a new host with all the easyEnv settings.

##~~ Variables ~~##
MYDIR=$(dirname $0)

##~~ Functions ~~##
function setBashRcHook ()
{
	# This function appends the data in $HOOK to the end of the files in
	# $FILES. If the specific .bashrc already has the $SIG signature, it
	# is skipped and nothing is appended.
	
	##~~ Variables ~~##
	SIG='###-easyEnv:HOOK'
	HOOK=$(
cat <<__HOOK__

$SIG -- do not remove. added by $(basename $0)
# Source the local config changes file if it exists
[ -f ~/.bashrc_local ] && . ~/.bashrc_local

__HOOK__
)
	FILES="/etc/skel/.bashrc /root/.bashrc /home/*/.bashrc"
	
	# Update all files
	for f in $FILES; do
		# Ignore it if it does not exist
		[ ! -f "$f" ] && continue

		echo -n "Setting up: $f ..."
		if grep -q "$SIG" $f ; then
			echo "Already contains signature."
			continue
		fi
	
		echo "$HOOK" >> $f || exit 1
		echo " done."
	done
}

function makeDirColorsDB ()
{
	# This function creates a local dircolors database by replacing some color
	# values with easyEnv preferences.
	# The database is created as $DBPATH and will not be created if $DBPATH
	# already exists.
	
	##~~ Variables ~~##
	DBNAME=dircolors_db
	DBPATH="${MYDIR}/${DBNAME}"
	
	# Does it exist already?
	[ -f "$DBPATH" ] && echo "$DBPATH already exists. Aborting..." && exit 1
	
	# Call dircolors and do some substitutions and send output to $DBPATH
	dircolors --print-database | 
		sed "s/^DIR .*/DIR 01;37;44 # directory/" > $DBPATH
}

function setUserFiles ()
{
	# This function copies the files in $SOURCES to the all home dirs that
	# contain a .bashrc file, and also to /etc/skel and /root. It then sets the
	# ownership and permission to the same as for the .bashrc in the same dir.

	##~~ Variables ~~##
	FILES="_p_/.inputrc _p_/.bashrc_local _p_/.vim"
	SOURCES=${FILES//_p_/${MYDIR}/skel}
	BASHRCs="/etc/skel/.bashrc /root/.bashrc /home/*/.bashrc"

	for f in $BASHRCs; do
		# Ignore it if it does not exist
		[ ! -f "$f" ] && continue

		# Get the dir
		d=$(dirname $f)
		# Generate the destinations
		DESTS=${FILES//_p_/$d}

		echo -n "Copying files to: $d ..."

		# Copy them
		cp -iur $SOURCES ${d}/ || exit 1
		# Set ownership and permissions
		for n in $DESTS; do
			if [ -f $n ]; then
				# This is a file
				chown --reference $f $DESTS || exit 1
				chmod --reference $f $DESTS || exit 1
			else
				# This is a dir
				# A dir might have a .svn subdir... delete these
				find $n -type d -name ".svn" | xargs rm -rf
				find $n -type d | xargs chown --reference $d
				find $n -type d | xargs chmod --reference $d
				find $n -type f | xargs chown --reference $f
				find $n -type f | xargs chmod --reference $f
			fi
		done
	
		echo " done."
	done
}

function setSystemFiles ()
{
	# This function copies system wide config files into place.

	##~~ Variables ~~##
	FILES="_p_/bash_aliases _p_/bash.rclocal _p_/dircolors_db _p_/host_prompt_colors"
	SOURCES=${FILES//_p_/${MYDIR}}
	DESTS=${FILES//_p_//etc}

	echo -n "Copying system wide config files to: /etc ..."

	# Install them - easier than cp + chmod + chown
	install -g root -o root -m 0664 $SOURCES /etc || exit 1

	echo " done."
}

function setupVim ()
{
	# Installs local vim and gvim files

	##~~ Variables ~~##
	DEST=/etc/vim
	SDIR=${MYDIR}/vim


	# Do we have the destination?
	if [ ! -d "$DEST" ]; then
		echo "It does not look like vim is installed. Hit enter to install it now."
		read $ans
		aptitude install vim || exit 1
	fi
	
	# Install it
	echo "Installing [g]vim local files..."
	install -g root -o root -m 0664 ${SDIR}/* $DEST || exit 1

	echo " done."
}

##~~ MAIN ~~##

# Must be root
[ $(id -u) -ne 0 ] && echo "You must be root to run this script." && exit 1
	
# Set the hook into .bashrc for our local environment handlers
setBashRcHook

# Create the local dircolors db if it does not already exist
[ ! -f "${MYDIR}/dircolors_db" ] && makeDirColorsDB 

# Copy local env files
setUserFiles

# Copy system env files
setSystemFiles 

# Do vim
setupVim 


