FROM jlesage/baseimage-gui:alpine-3.16-v4

# Define build arguments
ARG RCLONE_VERSION=1.71.0

# Define environment variables
ENV ARCH=amd64

# Define working directory.
WORKDIR /tmp

# Install Rclone Browser dependencies
RUN apk --no-cache add \
      ca-certificates \
      fuse \
      wget \
      qt6-qtbase \
      qt6-qtmultimedia \
      qt6-qtbase-x11 \
      dbus \
      xterm \
    && cd /tmp \
    && wget -q https://github.com/tgdrive/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-${ARCH}.zip \
    && unzip /tmp/rclone-v${RCLONE_VERSION}-linux-${ARCH}.zip \
    && mv /tmp/rclone-*-linux-${ARCH}/rclone /usr/bin \
    && rm -r /tmp/rclone* \
    && apk add --no-cache --virtual=build-dependencies \
        build-base \
        cmake \
        make \
        gcc \
        git \
        qt6-qtbase-dev \
        qt6-qtmultimedia-dev \
# Compile RcloneBrowser
    git clone https://github.com/kapitainsky/RcloneBrowser.git /tmp && \
    && mkdir /tmp/build \
    && cd /tmp/build \
    && cmake .. \
    && cmake --build . \
    && ls -l /tmp/build \
    && cp /tmp/build/build/rclone-browser /usr/bin \
# cleanup
    && apk del --purge build-dependencies \
    && rm -rf /tmp/*

# Maximize only the main/initial window.
RUN \
    sed-patch 's/<application type="normal">/<application type="normal" title="Rclone Browser">/' \
        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/rclone/rclone/raw/master/graphics/logo/logo_symbol/logo_symbol_color_512px.png \
    && install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY VERSION /

# Set environment variables.
ENV APP_NAME="RcloneBrowser" \
    S6_KILL_GRACETIME=8000

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/media"]

# Metadata.
LABEL \
      org.label-schema.name="rclonebrowser" \
      org.label-schema.description="Docker container for RcloneBrowser" \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/totza2010/rclonebrowser-docker" \
      org.label-schema.schema-version="1.0"