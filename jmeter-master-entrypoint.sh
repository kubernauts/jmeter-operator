#!/bin/bash
set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

echo "START Running Jmeter slave on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
echo "jmeter args=$@"

jmeter -Dserver.rmi.ssl.disable=true -R `getent ahostsv4 '{{ meta.name }}-jmeter-slaves-svc' | cut -d' ' -f1 | sort -u | awk -v ORS=, '{print $1}' | sed 's/,$//'` -n  $@