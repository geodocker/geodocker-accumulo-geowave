BASE := $(subst -, ,$(notdir ${CURDIR}))
ORG  := $(word 1, ${BASE})
REPO := $(word 2, ${BASE})-$(word 3, ${BASE})
IMG  := quay.io/${ORG}/${REPO}
GEOWAVE_VERSION := 0.9.3-SNAPSHOT
GEOWAVE_SHA := d8567e4892115813133b603c0cf7506906a43458
BUILD_ARGS := "-Daccumulo.version=1.7.1 -Daccumulo.api=1.7 -Dhadoop.version=2.7.2 -Dgeotools.version=14.2 -Dgeoserver.version=2.8.3"
EXTRA_ARGS := "-Dfindbugs.skip=true -DskipFormat=true -DskipITs=true -DskipTests=true"

DIST_ARCHIVE := archives/${GEOWAVE_SHA}.zip
SCRIPT := geowave-${GEOWAVE_SHA}/core/cli/src/main/resources/geowave-tools.sh
TOOLS := geowave-${GEOWAVE_SHA}/deploy/target/geowave-deploy-${GEOWAVE_VERSION}-tools.jar
PLUGINS := geowave-${GEOWAVE_SHA}/extensions/formats/geolife/target/geowave-format-geolife-${GEOWAVE_VERSION}.jar \
 geowave-${GEOWAVE_SHA}/extensions/formats/stanag4676/format/target/geowave-format-4676-${GEOWAVE_VERSION}.jar \
 geowave-${GEOWAVE_SHA}/extensions/formats/avro/target/geowave-format-avro-${GEOWAVE_VERSION}.jar \
 geowave-${GEOWAVE_SHA}/extensions/formats/geotools-raster/target/geowave-format-raster-${GEOWAVE_VERSION}.jar \
 geowave-${GEOWAVE_SHA}/extensions/formats/gpx/target/geowave-format-gpx-${GEOWAVE_VERSION}.jar \
 geowave-${GEOWAVE_SHA}/extensions/formats/tdrive/target/geowave-format-tdrive-${GEOWAVE_VERSION}.jar \
 geowave-${GEOWAVE_SHA}/extensions/formats/geotools-vector/target/geowave-format-vector-${GEOWAVE_VERSION}.jar \
 geowave-${GEOWAVE_SHA}/extensions/formats/gdelt/target/geowave-format-gdelt-${GEOWAVE_VERSION}.jar
ANALYTIC := geowave-${GEOWAVE_SHA}/analytics/mapreduce/target/munged/geowave-analytic-mapreduce-${GEOWAVE_VERSION}.jar
ITERATORS := geowave-${GEOWAVE_SHA}/deploy/target/geowave-deploy-${GEOWAVE_VERSION}-accumulo-singlejar.jar

build:  ${SCRIPT} ${TOOLS} ${PLUGINS} ${ANALYTIC} ${ITERATORS}
	mkdir -p plugins/
	cp -f ${SCRIPT} geowave-tools.sh
	chmod ugo+x geowave-tools.sh
	cp -f ${TOOLS} geowave-tools.jar
	cp -f ${PLUGINS} plugins/
	cp -f ${ANALYTIC} geowave-analytic-mapreduce.jar
	cp -f ${ITERATORS} geowave-accumulo.jar
	docker build \
		--build-arg GEOWAVE_VERSION=${GEOWAVE_VERSION} \
		-t ${IMG}:latest .

.PHONY world: geowave-${GEOWAVE_SHA}/
	docker run -it --rm \
		--env BUILD_ARGS=${BUILD_ARGS} \
		--env EXTRA_ARGS=${EXTRA_ARGS} \
		--volume $(PWD)/geowave-${GEOWAVE_SHA}:/geowave:rw \
		--volume $(HOME)/.m2:/root/.m2:rw \
		--volume $(PWD)/scripts:/scripts:ro \
		maven:3-jdk-7 /scripts/build.sh $(shell id -u) $(shell id -g)

${SCRIPT} ${TOOLS} ${PLUGINS} ${ANALYTIC} ${ITERATORS}:
	make world

${DIST_ARCHIVE}:
	(cd archives ; curl -L -C - -O "https://github.com/ngageoint/geowave/archive/${GEOWAVE_SHA}.zip")

geowave-${GEOWAVE_SHA}/: ${DIST_ARCHIVE}
	unzip $<

publish: build
	docker push ${IMG}:latest
	if [ "${TAG}" != "" -a "${TAG}" != "latest" ]; then docker tag ${IMG}:latest ${IMG}:${TAG} && docker push ${IMG}:${TAG}; fi

test: build
	docker-compose up -d
	docker-compose run --rm accumulo-master bash -c "set -e \
		&& source /sbin/accumulo-lib.sh \
		&& wait_until_accumulo_is_available \
		&& accumulo shell -p GisPwd -e 'info'"
	docker-compose down

clean:
	rm -f *.jar geowave-tools.sh
	rm -rf plugins

cleaner: clean
	rm -rf geowave-${GEOWAVE_SHA}/

cleanest: cleaner
	rm -f ${DIST_ARCHIVE}
