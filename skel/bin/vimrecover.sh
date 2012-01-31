#!/bin/bash

# Shell script to find and recover files in the current dir tree that were
# edited by (g)vim but where vim did not exit clenaly. This leaves swap files
# that may still contain changes that were not written to the original file.
# Swap files that contain no new changes are automatically deleted.

# Name of temp file to use for recovering a swap file
TMPF=/tmp/vimrecovery

# Find all vim type swap files in the current dir tree
for f in $(find . -name ".*.sw?"); do
	# Split the name in dir and file name
	DIRNAME=$(dirname $f)
	FNAME=$(basename $f)
	# Find the original file name from FNAME
	OFNAME=$(sed 's/^\.\(.*\)\.sw.$/\1/' <<< $FNAME)
	origf="${DIRNAME}/${OFNAME}"
	# Sanity check
	[ ! -f "$origf" ] && echo "No original file found for swap file [${f}]." && exit 1

	#echo "$DIRNAME  --  $FNAME  -- $OFNAME"
	echo "Swap file found for [${origf}] ..."

	# Recover it using VIM and write it to a temp file
	vim -r "$f" -c "wq! $TMPF" || exit 1
	# Sanity check
	[ ! -f "$TMPF" ] && echo "Expected recovery file to exists after VIM recory: [${TMPF}]." && exit 1

	# Compare the temp file and the original
	if cmp --quiet "$origf" "$TMPF" ; then
		# All is well and we can delete the swap file
		echo "Deleting swap file [${f}] ..."
		rm -f "$f" || exit 1
	else
		# The files differ, so show the diffs with the original on the left
		vimdiff -n "$origf" "$TMPF"
		# Are the two files the same now?
		if cmp --quiet "$origf" "$TMPF" ; then
			# All is well and we can delete the swap file
			echo "Deleting swap file [${f}] ..."
			rm -f "$f" || exit 1
		else
			echo "Files still differ. Leaving swap file [${f}] in place."
		fi
	fi

	# Clean up the temp file
	rm -f "$TMPF"
done
