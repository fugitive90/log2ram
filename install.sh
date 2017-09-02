#!/bin/sh

if [ `id -u` -eq 0 ]
then
  cp log2ram /etc/init.d/ 
  chmod 744 /etc/init.d/log2ram
  which update-rc.d >/dev/null
  if [ $? -eq 0 ]; then
	 update-rc.d log2ram defaults
  else
	 echo "Log2ram is not enabled on boot. Please update it with your init system."
  fi

  cp log2ram.conf /etc/log2ram.conf
  chmod 644 /etc/log2ram.conf
  cp log2ram.hourly /etc/cron.hourly/log2ram
  chmod +x /etc/cron.hourly/log2ram

else
  echo "You need to be ROOT (sudo can be used)"
fi
