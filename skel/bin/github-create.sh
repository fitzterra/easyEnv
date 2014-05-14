#!/bin/bash
#
# Script to create a GitHub repo from the command line.
# Based on the code from here:
#  http://viget.com/extend/create-a-github-repo-from-the-command-line

repo_name=$1

dir_name=`basename $(pwd)`

if [ "$repo_name" = "" ]; then
	echo "Repo name (hit enter to use '$dir_name')?"
	read repo_name
fi

if [ "$repo_name" = "" ]; then
	repo_name=$dir_name
fi

username=`git config github.user`
if [ "$username" = "" ]; then
	echo "Could not find username, run 'git config --global github.user <username>'"
	invalid_credentials=1
fi 

# This seems to not be needed for the V3 GitHub API anymore
## token=`git config github.token`
## if [ "$token" = "" ]; then
## 	echo "Could not find token, run 'git config --global github.token <token>'"
## 	invalid_credentials=1
## fi

if [ "$invalid_credentials" == "1" ]; then
	exit 1
fi

echo -n "Creating Github repository '$repo_name' ..."
# As commented above about API v3
## curl -u "$username:$token" https://api.github.com/user/repos -d '{"name":"'$repo_name'"}' > /dev/null 2>&1
curl -u "$username" https://api.github.com/user/repos -d '{"name":"'$repo_name'"}'
echo " done."

echo -n "Pushing local code to remote ..."
git remote add origin git@github.com:$username/$repo_name.git > /dev/null 2>&1
git push -u origin master > /dev/null 2>&1
echo " done."

