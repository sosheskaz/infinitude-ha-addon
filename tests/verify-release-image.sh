#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

image="${1:?usage: verify-release-image.sh IMAGE VERSION REVISION}"
expected_version="${2:?usage: verify-release-image.sh IMAGE VERSION REVISION}"
expected_revision="${3:?usage: verify-release-image.sh IMAGE VERSION REVISION}"

metadata="$(docker buildx imagetools inspect "${image}" --format '{{json .Image}}')"
jq -e \
    --arg version "${expected_version}" \
    --arg revision "${expected_revision}" \
    '
        (keys | sort) == ["linux/amd64", "linux/arm64"] and
        all(
            to_entries[];
            .value.config.Labels["io.hass.type"] == "app" and
            .value.config.Labels["io.hass.version"] == $version and
            .value.config.Labels["org.opencontainers.image.version"] == $version and
            .value.config.Labels["org.opencontainers.image.revision"] == $revision and
            .value.config.Labels["org.opencontainers.image.source"] ==
                "https://github.com/sosheskaz/infinitude-ha-addon"
        )
    ' <<< "${metadata}" >/dev/null

echo "verified ${image} for linux/amd64 and linux/arm64"
