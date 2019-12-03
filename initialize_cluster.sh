#!/usr/bin/env bash

## Create jmeter database automatically in Influxdb

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

echo "Creating Influxdb jmeter Database"

##Wait until Influxdb Deployment is up and running
##influxdb_status=`kubectl get po -n $tenant | grep influxdb-jmeter | awk '{print $2}' | grep Running

influxdb_pod=`kubectl -n $namespace get po | grep influxdb | awk '{print $1}'`

kubectl -n $namespace exec -ti $influxdb_pod -- influx -execute 'CREATE DATABASE jmeter'

## Create the influxdb datasource in Grafana

echo "Creating the Influxdb data source"

grafana_pod=`kubectl -n $namespace get po | grep grafana | awk '{print $1}'`

## Make load test script in Jmeter master pod executable

#Get Master pod details

master_pod=`kubectl -n $namespace get po | grep master | awk '{print $1}'`

# # Workaround for the read only attribute of config map
kubectl -n $namespace exec -ti $master_pod -- cp -rf /load_test /jmeter/load_test

kubectl -n $namespace exec -ti $master_pod -- chmod 755 /jmeter/load_test

#Get the name of the influxDB svc

influxdb_svc=`kubectl -n $namespace get svc | grep influxdb | awk '{print $1}'`

kubectl -n $namespace exec -ti $grafana_pod -- curl 'http://admin:admin@127.0.0.1:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"jmeterdb","type":"influxdb","url":"http://'$influxdb_svc':8086","access":"proxy","isDefault":true,"database":"jmeter","user":"admin","password":"admin"}'