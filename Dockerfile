FROM quay.io/geodocker/accumulo:latest

MAINTAINER Pomadchin Grigory, daunnc@gmail.com

ENV GEOWAVE_VERSION 0.9.1
ENV GEOWAVE_HOME /usr/local/geowave

# GeoWave Iterators
RUN set -x \
  && rpm -Uvh --replacepkgs http://s3.amazonaws.com/geowave-rpms/release/noarch/geowave-repo-1.0-3.noarch.rpm \
  && yum --enablerepo=geowave install -y geowave-${GEOWAVE_VERSION}-apache-accumulo \
  && yum --enablerepo=geowave install -y geowave-${GEOWAVE_VERSION}-apache-tools
