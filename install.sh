#!/bin/sh

if [ `id -u` -eq 0 ]
then
  cp log2ram.sh /usr/local/etc/rc.d/log2ram
  chmod u+x /usr/local/etc/rc.d/log2ram
  echo "log2ram_enable=\"YES\"" >> /etc/rc.conf

#saved for sysV
#  which update-rc.d >/dev/null
#  if [ $? -eq 0 ]; then
#	 update-rc.d log2ram defaults
#  else
#	 echo "Log2ram is not enabled on boot. Please update it with your init system."
#  fi

  cp log2ram.conf /usr/local/etc/log2ram.conf
  chmod 644 /usr/local/etc/log2ram.conf
  cp log2ram.cron /etc/cron.d/log2ram

else
  echo "You need to be ROOT (sudo can be used)"
fi
