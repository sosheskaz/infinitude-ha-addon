#!/usr/bin/env bash

set -e

CONFIG_PATH=/data/options.json

cfg() {
  jq --arg key "$1" '.[$key]' < "${CONFIG_PATH}"
}

MODE="$(cfg 'mode')"
export MODE

if [[ "${MODE}" = "Development" ]]
then
  set -x
fi

APP_SECRET="$(cfg 'app_secret')"
PASS_REQS="$(cfg 'pass_reqs')"
SERIAL_TTY="$(cfg 'serial_tty')"
SERIAL_SOCKET="$(cfg 'serial_socket')"
TZ="$(cfg timezone)"
export TZ

CFG="$(jq -s \
  --arg APP_SECRET "${APP_SECRET}" \
  --argjson PASS_REQS "${PASS_REQS}" \
  '{"app_secret":$APP_SECRET,"pass_reqs":$PASS_REQS}' \
  < /dev/null)"

if [[ -n "${SERIAL_TTY}" ]]
then
  CFG="$(jq \
    --arg SERIAL_TTY "${SERIAL_TTY}" \
    '. + {"serial_tty":$SERIAL_TTY}' \
    <<< "${CFG}")"
fi

if [[ -n "${SERIAL_SOCKET}" ]]
then
  CFG="$(jq \
    --arg SERIAL_TTY "${SERIAL_SOCKET}" \
    '. + {"serial_tty":$SERIAL_SOCKET}' \
    <<< "${CFG}")"
fi


echo "${CFG}" > /infinitude/infinitude.json

rm -rf /infinitude/state
mkdir -p /data/infinitude/state
ln -sfT /data/infinitude/state /infinitude/state

/infinitude/entrypoint.sh "$@"
