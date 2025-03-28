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

echo "Starting PaperMC version ${MC_VERSION}, build ${PAPER_BUILD}"
echo "JVM options: ${JAVA_OPTS}"

exec java ${JAVA_OPTS} -jar "${JAR}" nogui
