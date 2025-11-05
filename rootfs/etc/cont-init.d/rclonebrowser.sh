#!/bin/sh
set -eu

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

mkdir -p /config/logs
chown -R $USER_ID:$GROUP_ID /config/*