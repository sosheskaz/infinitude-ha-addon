#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

workdir="$(mktemp -d)"
cleanup() {
    rm -rf "${workdir}"
}
trap cleanup EXIT

mkdir -p "${workdir}/experimental" "${workdir}/stable"
cp infinitude-experimental/config.yaml "${workdir}/experimental/config.yaml"
cp infinitude/config.yaml "${workdir}/stable/config.yaml"
cp infinitude-experimental/CHANGELOG.md "${workdir}/experimental/CHANGELOG.md"
cp release-please-config.json "${workdir}/release-please-config.json"
cp "${workdir}/stable/config.yaml" "${workdir}/stable-before.yaml"

EXPERIMENTAL_CONFIG="${workdir}/experimental/config.yaml" \
RELEASE_PLEASE_CONFIG="${workdir}/release-please-config.json" \
    bash scripts/activate-experimental.sh v2.0.0

yq -e '
    .version == "v2.0.0" and
    .init == false and
    (.arch | join(",")) == "aarch64,amd64" and
    .hassio_api == true and
    (.services | join(",")) == "mqtt:want" and
    .backup == "hot" and
    .schema.mqtt_broker == "str?" and
    .schema.mqtt_user == "str?" and
    .schema.mqtt_pass == "password?" and
    .schema.mqtt_prefix == "str?" and
    .schema.mqtt_topic == "str?"
' "${workdir}/experimental/config.yaml" >/dev/null
yq -e 'has("bootstrap-sha") | not' "${workdir}/release-please-config.json" >/dev/null
cmp "${workdir}/stable/config.yaml" "${workdir}/stable-before.yaml"

EXPERIMENTAL_CONFIG="${workdir}/experimental/config.yaml" \
STABLE_CONFIG="${workdir}/stable/config.yaml" \
EXPERIMENTAL_CHANGELOG="${workdir}/experimental/CHANGELOG.md" \
STABLE_CHANGELOG="${workdir}/stable/CHANGELOG.md" \
    bash scripts/promote-experimental.sh

yq -e '
    .name == "Infinitude" and
    .slug == "infinitude" and
    .stage == "stable" and
    .version == "v2.0.0"
' "${workdir}/stable/config.yaml" >/dev/null
diff \
    <(yq 'del(.name, .slug, .stage)' "${workdir}/experimental/config.yaml") \
    <(yq 'del(.name, .slug, .stage)' "${workdir}/stable/config.yaml")
cmp "${workdir}/experimental/CHANGELOG.md" "${workdir}/stable/CHANGELOG.md"

echo "channel lifecycle examples passed"
