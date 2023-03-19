#!/bin/bash

# Script to generate partial local MIRROR which we use for client installation

# File to save fai-mirror process ID in
pidfile="/var/run/fai-mirror.pid"

# Path to symlink to this script
script="/usr/local/bin/mirror"

# Path to fai-mirror configuration directory
# this directory resembles /etc/fai structure and contains sources.list file
# which is used to create mirror
conf="/etc/fai" # "/etc/fai/mirror"

# Path to the server directory where the mirror will be located
mirror="/opt/mirror/ubuntu"

# FAI classes, which package lists are used to create mirror package list
classes="AMD64,DEFAULT,GRUB_PC,EFI,FAIBASE_EFI,BASE-JAMMY,AFS,CIP,APPS,JULIA-PKGS,CLUSTER"
#classes="AMD64,DEFAULT,GRUB_PC,FAIBASE,BIONIC,CIPMIN,CIP"

# Mirroring log file
log="/var/log/fai/mirror.log"

# Get CLI arguments
key="$1"

# generate help message
read -d '' help << EOF
----------------------------------------------------------------------

USAGE: sudo mirror [-c or --cron] OR [-h or --help]

Please use sudo to run this script.
	
Execute script without options to generate a new FAI mirror.
			
Configure crontab to execute this script automatically: sudo mirror -c

Show this help message and exit:                        sudo mirror -h

----------------------------------------------------------------------
EOF

# Check access rights
if [[ $USER != "root" ]]; then
	printf "\nUse sudo to run this script.\n\n"
	exit 1
fi

# Parse command-line options
case "$key" in
	-c|--c|-cron|--cron)
		# Configure cron to execute this script automatically
		# check if line exists and append it, if not
		if grep -q "$script" /etc/crontab; then
			printf "\nExisting crontab entry found.\n\n"
		else
			printf "\nAdding new crontab entry... "
			echo -e "\n# create partial Ubuntu mirror\n00 20   * * *   root    $script" >> /etc/crontab
			printf "Done.\n\n"
		fi
		exit 0
	;;
	-h|--help)
		echo -e "$help\n" && exit 0	# show help message and exit
	;;
esac

# Check running processes
if [[ -s $pidfile ]]; then
	PID=$(<$pidfile)
	if ps -p $PID &> /dev/null; then
		printf "\nMirroring process with PID %s is already running.\n\n" "$PID"
		exit 1
	else
		printf "\nPIDFile %s exists, but no processes with PID %s found.\n" "$pidfile" "$PID"
		printf "\nRemove this file and proceed? ( y | n | abort ): "
		read RMPIDFILE
		case $RMPIDFILE in
			y|Y|yes|Yes)
				rm "$pidfile" || exit 1
			;;
			*)
				printf "\nOk, bye\n\n"
				exit 1
			;;
		esac
	fi
fi

# Remove previous mirror
if [[ -d $mirror ]]; then
	printf "\nRemoving previous mirror..."
	if rm -r "$mirror"; then
		printf " Done.\n"
	else
		printf "\nCouldn't remove mirror!\n"
	fi
else
	printf "\nNo previous mirror found, proceeding.\n"
fi


#-------------------------------------------------------------------
# Execute mirroring script with given options and save process ID
#
# Check if reprepro installed
if ! dpkg -l | grep reprepro &> /dev/null; then
	printf "\nPackage 'reprepro' not found, but fai-mirror depends on it. Install it now? (y | n | abort) "
	read REPREPRO
	case $REPREPRO in
		y|Y|yes|Yes)
			apt-get install -y reprepro
			;;
		*)
			printf "\nBye\n"
			exit 0
			;;
	esac
fi


# Update package lists
apt-get update || exit 1

# Start fai-mirror
nohup fai-mirror -b -C "$conf" -c"$classes" "$mirror" &> "$log" &
FAI_MIRROR_PID="$!"
printf "\nMirroring process started in background.\n"
printf "\nChild process ID is %s.\n" "$FAI_MIRROR_PID"
printf "\nFollow up the log file contents using 'sudo tail -f %s'.\n" "$log"
#-------------------------------------------------------------------


# Write child process ID to a file
echo "$FAI_MIRROR_PID" > "$pidfile" 

# Wait for background process to terminate and exit
if wait "$FAI_MIRROR_PID"
then
   > "$pidfile"; exit 0
else
   > "$pidfile"; exit 1
fi
