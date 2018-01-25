#!/bin/sh

if [ `id -u` -eq 0 ]
then
  /usr/local/etc/init.d/log2ram stop
  rm /usr/local/etc/init.d/log2ram 
  rm /usr/local/etc/log2ram.conf
  rm /etc/cron.d/log2ram
else
  echo "You need to be ROOT (sudo can be used)"
fi
