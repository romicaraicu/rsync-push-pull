#!/bin/bash
# push-datasync.sh - Push site updates from master server to front end web servers via rsync

webservers=(web01 web02 web03 web04 web05)
status="/var/www/html/datasync.status"

if [ -d /tmp/.rsync.lock ]; then
echo "FAILURE : rsync lock exists : Perhaps there is a lot of new data to push to front end web servers. Will retry soon." > $status
exit 1
fi

/bin/mkdir /tmp/.rsync.lock

if [ $? = "1" ]; then
echo "FAILURE : can not create lock" > $status
exit 1
else
echo "SUCCESS : created lock" > $status
fi

for i in ${webservers[@]}; do

echo "===== Beginning rsync of $i ====="

nice -n 20 /usr/bin/rsync -avzx --delete -e ssh /var/www/vhosts root@$i:/var/www/vhosts

if [ $? = "1" ]; then
echo "FAILURE : rsync failed. Please refer to the solution documentation " > $status
exit 1
fi

echo "===== Completed rsync of $i =====";
done

/bin/rm -rf /tmp/.rsync.lock
echo "SUCCESS : rsync completed successfully" > $status