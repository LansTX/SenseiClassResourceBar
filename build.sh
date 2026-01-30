#!/bin/bash
set -euo pipefail

# =========================
# CONFIG (BASE PATH)
# =========================

# Repo = directory where this script lives
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =========================
# LOAD .env
# =========================

ENV_FILE="$REPO/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env file not found at $ENV_FILE"
  exit 1
fi

# Load env vars (ignores comments and empty lines)
set -a
source <(grep -vE '^\s*#|^\s*$' "$ENV_FILE")
set +a

if [[ -z "${WOW_ADDONS_DIR:-}" ]]; then
  echo "ERROR: WOW_ADDONS_DIR not defined in .env"
  exit 1
fi

# =========================
# CONFIG
# =========================

RELEASE="$REPO/.release"
LIBEQOL="$REPO/Libs/LibEQOL"
BUILD="$RELEASE/SenseiClassResourceBar"
BUILD_LIBEQOL="$BUILD/Libs/LibEQOL"
TARGET="$WOW_ADDONS_DIR/SenseiClassResourceBar"

# =========================
# GO TO REPO
# =========================

cd "$REPO" || {
  echo "ERROR: Repo path not found."
  exit 1
}

# =========================
# ENSURE PACKAGER
# =========================

if [[ ! -f "$RELEASE/release.sh" ]]; then
  echo
  echo "=== Packager not found. Cloning BigWigs packager... ==="
  git clone https://github.com/BigWigsMods/packager "$RELEASE"
fi

# =========================
# ENSURE LibEQOL (v1.0.0)
# =========================

echo
echo "=== Installing LibEQOL v1.0.0 ==="

mkdir -p Libs
rm -rf libeqol.zip LibEQOL Libs/LibEQOL

curl -L -o libeqol.zip \
  https://github.com/R41z0r/LibEQOL/archive/refs/tags/v1.0.0.zip

unzip -q libeqol.zip
mv LibEQOL-1.0.0 LibEQOL
mv LibEQOL Libs/
rm -f libeqol.zip

echo "LibEQOL installed successfully."

# =========================
# BUILD
# =========================

echo
echo "=== Building release package ==="
bash "$RELEASE/release.sh"

# =========================
# VALIDATE BUILD
# =========================

if [[ ! -d "$BUILD" ]]; then
  echo
  echo "ERROR: Build folder not found:"
  echo "  $BUILD"
  exit 1
fi

# =========================
# INJECT LibEQOL INTO BUILD
# =========================

echo
echo "=== Injecting LibEQOL into build ==="

rm -rf "$BUILD_LIBEQOL"
mkdir -p "$(dirname "$BUILD_LIBEQOL")"
cp -a "$LIBEQOL" "$BUILD_LIBEQOL"

# =========================
# DEPLOY TO WOW
# =========================

echo
echo "=== Deploying addon to WoW ==="

rm -rf "$TARGET"
mkdir -p "$(dirname "$TARGET")"
cp -a "$BUILD" "$TARGET"


echo
echo "=============================="
echo "  DONE. Built + injected + deployed"
echo "=============================="
