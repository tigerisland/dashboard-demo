#!/bin/sh

./script/server -e production > /dev/null 2>&1 &

ATTEMPTS=30

while [ $ATTEMPTS -gt 0 ]; do
        echo "Attempts remaining: $ATTEMPTS"
        (netstat -an|grep ' 0 0.0.0.0:3000 ' > /dev/null 2>&1) && exit 0
        sleep 1
        ATTEMPTS=`expr $ATTEMPTS \- 1`
done

exit 1
