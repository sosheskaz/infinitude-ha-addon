#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

experimental_config="${EXPERIMENTAL_CONFIG:-infinitude-experimental/config.yaml}"
stable_config="${STABLE_CONFIG:-infinitude/config.yaml}"
experimental_changelog="${EXPERIMENTAL_CHANGELOG:-infinitude-experimental/CHANGELOG.md}"
stable_changelog="${STABLE_CHANGELOG:-infinitude/CHANGELOG.md}"

cp "${experimental_config}" "${stable_config}"
yq -i '
    .name = "Infinitude" |
    .slug = "infinitude" |
    .stage = "stable"
' "${stable_config}"
cp "${experimental_changelog}" "${stable_changelog}"
