FROM cm2network/steamcmd:root

LABEL maintainer="TonyProx" \
      version="1.0" \
      description="Servidor dedicado para Core Keeper usando SteamCMD" \
      org.opencontainers.image.source="https://github.com/TonyProx/CK-DS-Docker"

# Instalar dependencias de X11, Mesa/OpenGL moderno, Xvfb y Unity
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libsqlite3-0 \
    libudev1 \
    libglu1-mesa \
    libgl1 \
    libglx-mesa0 \
    libmesa-dri \
    libxcursor1 \
    libxrandr2 \
    libxi6 \
    libgdiplus \
    libglib2.0-0t64 \
    xvfb \
    xauth \
    procps \
    curl \
    || (apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates libsqlite3-0 libudev1 libglu1-mesa libgl1 libxcursor1 libxrandr2 libxi6 libgdiplus libglib2.0-0 xvfb xauth procps curl)
        
        RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
        jq \
        && rm -rf /var/lib/apt/lists/*


# Crear directorio de socket X11 con permisos adecuados
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

ENV STEAMAPPID=1963720 \
    STEAMAPP=corekeeper \
    STEAMAPPDIR=/home/steam/corekeeper-dedicated \
    WORLD_NAME=CoreKeeperServer \
    WORLD_INDEX=0 \
    MAX_PLAYERS=12

WORKDIR /home/steam

COPY entrypoint.sh /home/steam/entrypoint.sh
RUN chmod +x /home/steam/entrypoint.sh && chown -R steam:steam /home/steam

USER steam

EXPOSE 27015/udp 27016/udp 27015/tcp

ENTRYPOINT ["/home/steam/entrypoint.sh"]