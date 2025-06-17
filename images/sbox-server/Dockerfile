FROM debian:trixie-slim AS builder

ARG DEBIAN_FRONTEND="noninteractive"
ARG SBOX_BETA="public"

RUN apt update && \
    dpkg --add-architecture i386 && \
    sed -i 's/^Components: main$/& contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources && \
    apt update

# Install packages
RUN apt-get install --assume-yes --no-install-recommends git make ca-certificates cabextract wine wine32 wine64 libwine libwine:i386 fonts-wine wget winbind xserver-xorg-core xvfb xauth psmisc && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt-get install --assume-yes steamcmd && \
    apt-get clean --assume-yes && \
    rm -rf /tmp/* /var/tmp/*

# Install winetricks
RUN apt-get remove --assume-yes winetricks && \ 
    git clone https://github.com/Winetricks/winetricks.git && \
    cd winetricks && \
    make install

# Prepare Wine environment
RUN mkdir -p /work && cd /work && \
    WINEPREFIX=/work/wineprefix xvfb-run winetricks -q --force win10 vcrun2022 dotnet9

# Prepare server install
RUN mkdir -p /work/server && \
    /usr/games/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir /work/server +login anonymous +app_update 1892930 validate -beta $SBOX_BETA +quit

# Clean up Wine install
RUN rm -rf "/work/wineprefix/drive_c/ProgramData/Package Cache"

## Move to the runtime image
FROM alpine:edge

# Create a user
RUN adduser -D -g "steam" steam && \
    echo "steam ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    apk add wine gnutls && \
    apk cache clean && \
    # Manual (package breaking) cleaning
    rm -rf /usr/lib/libLLVM* && \
    rm -rf /usr/lib/libgallium* && \
    rm -rf /usr/lib/gallium-pipe

# Copy artifacts to the new user
COPY --from=builder --chown=steam:steam --chmod=777 /work/wineprefix /home/steam/.wine
COPY --from=builder --chown=steam:steam --chmod=777 /work/server /home/steam/server

# Switch to the new user
USER steam

ENV WINEDEBUG=-all
ENV XDG_RUNTIME_DIR=/tmp

# Make sure our prefix is ready
RUN wine "" || true

# Prepare start script
RUN echo "#!/bin/ash" >> ~/start-server.sh && \
    echo "wine ~/server/sbox-server.exe \$@" >> ~/start-server.sh && \
    chmod +x ~/start-server.sh && \
    cd ~

ENTRYPOINT ["/home/steam/start-server.sh"]