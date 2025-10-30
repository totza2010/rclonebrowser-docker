#
# Custom RcloneBrowser (Qt5 + Teldrive build)
#

# =========================
# ==== BUILD STAGE ========
# =========================
FROM alpine:3.20 AS build

ARG ARCH=amd64
ARG RCLONE_VERSION=v1.71.0
ARG RCLONE_URL="https://github.com/tgdrive/rclone/releases/download/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip"

# ติดตั้ง dependencies ที่จำเป็นสำหรับ build
RUN apk add --no-cache --virtual .build-deps \
        build-base \
        cmake \
        git \
        wget \
        unzip \
        qt5-qtbase-dev \
        qt5-qtmultimedia-dev \
        qt5-qttools-dev \
        qt5-qtdeclarative-dev \
        qt5-qtsvg-dev \
        qt5-qtbase-x11

# ดาวน์โหลด rclone (Teldrive)
RUN wget -qO /tmp/rclone.zip "${RCLONE_URL}" \
    && unzip -q /tmp/rclone.zip -d /tmp \
    && mv /tmp/rclone-*-linux-${ARCH}/rclone /usr/local/bin/ \
    && chmod +x /usr/local/bin/rclone \
    && rm -rf /tmp/rclone*

# ดึงซอร์สโค้ดของคุณ
WORKDIR /tmp/src
RUN git clone https://github.com/totza2010/RcloneBrowser.git . \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc) \
    && strip build/rclone-browser

# =========================
# ==== RUNTIME STAGE ======
# =========================
FROM jlesage/baseimage-gui:alpine-3.20-glibc

# สภาพแวดล้อม GUI
ENV APP_NAME="RcloneBrowser" \
    S6_KILL_GRACETIME=8000 \
    QT_X11_NO_MITSHM=1 \
    LANG=C.UTF-8

# ติดตั้ง runtime dependencies เท่านั้น
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
    && rm -rf /var/cache/apk/*

# คัดลอกไฟล์จาก build stage
COPY --from=build /usr/local/bin/rclone /usr/bin/rclone
COPY --from=build /tmp/src/build/build/rclone-browser /usr/bin/rclone-browser

COPY rootfs/ /
COPY VERSION /

# ปรับแต่ง Openbox window title
RUN sed -i 's/<application type="normal">/<application type="normal" title="Rclone Browser">/' \
        /etc/xdg/openbox/rc.xml

# เพิ่มไอคอนแอพ
RUN APP_ICON_URL="https://github.com/rclone/rclone/raw/master/graphics/logo/logo_symbol/logo_symbol_color_512px.png" \
    && install_app_icon.sh "$APP_ICON_URL"

# เพิ่ม user ปลอดภัย (ไม่ใช้ root)
RUN adduser -D appuser \
    && mkdir -p /config /media \
    && chown -R appuser:appuser /config /media

USER appuser

# Mount points
VOLUME ["/config", "/media"]

# Healthcheck
HEALTHCHECK CMD pgrep -f rclone-browser || exit 1

# Metadata
LABEL \
    org.label-schema.name="rclonebrowser" \
    org.label-schema.description="Custom RcloneBrowser (Qt5 + Teldrive edition)" \
    org.label-schema.version="${RCLONE_VERSION}" \
    org.label-schema.vcs-url="https://github.com/totza2010/RcloneBrowser" \
    org.label-schema.schema-version="1.0"
