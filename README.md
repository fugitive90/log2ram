# Log2Ram

NB:This repository is fork of the (https://github.com/azlux/log2ram) 


Like ramlog for  FreeBSD rc systems.

Usefull for **Raspberry** for not writing all the time on the SD card. You need it because your SD card don't want to suffer anymore !

Log2Ram is based on transient log for Systemd here : [A transient /var/log](https://www.debian-administration.org/article/661/A_transient_/var/log). The rc script is modified to be compactible with FreeBSD systems.

## Install
```
git clone https://github.com/fugitive90/log2ram.git
cd log2ram
chmod +x install.sh
./install.sh
service log2ram start
service log2ram sync # To force sync
```
**REBOOT** before installing anything else (for example apache2)

## Customize
#### variables :
Into the file `/usr/local/etc/log2ram.conf`, there are three variables :

- The first variable define the size the log folder will reserve into the RAM.
- The second variable can be set to `true` if you prefer "rsync" than "cp". I use the command `cp -u` and `rsync -X`, I don't copy the all folder every time for optimization.
- The last varibale disable the error system mail if there are no enought place on RAM (if set on false)

#### refresh time:
The default is to write log into the HardDisk every hour. If you think this is too much, you can make the write every day by updating `/etc/cron.d/log2ram.cron`.

### It is working ?
You can now check the mount folder in ram with (You will see lines with log2ram if working)
```
df -h
mount -p
```

The log for log2ram will be writen here : `/var/hdd_log/log2ram.log`

### 
Author: azlux

Modified by: fugitive90

Version: 1.0

###### Now, muffins for everyone !


## Uninstall :(
(Because sometime we need it)
```
cd log2ram
chmod +x uninstall.sh
./uninstall.sh
```
