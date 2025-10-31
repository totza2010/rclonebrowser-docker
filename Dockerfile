FROM jlesage/baseimage-gui:alpine-3.12-glibc

ENV APP_NAME="RcloneBrowser" \
    S6_KILL_GRACETIME=8000

RUN apk add --no-cache ca-certificates fuse dbus \
        qt5-qtbase qt5-qtmultimedia qt5-qtdeclarative qt5-qtsvg qt5-qtbase-x11 \
        libstdc++ xterm wget unzip \
    && rm -rf /var/cache/apk/*

VOLUME ["/config", "/media", "/bin_override"]

# Environment variables สำหรับเลือก binary
ENV RCLONE_BIN="/bin_override/rclone" \
    RCLONE_BROWSER_BIN="/bin_override/rclone-browser" \
    RCLONE_BROWSER_URL="https://github.com/totza2010/RcloneBrowser/releases/download/release-bb5c8721/linux.zip" \
    RCLONE_URL=""

# copy binary override หรือดาวน์โหลด ถ้า URL มีค่า
RUN sh -c '\
    if [ -f "$RCLONE_BROWSER_BIN" ]; then \
        cp "$RCLONE_BROWSER_BIN" /usr/bin/rclone-browser && chmod +x /usr/bin/rclone-browser; \
    elif [ -n "$RCLONE_BROWSER_URL" ]; then \
        TMPDIR=$(mktemp -d) && \
        wget -qO "$TMPDIR/archive.zip" "$RCLONE_BROWSER_URL" && \
        unzip -q "$TMPDIR/archive.zip" -d "$TMPDIR" && \
        # ค้นหาไฟล์ rclone-browser ภายในโฟลเดอร์ unzip (รวม subfolder)
        find "$TMPDIR" -type f -name "rclone-browser" -exec cp {} /usr/bin/rclone-browser \; && \
        chmod +x /usr/bin/rclone-browser && \
        rm -rf "$TMPDIR"; \
    fi \
'

COPY rootfs/ /
COPY VERSION /

RUN sed -i 's/<application type="normal">/<application type="normal" title="Rclone Browser">/' /etc/xdg/openbox/rc.xml
COPY rootfs/icons/rclone-browser.png /usr/share/icons/hicolor/512x512/apps/rclone-browser.png

HEALTHCHECK CMD pgrep -f rclone-browser || exit 1
