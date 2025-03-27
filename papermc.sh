#!/bin/bash
set -euo pipefail

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

shutdown() {
  echo "SIGTERM catched, stopping server..."
  tmux send-keys -t papermc "stop" C-m
}

trap shutdown SIGTERM

if tmux ls | grep -q "^papermc:"; then
  echo "tmux-session already exists."
else
  echo "Creating new tmux session and starting server..."
  tmux new-session -d -s papermc "exec java -Xms${MC_RAM:-1024M} -Xmx${MC_RAM:-1024M} ${JAVA_OPTS} -jar \"$JAR\" nogui"
fi

tmux pipe-pane -o -t papermc 'cat >> /proc/1/fd/1'

# Следим за процессом, чтобы контейнер не завершался
while tmux has-session -t papermc 2>/dev/null; do
  sleep 5
done

# echo "Attaching to tmux session..."
# tmux attach-session -t papermc
