FROM alpine:3.21

ARG PACKAGES=" \
    xvfb xvfb-run \
    xdotool \
    wine \
    shadow \
    gnutls \
    bash \
    inotify-tools \
    python3 py3-pip \
    curl \
    "

#
# Install wine and a few dependencies
#

RUN apk update && \
    apk add $PACKAGES && \
    pip install --break-system-packages fastapi uvicorn

#
# Create novetus user.
#

RUN useradd \
      -u 1000 -U \
      -d /home/novetus \
      -s /bin/bash novetus && \
    mkdir -p /home/novetus && \
    chown -R novetus:novetus /home/novetus && \
    usermod -G users novetus

#
# Setup wineprefix.
#

USER novetus

RUN export WINEPREFIX=/home/novetus/.wine && \
    WINEDLLOVERRIDES="mscoree,mshtml=" wineboot -u && \
    xvfb-run wine msiexec /i https://dl.winehq.org/wine/wine-mono/9.4.0/wine-mono-9.4.0-x86.msi && \
    wineserver -k && \
    wineboot -u

#
# Put the novetus launcher, launch scripts, default map and addons inside the container
#

COPY --chown=novetus:novetus --chmod=777 Launcher /Launcher
COPY --chown=novetus:novetus --chmod=777 defaults /defaults
COPY --chown=novetus:novetus --chmod=777 default.rbxl /default.rbxl
COPY --chown=novetus:novetus --chmod=777 addons /Launcher/data/addons
RUN touch /Launcher/data/config/servers.txt /Launcher/data/config/ports.txt

#
# Health Check, to ensure novetus server is still running.
#

HEALTHCHECK --interval=10s --timeout=2m --start-period=10s \
  CMD curl -f --retry 3 --max-time 3 --retry-delay 3 http://127.0.0.1:3000/health || bash -c 'kill -s 15 -1 && (sleep 10; kill -s 9 -1)'

ENTRYPOINT ["/defaults/start.sh"]
