#!/usr/bin/env bash

set -e

BRANCH_NAME="${TRAVIS_BRANCH:=unknown}"

if [ -z "$TRAVIS_COMMIT" ]; then
    export TRAVIS_COMMIT=local
fi

if [[ "${TRAVIS_PULL_REQUEST}" != "false" ]]; then
    exit 0
fi

docker build --rm=false -t akvo-flow-schemas:develop . -f Dockerfile-ci

docker run \
    -v `pwd`:/app -v $HOME/.m2:/root/.m2 \
    akvo-flow-schemas:develop mvn schema-registry:test-compatibility

if [[ "${TRAVIS_BRANCH}" != "master" ]]; then
    exit 0
fi

docker run \
    -v `pwd`:/app -v $HOME/.m2:/root/.m2 \
    -e CLOJARS_PASSWORD="${CLOJARS_PASSWORD}" -e TRAVIS_COMMIT="${TRAVIS_COMMIT}" -e TRAVIS_BUILD_NUMBER="${TRAVIS_BUILD_NUMBER}" \
    -e CLOJARS_GPG_PASSWORD="${CLOJARS_GPG_PASSWORD}" \
     akvo-flow-schemas:develop /release.sh
