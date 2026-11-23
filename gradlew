#!/usr/bin/env sh
# Мини-загрузчик Gradle: скачивает версию из gradle/wrapper/gradle-wrapper.properties и запускает её.
set -e
APP_HOME=$(cd "$(dirname "$0")" && pwd -P)
URL=$(grep '^distributionUrl=' "$APP_HOME/gradle/wrapper/gradle-wrapper.properties" | cut -d= -f2- | tr -d '\\' | tr -d '\r')
NAME=$(basename "$URL" -bin.zip)
BASE="${GRADLE_USER_HOME:-$HOME/.gradle}/bootstrap"
DIR="$BASE/$NAME"
if [ ! -f "$DIR/bin/gradle" ]; then
  mkdir -p "$BASE"
  ZIP="$BASE/$NAME-bin.zip"
  echo "Скачиваю $URL"
  if command -v curl >/dev/null 2>&1; then curl -fL -o "$ZIP" "$URL"; else wget -O "$ZIP" "$URL"; fi
  if command -v unzip >/dev/null 2>&1; then unzip -q -o "$ZIP" -d "$BASE"
  elif command -v busybox >/dev/null 2>&1; then busybox unzip -q -o "$ZIP" -d "$BASE"
  else python3 -c "import zipfile,sys;zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])" "$ZIP" "$BASE"; fi
  rm -f "$ZIP"
  chmod +x "$DIR/bin/gradle"
fi
exec sh "$DIR/bin/gradle" "$@"
