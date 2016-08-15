#!/usr/bin/env bash

cd /geowave
mvn clean
mvn install $EXTRA_ARGS $BUILD_ARGS
mvn package -P accumulo-container-singlejar $EXTRA_ARGS $BUILD_ARGS
mvn package -P geotools-container-singlejar $EXTRA_ARGS $BUILD_ARGS
mvn package -P geowave-analytic-mapreduce $EXTRA_ARGS $BUILD_ARGS
mvn package -P geowave-tools-singlejar $EXTRA_ARGS $BUILD_ARGS
chown -R $1:$2 /root/.m2
chown -R $1:$2 /geowave
