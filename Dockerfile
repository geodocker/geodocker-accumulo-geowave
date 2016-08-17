FROM quay.io/geodocker/accumulo:latest

MAINTAINER Pomadchin Grigory <daunnc@gmail.com>

ARG GEOWAVE_VERSION
ENV GEOWAVE_VERSION ${GEOWAVE_VERSION}
ENV GEOWAVE_HOME /usr/local/geowave

ADD geowave-tools.sh ${GEOWAVE_HOME}/tools/
ADD geowave-tools.jar ${GEOWAVE_HOME}/tools/
ADD plugins/ ${GEOWAVE_HOME}/tools/plugins/
ADD geowave-analytic-mapreduce.jar ${GEOWAVE_HOME}/tools/
ADD geowave-accumulo.jar ${GEOWAVE_HOME}/accumulo/

# Add a useful alias for geowave command line
RUN echo '#!/bin/bash' > /usr/bin/geowave
RUN echo '${GEOWAVE_HOME}/tools/geowave-tools.sh' >> /usr/bin/geowave
RUN chmod +x /usr/bin/geowave


COPY ./fs /
ENTRYPOINT [ "/sbin/geowave-entrypoint.sh" ]
