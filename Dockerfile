FROM debian:bookworm

# Prepare our package system
RUN dpkg --add-architecture i386 && \
    sed -i 's/^Components: main$/& contrib non-free/' /etc/apt/sources.list.d/debian.sources && \
    apt-get update

ARG DEBIAN_FRONTEND="noninteractive"

# Install packages
RUN apt-get install --assume-yes --no-install-recommends ca-certificates cabextract wine wine32 wine64 libwine libwine:i386 fonts-wine winetricks wget winbind xserver-xorg-core xvfb psmisc && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt-get install --assume-yes steamcmd && \
    apt-get clean --assume-yes && \
    rm -rf /tmp/* /var/tmp/*

# Prepare Wine environment
RUN mkdir /wine /wine/redist /wine/steamapps /wine/prefix

WORKDIR /wine/redist
RUN wget https://aka.ms/vs/17/release/vc_redist.x86.exe && \
    wget https://aka.ms/vs/17/release/vc_redist.x64.exe && \
    wget https://download.visualstudio.microsoft.com/download/pr/38e45a81-a6a4-4a37-a986-bc46be78db16/33e64c0966ebdf0088d1a2b6597f62e5/dotnet-sdk-9.0.101-win-x64.exe

# Install redistributables and update steamcmd
RUN <<EOF
Xvfb :2 -core -nolisten tcp &
DISPLAY=:2 WINEPREFIX=/wine/prefix wine vc_redist.x64.exe /install /norestart /passive /log redist.x64.log.txt
DISPLAY=:2 WINEPREFIX=/wine/prefix wine vc_redist.x86.exe /install /norestart /passive /log redist.x86.log.txt
DISPLAY=:2 WINEPREFIX=/wine/prefix wine dotnet-sdk-9.0.101-win-x64.exe /install /quiet /norestart
/usr/games/steamcmd +quit
killall Xvfb
EOF

# Clean up, remove stuff we don't need to run the server
RUN apt-get remove --assume-yes xorg xserver-xorg-core xvfb fonts-wine psmisc cabextract winetricks && \
    apt-get autoremove --assume-yes && \
    apt-get clean --assume-yes && \
    rm -rf /tmp/* /var/tmp/*

# Copy log files
RUN mv redist.x86.log.txt /wine/ && \
    mv redist.x64.log.txt /wine/ && \
    rm -r /wine/redist

# Give all users access to the SteamApps foldeer and wine prefix, just in case another user is meant to use this
RUN chmod -R 777 /wine/steamapps && chmod -R 777 /wine/prefix

# Prepare sbox-server (we won't install it here during the build)
ADD ./sbox-server /usr/local/bin/sbox-server
ADD ./sbox-server-no-update /usr/local/bin/sbox-server-no-update
ADD ./update-sbox-server /usr/local/bin/update-sbox-server
RUN chmod +x /usr/local/bin/sbox-server && chmod +x /usr/local/bin/sbox-server-no-update && chmod +x /usr/local/bin/update-sbox-server

ENTRYPOINT ["bash", "-c", "/usr/local/bin/sbox-server"]
