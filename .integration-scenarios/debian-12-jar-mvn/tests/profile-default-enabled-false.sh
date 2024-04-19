#!/usr/bin/env bash

TESTROOT="$( cd "$(dirname "$0")"/.. >/dev/null 2>&1 ; pwd -P )"
source $TESTROOT/files/testfunctions.sh
source $TESTROOT/files/test.conf
prepareTest $(basename $0) $*

configPT=$(makeTempFile $(basename $0) "\
ors:
  engine:
    source_file: ors-api/src/test/files/heidelberg.osm.gz
    profile_default:
      enabled: false
    profiles:
      public-transport:
        gtfs_file: ors-api/src/test/files/vrn_gtfs_cut.zip
")

podman run --replace --name "${CONTAINER}" -p "${HOST_PORT}":8082 \
  -v "${M2_FOLDER}":/root/.m2 \
  -v "${TESTROOT}/graphs_volume":"${CONTAINER_WORK_DIR}/graphs" \
  -v "${configPT}":"${CONTAINER_WORK_DIR}/ors-config.yml" \
  "local/${IMAGE}:latest" &

# expect process finished timout
res=$(expectOrsStartupFails 300 "$CONTAINER" )
# stop container if was not finished
cleanupTest

assertEquals "terminated" "$res"
