#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

release_tag="${1:-}"
experimental_config="${EXPERIMENTAL_CONFIG:-infinitude-experimental/config.yaml}"
release_config="${RELEASE_PLEASE_CONFIG:-release-please-config.json}"

if [[ ! "${release_tag}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "release tag must match vX.Y.Z" >&2
    exit 1
fi

export release_tag
yq -i '.version = strenv(release_tag)' "${experimental_config}"

# Bootstrap history is only needed for the first release proposal. Removing it
# in the activation PR makes the steady-state configuration explicit.
yq -o=json -I=2 -i 'del(."bootstrap-sha")' "${release_config}"
