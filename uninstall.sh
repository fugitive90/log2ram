#!/bin/sh

if [ `id -u` -eq 0 ]
then
  /etc/init.d/log2ram stop
  rm /etc/init.d/log2ram 
  rm /etc/log2ram.conf
  rm /etc/cron.hourly/log2ram
else
  echo "You need to be ROOT (sudo can be used)"
fi
