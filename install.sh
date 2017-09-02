#!/bin/sh

if [ `id -u` -eq 0 ]
then
  cp log2ram /etc/init.d/ 
  chmod 744 /etc/init.d/log2ram
  update-rc.d log2ram defaults
  cp log2ram.conf /etc/default/log2ram.conf
  chmod 644 /etc/default/log2ram.conf
  cp log2ram.hourly /etc/cron.hourly/log2ram
  chmod +x /etc/cron.hourly/log2ram

  echo "##### Reboot to activate log2ram #####"
else
  echo "You need to be ROOT (sudo can be used)"
fi
