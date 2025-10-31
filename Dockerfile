#
# Custom Rclone Browser (Qt5 + Teldrive edition)
#

# =========================
# ==== RUNTIME STAGE ======
# =========================
FROM jlesage/baseimage-gui:alpine-3.12-glibc

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

# ===== Download Rclone Browser binary (จาก GitHub Release) =====
# ✅ โหลด binary ล่าสุดอัตโนมัติจากโปรเจกต์ totza2010/RcloneBrowser
RUN wget -qO /usr/bin/rclone-browser \
    $(wget -qO- https://api.github.com/repos/totza2010/RcloneBrowser/releases/latest \
      | grep "browser_download_url" \
      | grep -E "rclone-browser(_x86_64)?$" \
      | head -n 1 \
      | cut -d '"' -f 4) \
    && chmod +x /usr/bin/rclone-browser

# ===== Copy rootfs and VERSION =====
COPY rootfs/ /
COPY VERSION /

# ===== UI Tweak =====
RUN sed -i 's/<application type="normal">/<application type="normal" title="Rclone Browser">/' /etc/xdg/openbox/rc.xml

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
