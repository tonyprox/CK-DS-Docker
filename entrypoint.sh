#!/bin/bash
set -e

log_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

log_info "=== Iniciando contenedor de Core Keeper ==="

SERVER_BINARY="$STEAMAPPDIR/CoreKeeperServer"

if [ ! -f "$SERVER_BINARY" ]; then
    log_info "El binario del servidor no existe. Iniciando instalación limpia..."
    DO_UPDATE=true
else
    AUTO_UPDATE="${AUTO_UPDATE:-true}"
    if [ "$AUTO_UPDATE" = "true" ]; then
        log_info "AUTO_UPDATE está activo. Verificando actualizaciones..."
        DO_UPDATE=true
    else
        log_info "AUTO_UPDATE está desactivado. Saltando comprobación..."
        DO_UPDATE=false
    fi
fi

if [ "$DO_UPDATE" = "true" ]; then
    /home/steam/steamcmd/steamcmd.sh \
        +@sSteamCmdForcePlatformType linux \
        +force_install_dir "$STEAMAPPDIR" \
        +login anonymous \
        +app_update 1963720 validate \
        +quit || {
            log_error "SteamCMD encontró un error durante la actualización/instalación."
            exit 1
        }
    log_success "Instalación / Actualización completada con éxito."
else
    log_success "Usando versión existente del servidor local."
fi

cd "$STEAMAPPDIR"

LOG_FILE="$STEAMAPPDIR/CoreKeeperServerLog.txt"
touch "$LOG_FILE"

# --- SINCRONIZACIÓN DE CONFIGURACIÓN ---
CONFIG_DIR="/home/steam/.config/unity3d/Pugstorm/Core Keeper/DedicatedServer"
CONFIG_FILE="$CONFIG_DIR/ServerConfig.json"
mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    echo '{}' > "$CONFIG_FILE"
fi

update_json_val() {
    local key="$1"
    local val="$2"
    local is_num="${3:-false}"
    if [ -n "$val" ]; then
        if [ "$is_num" = true ]; then
            tmp=$(/usr/bin/jq --argjson v "$val" --arg k "$key" '.[$k] = $v' "$CONFIG_FILE")
        else
            tmp=$(/usr/bin/jq --arg v "$val" --arg k "$key" '.[$k] = $v' "$CONFIG_FILE")
        fi
        echo "$tmp" > "$CONFIG_FILE"
    fi
}

update_json_val "worldName" "${WORLD_NAME:-CoreKeeperServer}" false
update_json_val "world" "${WORLD_INDEX:-0}" true
update_json_val "maxNumberPlayers" "${MAX_PLAYERS:-12}" true
update_json_val "password" "${WORLD_PASSWORD:-}" false

if [ -n "$GAME_ID" ]; then
    if [[ "$GAME_ID" =~ ^[a-zA-Z0-9]{8,32}$ ]]; then
        update_json_val "gameId" "$GAME_ID" false
    fi
fi

xvfbpid=""
ckpid=""

function kill_corekeeperserver() {
    log_info "Deteniendo servidor de Core Keeper de forma ordenada..."
    if [[ ! -z "$ckpid" ]]; then kill $ckpid 2>/dev/null || true; wait $ckpid 2>/dev/null || true; fi
    if [[ ! -z "$xvfbpid" ]]; then kill $xvfbpid 2>/dev/null || true; wait $xvfbpid 2>/dev/null || true; fi
    log_success "Contenedor detenido correctamente."
}

trap kill_corekeeperserver EXIT INT TERM

rm -f GameInfo.txt
chmod +x ./CoreKeeperServer
rm -f /tmp/.X99-lock

Xvfb :99 -screen 0 1x1x24 -nolisten tcp &
xvfbpid=$!

ARGS=("-batchmode" "-logfile" "$LOG_FILE")
if [ -n "$WORLD_NAME" ]; then ARGS+=("-worldname" "$WORLD_NAME"); fi
if [ -n "$WORLD_INDEX" ]; then ARGS+=("-worldindex" "$WORLD_INDEX"); fi
if [ -n "$MAX_PLAYERS" ]; then ARGS+=("-maxplayers" "$MAX_PLAYERS"); fi
if [ -n "$WORLD_PASSWORD" ]; then ARGS+=("-password" "$WORLD_PASSWORD"); fi
if [ -n "$EXTRA_ARGS" ]; then ARGS+=($EXTRA_ARGS); fi

DISPLAY=:99 LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$STEAMAPPDIR/linux64/" \
    ./CoreKeeperServer "${ARGS[@]}" &
ckpid=$!

while [ ! -f GameInfo.txt ]; do sleep 0.1; done

log_success "=================================================="
log_success "       ¡SERVIDOR DE CORE KEEPER LISTO!           "
log_success "=================================================="
echo -e "\033[1;33mGAME ID:\033[0m \033[1;32;40m $(cat GameInfo.txt) \033[0m"
log_success "=================================================="

# --- VOLCADO NATIVO EN TIEMPO REAL SIN BÚFER (BASH READ LOOP) ---
tail -n 20 -F "$LOG_FILE" 2>/dev/null | while IFS= read -r line; do
    if [[ "$line" =~ player.*connected || "$line" =~ "Accepted connect" || "$line" =~ "Enabling player entity" || "$line" =~ "is using new name" || "$line" =~ "Started game for new connection" ]]; then
        echo -e "\033[1;32m[PLAYER-JOIN]\033[0m \033[1;32;40m ${line} \033[0m"
    elif [[ "$line" =~ "Started session" || "$line" =~ "GameID" || "$line" =~ "Listening on" ]]; then
        echo -e "\033[1;36m[SESSION]\033[0m \033[1;97;42m ${line} \033[0m"
    elif [[ "$line" =~ "WorldSave" || "$line" =~ "Allocating a new file write buffer" || "$line" =~ "ghost collection" ]]; then
        echo -e "\033[1;35m[SAVE]\033[0m \033[1;35m${line}\033[0m"
    elif [[ "$line" =~ "Read cartography" || "$line" =~ "Do not spawn" || "$line" =~ "ECSManager" || "$line" =~ "PugDatabase" || "$line" =~ "ConvertAuthoringDataRoutine" || "$line" =~ "timescale" || "$line" =~ "content bundle" ]]; then
        echo -e "\033[1;33m[WORLD]\033[0m \033[1;33m${line}\033[0m"
    elif [[ "$line" =~ [Ee]rror || "$line" =~ [Ee]xception || "$line" =~ [Ff]ailed || "$line" =~ mismatch ]]; then
        echo -e "\033[1;31m[ERROR/WARN]\033[0m \033[1;31m${line}\033[0m"
    else
        echo "$line"
    fi
done &
tailpid=$!

wait $ckpid
kill $tailpid 2>/dev/null || true