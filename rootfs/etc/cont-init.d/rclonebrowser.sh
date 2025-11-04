#!/bin/sh
set -eu

echo "[cont-init.d] $(basename $0): initializing..."
mkdir -p /config/logs
chown -R ${USER_ID:-0}:${GROUP_ID:-0} /config || true