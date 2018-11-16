#!/system/bin/sh

# This script is designed to be run on an Android device. It waits for a
# process to start that has exactly the given name (NOT a name that is a
# superstring of the given argument as in record-network-info.sh), and then
# it invokes strace on the process.

WAIT_SLEEP_INTERVAL=0.1    # seconds

USAGE="./attach-strace-on-startup.sh app-name"

appName=$1

if [[ $appName = "" ]] ; then
    echo "usage: $USAGE"
    exit 1
fi

pid=$(ps | grep "$appName" | cut -d " " -f 5)
while [[ $pid = "" ]] ; do
    sleep $WAIT_SLEEP_INTERVAL
    pid=$(ps | grep "$appName" | cut -d " " -f 5)
done

echo "App $appName started with PID $pid"

strace -o "$appName-trace.txt" -f -p $pid
