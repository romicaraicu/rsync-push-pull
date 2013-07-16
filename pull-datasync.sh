#!/bin/bash
# pull-datasync.sh : Pull site updates down from master to front end web servers via rsync

status="/var/www/html/datasync.status"

if [ -d /tmp/.rsync.lock ]; then
echo "FAILURE : rsync lock exists : Perhaps there is a lot of new data to pull from the master server. Will retry shortly" > $status
exit 1
fi

/bin/mkdir /tmp/.rsync.lock

if [ $? = "1" ]; then
echo "FAILURE : can not create lock" > $status
exit 1
else
echo "SUCCESS : created lock" > $status
fi

echo "===== Beginning rsync ====="

nice -n 20 /usr/bin/rsync -axvz --delete -e ssh root@192.168.1.1:/var/www/vhosts/ /var/www/vhosts/

if [ $? = "1" ]; then
echo "FAILURE : rsync failed. Please refer to solution documentation" > $status
exit 1
fi

echo "===== Completed rsync ====="

/bin/rm -rf /tmp/.rsync.lock
echo "SUCCESS : rsync completed successfully" > $status