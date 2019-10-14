# Backupper for Raspberry Pi by /u/niiwiicamo
# https://github.com/niiwiicamo

# SCRIPT VERSION 1.0

# get config
. ./backupper.conf

# check if target share is mounted
teststring="${NFSSHARE} ${MOUNTPOINT} ";

if grep -qs ${teststring} /proc/mounts; then
	echo "Backup share is mounted.";
else
	echo "Backup share is not mounted.";

	attempts=0;

	until (( grep -qs ${teststring} /proc/mounts )); do
		attempts=$((attempts+1));
		#check if max attempts reached
		if [ $attempts -le $MOUNTATTEMPTS ];
		then
			echo "Attempting to mount share "${NFSSHARE}". Attempt "${attempts}"/"${MOUNTATTEMPTS};
			mkdir -p ${MOUNTPOINT};
			mount -t nfs -o soft ${NFSSHARE} ${MOUNTPOINT};
		else
			echo "Share could not be mounted. Are you allowed to? Maybe try sudo?";
			exit 1;
		fi
		sleep ${MOUNTRETRYDELAY};
	done
	# share is mounted now, tell user where
	echo "Backup will be saved to ${BACKUPLOCATION}, which resides on ${NFSSHARE}."
	sleep 3
fi

# Check for existing backups
#for f in "${BACKUPLOCATION}/*"; do
#	
#
#


# stop services before starting backup
${STOPSERVICES} stop

# make subdirectory, if necessary
mkdir -p ${BACKUPLOCATION}

#do backup
dd if=/dev/mmcblk0 of=${BACKUPLOCATION}/${BACKUPNAME}.img bs=${BLOCKSIZE}

# start services
${STOPSERVICES} start

# clean up old backups
pushd ${BACKUPLOCATION}; ls -tr ${BACKUPLOCATION}/${BACKUPNAME}* | head -n -${BACKUPCOUNT} | xargs rm; popd
