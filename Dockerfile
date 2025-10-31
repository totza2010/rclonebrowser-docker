#
# Custom Rclone Browser (Qt5 + Teldrive edition)
#

# =========================
# ==== RUNTIME STAGE ======
# =========================
FROM jlesage/baseimage-gui:debian-12-v4

# ===== Environment =====
ENV APP_NAME="RcloneBrowser" \
    S6_KILL_GRACETIME=8000 \
    QT_X11_NO_MITSHM=1 \
    LANG=C.UTF-8

# ===== Runtime Dependencies =====
RUN apk add --no-cache \
        ca-certificates \
        fuse \
        dbus \
        qt5-qtbase \
        qt5-qtmultimedia \
        qt5-qtdeclarative \
        qt5-qtsvg \
        qt5-qtbase-x11 \
        libstdc++ \
        xterm \
        wget \
        unzip

# ===== Add rclone (Teldrive version) =====
ARG ARCH=amd64
ARG RCLONE_VERSION=v1.71.0
RUN wget -qO /tmp/rclone.zip "https://github.com/tgdrive/rclone/releases/download/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip" \
    && unzip -q /tmp/rclone.zip -d /tmp \
    && mv /tmp/rclone-*-linux-${ARCH}/rclone /usr/bin/rclone \
    && chmod +x /usr/bin/rclone \
    && rm -rf /tmp/rclone*

# ===== Download Rclone Browser binary =====
# ใช้ release zip ตรง ๆ จาก GitHub
ARG RCLONE_BROWSER_URL="https://github.com/totza2010/RcloneBrowser/releases/download/release-bb5c8721/linux.zip"

RUN wget -qO /tmp/rclone-browser.zip "$RCLONE_BROWSER_URL" \
    && unzip -q /tmp/rclone-browser.zip -d /tmp/rclone-browser \
    && mv /tmp/rclone-browser/linux/rclone-browser /usr/bin/rclone-browser \
    && chmod +x /usr/bin/rclone-browser \
    && rm -rf /tmp/rclone-browser*

# ===== Copy rootfs and VERSION =====
COPY rootfs/ /
COPY VERSION /
COPY rootfs/startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

# ===== Icon =====
COPY rootfs/icons/rclone-browser.png /usr/share/icons/hicolor/512x512/apps/rclone-browser.png

# ===== Mount Points =====
VOLUME ["/config", "/media"]

# ===== Healthcheck =====
HEALTHCHECK CMD pgrep -f rclone-browser || exit 1

# ===== Metadata =====
LABEL \
    org.label-schema.name="rclonebrowser" \
    org.label-schema.description="Custom RcloneBrowser (Qt5 + Teldrive edition)" \
    org.label-schema.version="${RCLONE_VERSION}" \
    org.label-schema.vcs-url="https://github.com/totza2010/RcloneBrowser" \
    org.label-schema.schema-version="1.0"
