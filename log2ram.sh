#!/bin/sh
## $FreeBSD: releng/11.1/etc/rc.d/dmesg 298514 2016-04-23 16:10:54Z lme $#

# PROVIDE: log2ram
# REQUIRE: mountcritremote FILESYSTEMS
# BEFORE: DAEMON

# Modification:	   Script modified to be compactible with FreeBSD rc
# Pre-check is made if log2ram is already mounted, which prevents over usage of RAM


# Author: azlux <azlux@outlook.com>
# Modified by: fugitive90 <fugitiv3@protonmail.com>
# Compactible by  FreeBSD 

. /etc/rc.subr


RAM_LOG="/var/log"
HDD_LOG="/var/hdd_log"
LOG2RAM_LOG="${HDD_LOG}/log2ram"
CONFIG="/usr/local/etc/log2ram.conf"

name="log2ram"
desc="make /var/log as tmpfs, and do periodical syncs in order to prevent lot of I/O on sdcards"
rcvar="${name}_enable"
start_cmd="${name}_start"
stop_cmd="${name}_stop"
sync_cmd="${name}_sync"
extra_commands="sync"
pidfile="/var/run/${name}.pid"

[ $( id -u ) -ne 0 ] && err 2 "Must be run as root"


# Load config 
if [ ! -f $CONFIG ]; then
   err 2 "Config file not found!" 
else
   . $CONFIG
fi



check_is_mounted ()
{
	if mount -p | grep -q "${RAM_LOG}.*tmpfs" ; then
     return 0 #log2ram  mounted
   else 
     return 1 #log2ram not mounted
   fi
   

}

# FIXME: Failure to umount /var/log due /w actions from syslog!
# Because syslog oftenly writes to /var/log making it busy for unmount.
# NB: generally --force flag is considered dangerous, but since this is a RAM-type FS
# should be considered safe.
umount_log ()
{
	local _rc_log

	check_is_mounted
	if [ $? -eq 0 ];then
       if ! umount  "$RAM_LOG" ; then
           warn "Failed umounting $RAM_LOG . Trying to force it.."
           umount -f $RAM_LOG && info "${RAM_LOG} unmounted"      
       fi
	else
		info "Log2ram is not mounted" 
      return 2
	fi
}

is_safe () {
    [ -d "$HDD_LOG" ] || err 2 "$HDD_LOG doesn't exist!  Can't sync."
}

sync_to_disk () {
    is_safe

    if [ "$USE_RSYNC" = true ]; then
        rsync -aXWv --delete --exclude log2ram.log --links ${RAM_LOG}/* "${HDD_LOG}" || err 2 "Unable to rsync"
    else
        cp -rfp  "${RAM_LOG}/" "${HDD_LOG}" || err 2 "Unable to copy files."
    fi
    return 0
}

# Copy files from HDD to ram
sync_from_disk () {
    is_safe

    if [ ! -z $( /usr/bin/du -sh -t "$SIZE" "$HDD_LOG" | cut -f1 ) ]; then
        warn "RAM disk too small. Can't sync." && umount_log

		if [ "$MAIL" = true ]; then
			warn "LOG2RAM : No place on RAM anymore, fallback on the disk"
			echo "LOG2RAM : No place on RAM anymore, fallback on the disk" | mail -s 'Log2Ram Error' root;
		fi
        exit 1
    fi

    # Don't sync compressed logs to the ramdisk, in order to save RAM
    if [ "$USE_RSYNC" = true ]; then
        rsync -aXWv --delete \
              --exclude=*.bz2 \
				  --exclude=*.[0-9] \
              --exclude=*.gz \
              --links ${HDD_LOG}/* "$RAM_LOG" > "${LOG2RAM_LOG}.log" 2> "${LOG2RAM_LOG}.err" || warn "Failure to sync to the RAM disk"
    else
        for i in  ${HDD_LOG}/* ; do
				case "$i" in 
				*.bz2)
               continue ;;
            *.gz)
               continue ;;
            *.[0-9])
               continue ;;
            *)
               cp -rfp $i "$RAM_LOG" > "${LOG2RAM_LOG}.log" 2> "${LOG2RAM_LOG}.err" || warn "Failure to sync to the RAM disk"
				   ;;
				esac
            #   grep -v "\.\(bz2\|tar\|\[0-9\]\|xz\|gz\)$" 
            #cp -rfp $i "$RAM_LOG" > "${LOG2RAM_LOG}.log" 2> "${LOG2RAM_LOG}.err" || warn "Failure to sync to the RAM disk"
        done
    fi
   return 0
}


log2ram_start ()
{
	
   [ -d "$HDD_LOG" ] || mkdir "$HDD_LOG"
   [ -f ${LOG2RAM_LOG} ]  && rm ${LOG2RAM_LOG}.*  
  
   if [ ! -e $pidfile ] ; then
        sync_to_disk
        mount -t tmpfs -o nosuid,noexec,mode=0755,size="$SIZE" log2ram "$RAM_LOG" || err 2 "Failure to mount $RAM_LOG as tmpfs!"
     	  sync_from_disk && info "Log2ram is running"
	     echo $$ > $pidfile
   else
      err 2 "Log2ram is already running"
   fi

}

log2ram_stop ()
{
  if [ -e $pidfile ]; then
	check_is_mounted 
	[  $? -eq 0 ] && sync_to_disk
	umount_log && rm $pidfile
  else
    warn "Log2ram is not running."
    exit 2
  fi
}

log2ram_sync ()
{
	check_is_mounted
	if [ $? -eq 0 ]; then
   	sync_to_disk &&  info "Files synced"
      logger -p info "Files synced"
	else
	  warn "Log2ram not mounted. Files not synced!"
	  exit 2 
	fi

}

load_rc_config $name
run_rc_command $*
