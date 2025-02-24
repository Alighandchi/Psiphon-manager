#!/bin/bash

# لیست لوکیشن‌ها و پورت‌های شروع
LOCATIONS=("AT" "AU" "BE" "BG" "BR" "CA" "CH" "CZ" "DE" "DK" "EE" "ES" "FI" "FR" "GB" "GR" "HR" "HU" "ID" "IE" "IN" "IT" "JP" "LV" "LT" "NL" "NO" "PL" "PT" "RO" "RS" "SE" "SG" "SK" "UA" "US")
BASE_PORT=9001
BASE_DIR="/root/Psiphon-Server"
BIN_URL="https://raw.githubusercontent.com/Psiphon-Labs/psiphon-tunnel-core-binaries/master/linux/psiphon-tunnel-core-x86_64"

install_dependencies() {
    echo "Installing dependencies..."
    apt install -y tmux wget curl
}

setup_folders() {
    echo "Setting up directories..."
    mkdir -p "$BASE_DIR"
    for ((i=0; i<${#LOCATIONS[@]}; i++)); do
        PORT=$((BASE_PORT + i))
        LOC="${LOCATIONS[$i]}"
        LOC_DIR="$BASE_DIR/$LOC-$PORT"
        mkdir -p "$LOC_DIR"
        wget -q "$BIN_URL" -O "$LOC_DIR/psiphon-tunnel-core-x86_64-$LOC"
        chmod +x "$LOC_DIR/psiphon-tunnel-core-x86_64-$LOC"
        create_config "$LOC" "$PORT" "$LOC_DIR"
    done
}

create_config() {
    local LOC="$1"
    local PORT="$2"
    local LOC_DIR="$3"
    cat > "$LOC_DIR/psiphon.config" <<EOL
{
    "LocalSocksProxyPort":$PORT,
    "EgressRegion":"$LOC",
    "PropagationChannelId":"FFFFFFFFFFFFFFFF",
    "RemoteServerListDownloadFilename":"remote_server_list",
    "RemoteServerListSignaturePublicKey":"MIICIDANBgkqhkiG9w0BAQEFAAOCAg0AMIICCAKCAgEAt7Ls+/39r+T6zNW7GiVpJfzq/xvL9SBH5rIFnk0RXYEYavax3WS6HOD35eTAqn8AniOwiH+DOkvgSKF2caqk/y1dfq47Pdymtwzp9ikpB1C5OfAysXzBiwVJlCdajBKvBZDerV1cMvRzCKvKwRmvDmHgphQQ7WfXIGbRbmmk6opMBh3roE42KcotLFtqp0RRwLtcBRNtCdsrVsjiI1Lqz/lH+T61sGjSjQ3CHMuZYSQJZo/KrvzgQXpkaCTdbObxHqb6/+i1qaVOfEsvjoiyzTxJADvSytVtcTjijhPEV6XskJVHE1Zgl+7rATr/pDQkw6DPCNBS1+Y6fy7GstZALQXwEDN/qhQI9kWkHijT8ns+i1vGg00Mk/6J75arLhqcodWsdeG/M/moWgqQAnlZAGVtJI1OgeF5fsPpXu4kctOfuZlGjVZXQNW34aOzm8r8S0eVZitPlbhcPiR4gT/aSMz/wd8lZlzZYsje/Jr8u/YtlwjjreZrGRmG8KMOzukV3lLmMppXFMvl4bxv6YFEmIuTsOhbLTwFgh7KYNjodLj/LsqRVfwz31PgWQFTEPICV7GCvgVlPRxnofqKSjgTWI4mxDhBpVcATvaoBl1L/6WLbFvBsoAUBItWwctO2xalKxF5szhGm8lccoc5MZr8kfE0uxMgsxz4er68iCID+rsCAQM=",
    "RemoteServerListUrl":"https://s3.amazonaws.com//psiphon/web/mjr4-p23r-puwl/server_list_compressed",
    "SponsorId":"FFFFFFFFFFFFFFFF",
    "UseIndistinguishableTLS":true
}
EOL
}

start_tmux_session() {
    local LOC="$1"
    local PORT="$2"
    local LOC_DIR="$BASE_DIR/$LOC-$PORT"
    tmux new -d -s "$LOC" "cd $LOC_DIR && ./psiphon-tunnel-core-x86_64-$LOC -config ./psiphon.config"
    echo "Started Psiphon for $LOC on port $PORT"
}

stop_tmux_session() {
    local LOC="$1"
    tmux kill-session -t "$LOC"
    echo "Stopped Psiphon session: $LOC"
}

show_menu() {
    while true; do
        echo "\n=== Psiphon Server Manager ==="
        echo "1) Setup server"
        echo "2) Start all servers"
        echo "3) Stop all servers"
        echo "4) Show running sessions"
        echo "5) Exit"
        read -p "Select an option: " OPTION
        case $OPTION in
            1) install_dependencies; setup_folders ;;
            2) for ((i=0; i<${#LOCATIONS[@]}; i++)); do start_tmux_session "${LOCATIONS[$i]}" $((BASE_PORT + i)); done ;;
            3) for LOC in "${LOCATIONS[@]}"; do stop_tmux_session "$LOC"; done ;;
            4) tmux list-sessions ;;
            5) exit 0 ;;
            *) echo "Invalid option!" ;;
        esac
    done
}

# اجرای منو
echo "Starting Psiphon setup..."
show_menu
