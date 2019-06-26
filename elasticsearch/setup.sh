#!/usr/bin/env bash
#
# Copyright (C) 2019 by eHealth Africa : http://www.eHealthAfrica.org
#
# See the NOTICE file distributed with this work for additional information
# regarding copyright ownership.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
set -Eeuo pipefail

source ./.env || \
    ( echo "Run this script from /aether-bootstrap not from /aether-bootstrap/elasticsearch" && \
      exit 1 )
source ./scripts/aether_functions.sh

DC_AUTH="docker-compose -f docker-compose-generation.yml"
AUTH_RUN="$DC_AUTH run --rm auth"
DCES="docker-compose -f ./elasticsearch/docker-compose.yml"

$DCES pull elasticsearch kibana
$DCES up -d elasticsearch

start_container kong     $KONG_INTERNAL
start_container keycloak "${KEYCLOAK_INTERNAL}/auth"


$AUTH_RUN setup_elasticsearch

function add_es_tenant {
    REALM=$1
    echo_message "Adding [kibana] service in kong..."
    $AUTH_RUN add_service kibana $REALM $KEYCLOAK_KONG_CLIENT
    $AUTH_RUN add_elasticsearch_tenant $REALM
}


add_es_tenant "dev"
add_es_tenant "prod"
add_es_tenant "test"