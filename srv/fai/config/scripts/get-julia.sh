#!/bin/bash

# Download Julia versions, move them to /srv/fai/config/files/archives/APPS/opt/.
# Edit /srv/fai/config/scripts/APPS/70-julia to use the same versions.

# make sure we're in the right directory
#cd /srv/fai/config/files/archives || exit 1
#cd /tmp

# check if running with sudo permissions
# need them to access /srv/fai/config/...
if [[ ! $(id -u) -eq 0 ]]; then echo "Use sudo to run this script."; exit 1; fi

juliaDownloadBaseURL=https://julialang-s3.julialang.org/bin/linux/x64/
juliaFaiPath=/srv/fai/config/files/archives/APPS/opt/

# array of julia versions
# declare -A juliaVersArr
# juliaVersArr[julia-1.6.5]="1.6/julia-1.6.5-linux-x86_64.tar.gz"
# juliaVersArr[julia-1.6.7]="1.6/julia-1.6.7-linux-x86_64.tar.gz"
# juliaVersArr[julia-1.7.2]="1.7/julia-1.7.2-linux-x86_64.tar.gz"
# juliaVersArr[julia-1.8.5]="1.8/julia-1.8.5-linux-x86_64.tar.gz"

# main versions (will be suffixed with -stable and -lts)
# juliaVersStable="julia-1.8.5"
# juliaVersLTS="julia-1.6.7"

# load the list of versions
source $juliaFaiPath/get-julia-versions.conf

echo "Removing old versions from the $juliaFaiPath..."
cd $juliaFaiPath
rm -rf julia
rm -rf julia-*

echo  

cd /tmp


# download all archives into
echo "The following julia versions will be downloaded: ${!juliaVersArr[@]}"
echo 
for vers in "${!juliaVersArr[@]}"; do
	echo " [$vers] downloading..."
	wget -q $juliaDownloadBaseURL${juliaVersArr[$vers]}
	# extract
	echo " [$vers] extracting..."
	tar -zxf $vers-*.tar.gz
	echo " [$vers] move to FAI..."
	# move to juliaFaiPath
        mv $vers $juliaFaiPath$vers
	# remove archive
	echo " [$vers] cleaning up /tmp..."
	rm $vers-*.tar.gz
	echo 
done

echo "Rename the stable and lts versions..."

# rename stable and lts versions
cd $juliaFaiPath
mv $juliaVersStable $juliaVersStable-stable
mv $juliaVersLTS $juliaVersLTS-lts

# link current stable release
echo "Linking julia to the current stable release..."
ln -s $juliaVersStable-stable julia

echo 
echo "Executing pack to create new archives..."
echo
pack
echo 
echo "Done."

exit 1

