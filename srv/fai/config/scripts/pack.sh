#!/bin/bash

# Create archives for each FAI class using $files/archives directory

# make sure we're in the right directory
cd /srv/fai/config/files/archives || exit 1

# check if running with sudo permissions
# need them to manipulate archive content ownerships
if [[ ! $(id -u) -eq 0 ]]; then echo "Use sudo to run this script."; exit 1; fi

echo -n "Removing old archives... "
find ./ -iname '*.tar' -exec rm {} \; && echo "Done."

# configure file permissions for target system
# save existing permissions
echo -n "Saving previous file permissions... "
getfacl -R . > fai_archives.acl && echo "Done."
	
# set new ones
#echo -n "Setting new file permissions for target filesystem... "
#chown -R root:root ./
#find ./ -type d -exec chmod 0755 {} \;
#find ./ -type f -exec chmod 0644 {} \;
#find ./ -iname '*.sh' -exec chmod 0755 {} \;
#find ./ -iname '*.py' -exec chmod 0755 {} \;
#echo "Done."

# use ls to print directories in the cwd
# then use sed to remove trailing slashes: CIP/ -> CIP
# "dir_list" contains then a cwd directories list
dir_list=$(ls -d */ | sed 's/\//''/g')

# iterate over classes in $files/archives
for class in $dir_list
do		
	echo -n "Creating new $class.tar... "
	# -C to change dir and . to use current (new) dir als source
	tar cf "$class.tar" -C "$class" . && echo "Done."
done

#echo -n "Restoring previous file permissions... "
#setfacl --restore=fai_archives.acl && echo "Done."

exit 0
