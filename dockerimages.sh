#!/bin/bash -e

operator-sdk build gcr.io/wp-engine-development/jmeter-operator:latest
docker build --tag="gcr.io/wp-engine-development/jmeter-base:latest" -f Dockerfile-base .
docker build --tag="gcr.io/wp-engine-development/jmeter-master:latest" -f Dockerfile-master .
docker build --tag="gcr.io/wp-engine-development/jmeter-slave:latest" -f Dockerfile-slave .
# docker build --tag="gcr.io/wp-engine-development/jmeter-reporter:latest" -f Dockerfile-reporter .

docker push gcr.io/wp-engine-development/jmeter-operator:latest
docker push gcr.io/wp-engine-development/jmeter-base:latest
docker push gcr.io/wp-engine-development/jmeter-master:latest
docker push gcr.io/wp-engine-development/jmeter-slave:latest
# docker push gcr.io/wp-engine-development/jmeter-reporter:latest
