FROM quay.io/geodocker/accumulo:0.2

MAINTAINER Pomadchin Grigory <daunnc@gmail.com>

ARG GEOWAVE_VERSION
ENV GEOWAVE_VERSION ${GEOWAVE_VERSION}
ENV GEOWAVE_HOME /usr/local/geowave

ADD geowave-tools.sh ${GEOWAVE_HOME}/tools/
ADD geowave-tools.jar ${GEOWAVE_HOME}/tools/
ADD plugins/ ${GEOWAVE_HOME}/tools/plugins/
ADD geowave-analytic-mapreduce.jar ${GEOWAVE_HOME}/tools/
ADD geowave-accumulo.jar ${GEOWAVE_HOME}/accumulo/

COPY ./fs /
ENTRYPOINT [ "/sbin/geowave-entrypoint.sh" ]
