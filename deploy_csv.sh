#!/usr/bin/env bash
#Script created to copy csv config file to jmeter slave pods
#It requires that you supply the path to the csv file and destination path in the jmeter pods

namespace="$1"

[ -n "$namespace" ] || read -p 'Enter the Jmeter Namespace: ' namespace

kubectl get namespace | grep $namespace >> /dev/null

if [ $? != 0 ];
then
    echo "Namespace does not exist in the kubernetes cluster"
    echo ""
    echo "Below is the list of namespaces in the kubernetes cluster"

    kubectl get namespaces
    echo ""
    echo "Please check and try again"
    exit
fi

csv="$2"
[ -n "$csv" ] || read -p 'Enter path to the csv file:' csv

if [ ! -f "$csv" ];
then
    echo "csv file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

csv_name="$(basename "$csv")"

path="$3"
[ -n "$path" ] || read -p 'Enter destination path:' path



#Get Master pod details

kubectl -n $namespace get po | grep jmeter-slave | grep Running | awk '{print $1}' | while read -r slave_pod ; do
    echo "Deploying $csv_name to:  $slave_pod"
    kubectl -n $namespace cp "$csv" "$slave_pod:$path/$csv_name"
done



