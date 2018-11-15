#!/system/bin/sh

# This script is designed to be run on an Android device. It waits for a
# process to start that has a name that is a superstring of the supplied
# argument, and then it prints "bytes received" and "bytes transmitted" values
# from /proc/net/dev at regular intervals for a configurable amount of time.

WAIT_SLEEP_INTERVAL=0.1    # seconds
OUTPUT_SLEEP_INTERVAL=0.1    # seconds
OUTPUT_DURATION=150    # number of "output sleeps"

USAGE="./record-network-info.sh app-name"

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

counter=0
while [[ $counter -le $OUTPUT_DURATION ]] ; do
    cat /proc/net/dev | sed -n '4p' | tr -s ' ' | cut -d " " -f 3,11
    counter=$counter+1
    sleep $OUTPUT_SLEEP_INTERVAL
done
