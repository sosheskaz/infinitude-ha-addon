#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

image="${1:?usage: published-image-smoke.sh IMAGE VERSION REVISION}"
expected_version="${2:?usage: published-image-smoke.sh IMAGE VERSION REVISION}"
expected_revision="${3:?usage: published-image-smoke.sh IMAGE VERSION REVISION}"

manifest="$(docker buildx imagetools inspect "${image}" --format '{{json .Manifest}}')"
index_digest="$(jq -er '.digest | select(test("^sha256:[0-9a-f]{64}$"))' <<< "${manifest}")"
repository="${image}"
if [[ "${image##*/}" == *:* ]]; then
    repository="${image%:*}"
fi
amd64_digest="$(jq -er '
    [.manifests[] | select(.platform.os == "linux" and .platform.architecture == "amd64") | .digest]
    | if length == 1 then .[0] else error("expected exactly one linux/amd64 manifest") end
' <<< "${manifest}")"
arm64_digest="$(jq -er '
    [.manifests[] | select(.platform.os == "linux" and .platform.architecture == "arm64") | .digest]
    | if length == 1 then .[0] else error("expected exactly one linux/arm64 manifest") end
' <<< "${manifest}")"
amd64_ref="${repository}@${amd64_digest}"
arm64_ref="${repository}@${arm64_digest}"
suffix="${GITHUB_RUN_ID:-local}-${RANDOM}"
amd64_image="infinitude-release-smoke:${suffix}-amd64"
arm64_image="infinitude-release-smoke:${suffix}-arm64"

cleanup() {
    docker image rm "${amd64_image}" "${arm64_image}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

verify_local_image() {
    local candidate="$1"
    local platform="$2"

    test "$(docker image inspect "${candidate}" --format '{{.Os}}/{{.Architecture}}')" = "${platform}"
    docker image inspect "${candidate}" --format '{{json .Config.Labels}}' | jq -e \
        --arg version "${expected_version}" \
        --arg revision "${expected_revision}" \
        '."io.hass.type" == "app" and
            ."io.hass.version" == $version and
            ."org.opencontainers.image.version" == $version and
            ."org.opencontainers.image.revision" == $revision and
            ."org.opencontainers.image.source" ==
                "https://github.com/sosheskaz/infinitude-ha-addon"' \
        >/dev/null
}

# Run the common Supervisor and MQTT examples against the exact published
# manifest's amd64 variant, rather than a separately rebuilt image.
docker pull --platform linux/amd64 "${amd64_ref}"
docker image tag "${amd64_ref}" "${amd64_image}"
verify_local_image "${amd64_image}" linux/amd64
tests/runtime-smoke.sh "${amd64_image}" "${expected_version}"

# The full behavioral examples run natively above. QEMU still starts the arm64
# artifact and proves its runtime dependencies can be loaded.
docker pull --platform linux/arm64 "${arm64_ref}"
docker image tag "${arm64_ref}" "${arm64_image}"
verify_local_image "${arm64_image}" linux/arm64
docker run --rm \
    --platform linux/arm64 \
    --entrypoint perl \
    "${arm64_image}" \
    -MData::ParseBinary -MDigest::CRC -MHash::AsObject -MIO::Termios -MNet::MQTT::Simple \
    -e 1

echo "published image smoke test passed for ${repository}@${index_digest}"
