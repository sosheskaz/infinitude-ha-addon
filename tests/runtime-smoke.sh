#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

image="${1:-infinitude-ha-addon:ci}"
expected_version="${2:-ci}"
workdir=""
container=""
mock=""
network=""
addon_config="$(yq -o=json '.' infinitude/config.yaml)"

validate_addon_contract() {
    local config

    for config in infinitude/config.yaml infinitude-experimental/config.yaml; do
        yq -o=json '.' "${config}" | jq -e '
            .init == false and
            .arch == ["aarch64", "amd64"] and
            (.services | index("mqtt:want") != null) and
            (.hassio_api // false) == false and
            .schema.mqtt_broker == "str?" and
            .schema.mqtt_user == "str?" and
            .schema.mqtt_pass == "password?" and
            .schema.mqtt_prefix == "str?" and
            .schema.mqtt_topic == "str?"
        ' >/dev/null
    done
}

cleanup() {
    local status=$?

    if [ -n "${container}" ]; then
        docker exec "${container}" rm -rf /data/infinitude >/dev/null 2>&1 || true
        docker rm --force "${container}" >/dev/null 2>&1 || true
        if [ -n "${workdir}" ] && [ -e "${workdir}/data/infinitude" ]; then
            docker run --rm \
                --entrypoint /bin/rm \
                --volume "${workdir}/data:/data" \
                "${image}" \
                -rf /data/infinitude >/dev/null 2>&1 || true
        fi
    fi
    if [ -n "${mock}" ]; then
        docker rm --force "${mock}" >/dev/null 2>&1 || true
    fi
    if [ -n "${network}" ]; then
        docker network rm "${network}" >/dev/null 2>&1 || true
    fi
    if [ -n "${workdir}" ]; then
        rm -rf "${workdir}" >/dev/null 2>&1 || true
    fi
    return "${status}"
}
trap cleanup EXIT

prepare_example() {
    name="$1"
    options="$2"
    mqtt_service="$3"

    cleanup
    workdir="$(mktemp -d)"
    container="infinitude-${name}-${RANDOM}"
    mock="${container}-supervisor"
    network="${container}-network"
    mkdir -p "${workdir}/data"
    printf '%s\n' "${options}" > "${workdir}/data/options.json"

    docker network create "${network}" >/dev/null
    mock_args=(
        --detach
        --name "${mock}"
        --network "${network}"
        --network-alias supervisor
        --env "ADDON_CONFIG_JSON=${addon_config}"
        --volume "${workdir}/data/options.json:/fixtures/options.json:ro"
        --volume "${PWD}/tests/mock-supervisor.py:/mock-supervisor.py:ro"
    )
    if [ -n "${mqtt_service}" ]; then
        mock_args+=(--env "MQTT_SERVICE_JSON=${mqtt_service}")
    fi
    docker run "${mock_args[@]}" \
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
}

run_example() {
    name="$1"
    options="$2"
    mqtt_service="$3"
    assertion="$4"
    secrets="$5"
    expected_log="${6:-}"

    prepare_example "${name}" "${options}" "${mqtt_service}"

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
    docker exec "${container}" jq -e "${assertion}" /infinitude/infinitude.json >/dev/null
    test "$(docker exec "${container}" stat -c '%a' /infinitude/infinitude.json)" = "600"
    docker exec "${container}" test -L /infinitude/state
    test "$(docker exec "${container}" readlink /infinitude/state)" = "/data/infinitude/state"

    logs="$(docker logs "${container}" 2>&1)"
    old_ifs="${IFS}"
    IFS=,
    for secret in ${secrets}; do
        if grep -Fq "${secret}" <<< "${logs}"; then
            echo "${name} log exposed a credential" >&2
            exit 1
        fi
    done
    IFS="${old_ifs}"
    if [ -n "${expected_log}" ]; then
        grep -Fq "${expected_log}" <<< "${logs}"
    fi
    echo "${name} example passed"
}

validate_addon_contract

base_options='{"app_secret":"runtime-smoke-secret","mode":"Production","pass_reqs":0,"serial_tty":"/dev/ttyUSB0","serial_socket":"127.0.0.1:9876"}'
auto_service='{"host":"mqtt.internal","port":1883,"ssl":false,"protocol":"3.1.1","username":"ha-user","password":"ha-pass"}'
tls_service='{"host":"mqtt.internal","port":8883,"ssl":true,"protocol":"3.1.1","username":"ha-tls-user","password":"ha-tls-pass"}'
unsupported_protocol_service='{"host":"mqtt.internal","port":1883,"ssl":false,"protocol":"5","username":"ha-v5-user","password":"ha-v5-pass"}'
manual_options='{"app_secret":"manual-app-secret","mode":"Production","pass_reqs":0,"mqtt_broker":"manual.example:2883","mqtt_user":"manual-user","mqtt_pass":"manual-pass","mqtt_prefix":"custom-discovery","mqtt_topic":"upstairs"}'

# Common path: Supervisor's MQTT service is enough to enable discovery.
run_example \
    automatic-mqtt \
    "${base_options}" \
    "${auto_service}" \
    '.pass_reqs == 0 and .serial_tty == "/dev/ttyUSB0" and .serial_socket == "127.0.0.1:9876" and .mqtt_broker == "mqtt.internal:1883" and .mqtt_user == "ha-user" and .mqtt_pass == "ha-pass" and ([keys[] | select(startswith("mqtt_"))] | length) == 3 and (has("mqtt_prefix") | not) and (has("mqtt_topic") | not)' \
    'runtime-smoke-secret,ha-pass'

# Infinitude does not currently support TLS, so reject those service details
# without making the core proxy unavailable.
run_example \
    unsupported-mqtt-tls \
    "${base_options}" \
    "${tls_service}" \
    '([keys[] | select(startswith("mqtt_"))] | length) == 0' \
    'runtime-smoke-secret,ha-tls-pass' \
    'TLS is unsupported'

# Explicit options take precedence over a discovered Supervisor service.
run_example \
    manual-mqtt \
    "${manual_options}" \
    "${auto_service}" \
    '.mqtt_broker == "manual.example:2883" and .mqtt_user == "manual-user" and .mqtt_pass == "manual-pass" and ([keys[] | select(startswith("mqtt_"))] | length) == 5 and .mqtt_prefix == "custom-discovery" and .mqtt_topic == "upstairs"' \
    'manual-app-secret,manual-pass,ha-pass'

# With neither source configured, the generated config omits MQTT entirely.
run_example \
    mqtt-disabled \
    "${base_options}" \
    '' \
    '([keys[] | select(startswith("mqtt_"))] | length) == 0' \
    'runtime-smoke-secret'

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

# Infinitude's client speaks MQTT 3.1.1; reject incompatible service metadata
# without making the core proxy unavailable.
run_example \
    unsupported-mqtt-protocol \
    "${base_options}" \
    "${unsupported_protocol_service}" \
    '([keys[] | select(startswith("mqtt_"))] | length) == 0' \
    'runtime-smoke-secret,ha-v5-pass' \
    'protocol 5 is unsupported'

echo "runtime smoke test passed"
