FROM debian:trixie

SHELL ["/bin/bash", "-c"]

# Prepare our package system
RUN dpkg --add-architecture i386 && \
    sed -i 's/^Components: main$/& contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources && \
    apt-get update

ARG DEBIAN_FRONTEND="noninteractive"

# Install packages
RUN apt-get install --assume-yes --no-install-recommends git make ca-certificates cabextract wine wine32 wine64 libwine libwine:i386 fonts-wine wget winbind xserver-xorg-core xvfb psmisc && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt-get install --assume-yes steamcmd && \
    apt-get clean --assume-yes && \
    rm -rf /tmp/* /var/tmp/*

# Prepare winetricks
RUN apt-get remove --assume-yes winetricks && \ 
    git clone https://github.com/Winetricks/winetricks.git && \
    cd winetricks && \
    make install

# Prepare Wine environment
RUN mkdir /wine /wine/redist /wine/steamapps /wine/prefix

# Install redistributables and update steamcmd
RUN Xvfb :2 -core -nolisten tcp & \
    DISPLAY=:2 WINEPREFIX=/wine/prefix winetricks -q --force win10 && \
    DISPLAY=:2 WINEPREFIX=/wine/prefix winetricks -q --force vcrun2022 dotnet9 && \
    killall Xvfb

# Clean up, remove stuff we don't need to run the server
RUN apt-get remove --assume-yes git make xorg xserver-xorg-core xvfb fonts-wine psmisc cabextract winetricks && \
    apt-get autoremove --assume-yes && \
    apt-get clean --assume-yes && \
    rm -rf /tmp/* /var/tmp/*

# Give all users access to the SteamApps foldeer and wine prefix, just in case another user is meant to use this
RUN chmod -R 777 /wine/steamapps && chmod -R 777 /wine/prefix

# Prepare sbox-server (we won't install it here during the build)
ADD sbox-server.sh /usr/local/bin/sbox-server
ADD sbox-server-no-update.sh /usr/local/bin/sbox-server-no-update
ADD update-sbox-server.sh /usr/local/bin/update-sbox-server

# Fix Windows-isms
RUN apt-get install --assume-yes dos2unix && \
    dos2unix /usr/local/bin/sbox-server && \
    dos2unix /usr/local/bin/sbox-server-no-update && \
    dos2unix /usr/local/bin/update-sbox-server

RUN chmod +x /usr/local/bin/sbox-server && chmod +x /usr/local/bin/sbox-server-no-update && chmod +x /usr/local/bin/update-sbox-server

ENTRYPOINT ["bash", "-c", "/usr/local/bin/sbox-server"]
