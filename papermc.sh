#!/bin/bash
set -euo pipefail

# Функция для остановки сервера
stop_server() {
  echo "Остановка сервера..."
  tmux send-keys -t paper "stop" Enter
  exit 0
}

# Регистрируем обработчик SIGTERM
trap stop_server SIGTERM

MC_VERSION=${MC_VERSION:-latest}
PAPER_BUILD=${PAPER_BUILD:-latest}

API_URL="https://api.papermc.io/v2/projects/paper"

[[ "$MC_VERSION" == "latest" ]] && 
  MC_VERSION=$(wget -qO - $API_URL | jq -r '.versions[-1]')

[[ "$PAPER_BUILD" == "latest" ]] && 
  PAPER_BUILD=$(wget -qO - "$API_URL/versions/$MC_VERSION" | jq -r '.builds[-1]')

JAR="paper-$MC_VERSION-$PAPER_BUILD.jar"
[ ! -f "$JAR" ] && 
  wget "$API_URL/versions/$MC_VERSION/builds/$PAPER_BUILD/downloads/$JAR"

echo "eula=${EULA:-false}" > eula.txt

# exec java -Xms${MC_RAM:-1024M} -Xmx${MC_RAM:-1024M} -jar "$JAR" nogui

# Запуск сервера в tmux
if ! tmux has-session -t paper 2>/dev/null; then
  tmux new-session -d -s paper \
    "java -Xms${MC_RAM:-1024M} -Xmx${MC_RAM:-1024M} -jar '$JAR' nogui"
fi

# Мониторинг сессии
while tmux has-session -t paper 2>/dev/null; do
  sleep 10
done