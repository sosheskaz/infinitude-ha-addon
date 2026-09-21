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
cp "${workdir}/experimental/config.yaml" "${workdir}/experimental-before.yaml"
cp "${workdir}/release-please-config.json" "${workdir}/release-please-before.json"
cp "${workdir}/stable/config.yaml" "${workdir}/stable-before.yaml"

EXPERIMENTAL_CONFIG="${workdir}/experimental/config.yaml" \
RELEASE_PLEASE_CONFIG="${workdir}/release-please-config.json" \
    bash scripts/activate-experimental.sh v2.0.0

yq -e '.version == "v2.0.0"' "${workdir}/experimental/config.yaml" >/dev/null
diff \
    <(yq 'del(.version)' "${workdir}/experimental-before.yaml") \
    <(yq 'del(.version)' "${workdir}/experimental/config.yaml")
yq -e '
    has("bootstrap-sha") | not and
    ."initial-version" == "2.0.0"
' "${workdir}/release-please-config.json" >/dev/null
diff \
    <(yq -o=json 'del(."bootstrap-sha")' "${workdir}/release-please-before.json") \
    "${workdir}/release-please-config.json"
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
