#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

image="${1:-infinitude-ha-addon:ci}"
expected_version="${2:-ci}"
workdir="$(mktemp -d)"
container="infinitude-runtime-smoke-${RANDOM}"
mock="${container}-supervisor"
network="${container}-network"
secret="runtime-smoke-secret"

cleanup() {
    local status=$?

    docker exec "${container}" rm -rf /data/infinitude >/dev/null 2>&1 || true
    docker rm --force "${container}" >/dev/null 2>&1 || true
    if [ -e "${workdir}/data/infinitude" ]; then
        docker run --rm \
            --entrypoint /bin/rm \
            --volume "${workdir}/data:/data" \
            "${image}" \
            -rf /data/infinitude >/dev/null 2>&1 || true
    fi
    docker rm --force "${mock}" >/dev/null 2>&1 || true
    docker network rm "${network}" >/dev/null 2>&1 || true
    rm -rf "${workdir}" >/dev/null 2>&1 || true
    return "${status}"
}
trap cleanup EXIT

mkdir -p "${workdir}/data"
printf '%s\n' "{\"app_secret\":\"${secret}\",\"log_level\":\"info\",\"mode\":\"Production\",\"pass_reqs\":0,\"serial_tty\":\"/dev/ttyUSB0\",\"serial_socket\":\"127.0.0.1:9876\"}" \
    > "${workdir}/data/options.json"

docker network create "${network}" >/dev/null
docker run --detach \
    --name "${mock}" \
    --network "${network}" \
    --network-alias supervisor \
    --volume "${workdir}/data/options.json:/fixtures/options.json:ro" \
    --volume "${PWD}/tests/mock-supervisor.py:/mock-supervisor.py:ro" \
    docker.io/library/python:3.14-alpine@sha256:016508ba505da24f7139765bc4bb669df4e88eb2f12eeadd571bf2f88d7533df \
    python /mock-supervisor.py >/dev/null

for _ in $(seq 1 30); do
    if docker exec "${mock}" python -c \
        'import urllib.request; urllib.request.urlopen("http://127.0.0.1/addons/self/options/config")' \
        >/dev/null 2>&1; then
        break
    fi
    sleep 1
done
docker exec "${mock}" python -c \
    'import urllib.request; urllib.request.urlopen("http://127.0.0.1/addons/self/options/config")' \
    >/dev/null

docker run --detach \
    --name "${container}" \
    --env SUPERVISOR_TOKEN=runtime-smoke-token \
    --network "${network}" \
    --publish 127.0.0.1::3000 \
    --volume "${workdir}/data:/data" \
    "${image}" >/dev/null

port=""
for _ in $(seq 1 60); do
    port="$(docker port "${container}" 3000/tcp 2>/dev/null | head -n 1 | sed 's/.*://' || true)"
    if [ -n "${port}" ] && curl --fail --silent "http://127.0.0.1:${port}/api/status" >/dev/null; then
        break
    fi
    if [ "$(docker inspect --format '{{.State.Running}}' "${container}")" != "true" ]; then
        docker logs "${container}" >&2
        exit 1
    fi
    sleep 1
done

test -n "${port}"
curl --fail --silent "http://127.0.0.1:${port}/api/status" >/dev/null

docker image inspect "${image}" --format '{{json .Config.Labels}}' | jq -e \
    --arg version "${expected_version}" \
    '."io.hass.type" == "app"
        and ."io.hass.version" == $version
        and ."org.opencontainers.image.version" == $version
        and ."org.opencontainers.image.source" == "https://github.com/sosheskaz/infinitude-ha-addon"' \
    >/dev/null
docker exec "${container}" perl \
    -MData::ParseBinary -MDigest::CRC -MHash::AsObject -MIO::Termios -MNet::MQTT::Simple \
    -e 1
docker exec "${container}" jq -e \
    '.pass_reqs == 0 and .serial_tty == "/dev/ttyUSB0" and .serial_socket == "127.0.0.1:9876"' \
    /infinitude/infinitude.json >/dev/null
test "$(docker exec "${container}" stat -c '%a' /infinitude/infinitude.json)" = "600"
docker exec "${container}" test -L /infinitude/state
test "$(docker exec "${container}" readlink /infinitude/state)" = "/data/infinitude/state"

if docker logs "${container}" 2>&1 | grep -Fq "${secret}"; then
    echo "runtime log exposed app_secret" >&2
    exit 1
fi

echo "runtime smoke test passed"
