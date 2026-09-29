#!/usr/bin/env bash
# Generate a Play upload keystore + android/key.properties (both gitignored).
# Do NOT commit the keystore or key.properties. Do NOT use Makefile android-release-keystore.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEYS_DIR="$ROOT/android/keys"
KEYSTORE="$KEYS_DIR/upload-keystore.jks"
PROPS="$ROOT/android/key.properties"
ALIAS="${KEY_ALIAS:-upload}"

if [[ -f "$KEYSTORE" && -f "$PROPS" ]]; then
  echo "Already present:"
  echo "  $KEYSTORE"
  echo "  $PROPS"
  echo "Delete them first if you need to regenerate."
  exit 0
fi

mkdir -p "$KEYS_DIR"

if [[ -z "${STORE_PASSWORD:-}" || -z "${KEY_PASSWORD:-}" ]]; then
  echo "Enter passwords for the upload keystore (not echoed)."
  read -r -s -p "storePassword: " STORE_PASSWORD
  echo
  read -r -s -p "keyPassword: " KEY_PASSWORD
  echo
fi

if [[ -z "$STORE_PASSWORD" || -z "$KEY_PASSWORD" ]]; then
  echo "STORE_PASSWORD and KEY_PASSWORD are required." >&2
  exit 1
fi

if [[ ! -f "$KEYSTORE" ]]; then
  keytool -genkey -v \
    -keystore "$KEYSTORE" \
    -storetype JKS \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$ALIAS" \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "${KEY_DNAME:-CN=HapoPay, OU=Mobile, O=HapoPay, L=Unknown, ST=Unknown, C=US}"
fi

cat > "$PROPS" <<EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$ALIAS
storeFile=keys/upload-keystore.jks
EOF

chmod 600 "$PROPS" "$KEYSTORE"
echo "Created:"
echo "  $KEYSTORE"
echo "  $PROPS"
echo "Keep backups of the keystore and passwords offline. Losing them blocks Play updates."
