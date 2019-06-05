#!/bin/bash
set -xeo pipefail

VERSIONS="8 7"

if ! command -v skopeo; then
    echo "skopeo is required." 1>&2
    exit 1
fi
if ! command -v jq; then
    echo "jq is required." 1>&2
    exit 1
fi

mkdir -p dist

for version in $VERSIONS; do
    # skopeo inspect --raw "docker://registry.access.redhat.com/ubi${version}"
    archs=$(skopeo inspect --raw "docker://registry.access.redhat.com/ubi${version}" | \
        jq -r '.manifests | .[] | .platform.architecture')
    for arch in ${archs}; do
        skopeo --override-arch "${arch}" --override-os linux \
            copy "docker://registry.access.redhat.com/ubi${version}:latest" \
            "docker-archive:dist/rhel${version}-${arch}.tar:quay.io/junaruga/multiarch-rhel:${version}-${arch}"
    done
done
