#!/usr/bin/env bash
# Lance le backend Laravel et l'app Flutter sur le meme reseau WiFi, pour
# tester avec un telephone physique branche en USB (mode debogage sans fil
# active) ou simplement connecte au meme WiFi que cette machine.
#
# Usage:
#   ./scripts/run-on-lan.sh            # backend + build/run sur le premier device Flutter trouve
#   ./scripts/run-on-lan.sh --backend-only   # demarre juste le backend sur le reseau local
#   ./scripts/run-on-lan.sh -d <device-id>   # cible un device precis (voir `flutter devices`)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOBILE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$(cd "$MOBILE_DIR/../backend" && pwd)"
BACKEND_PORT="${BACKEND_PORT:-8002}"

BACKEND_ONLY=0
DEVICE_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --backend-only) BACKEND_ONLY=1; shift ;;
    -d|--device) DEVICE_ID="$2"; shift 2 ;;
    *) echo "Argument inconnu: $1" >&2; exit 1 ;;
  esac
done

# --- 1. Detecter l'IP locale (celle sur le meme WiFi que le telephone) ---
detect_lan_ip() {
  if command -v ip >/dev/null 2>&1; then
    ip -4 route get 1.1.1.1 2>/dev/null | awk '{for (i=1;i<=NF;i++) if ($i=="src") print $(i+1)}' | head -n1
  fi
}

LAN_IP="$(detect_lan_ip)"
if [[ -z "${LAN_IP:-}" ]]; then
  echo "Impossible de detecter automatiquement l'IP locale." >&2
  echo "Trouvez-la vous-meme (ex: 'ip addr' ou parametres WiFi) et relancez avec:" >&2
  echo "  LAN_IP=192.168.x.x ./scripts/run-on-lan.sh" >&2
  LAN_IP="${LAN_IP:-}"
  if [[ -z "$LAN_IP" ]]; then exit 1; fi
fi

echo "==> IP locale detectee : $LAN_IP"
echo "==> Assurez-vous que le telephone est sur le MEME reseau WiFi que cette machine."
echo "==> Backend accessible depuis le telephone sur : http://$LAN_IP:$BACKEND_PORT/api/v1"
echo

# --- 2. Demarrer le backend Laravel, ecoute sur toutes les interfaces ---
cd "$BACKEND_DIR"
echo "==> Demarrage du backend Laravel (0.0.0.0:$BACKEND_PORT)..."
php artisan serve --host=0.0.0.0 --port="$BACKEND_PORT" > /tmp/validika-backend.log 2>&1 &
BACKEND_PID=$!
trap 'echo "==> Arret du backend (pid $BACKEND_PID)"; kill "$BACKEND_PID" 2>/dev/null || true' EXIT

sleep 1
if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
  echo "Le backend n'a pas demarre. Voir /tmp/validika-backend.log" >&2
  cat /tmp/validika-backend.log >&2
  exit 1
fi
echo "==> Backend demarre (pid $BACKEND_PID), logs dans /tmp/validika-backend.log"
echo

if [[ "$BACKEND_ONLY" -eq 1 ]]; then
  echo "==> Mode --backend-only : le backend tourne. Ctrl+C pour arreter."
  wait "$BACKEND_PID"
  exit 0
fi

# --- 3. Verifier qu'un device Flutter (telephone physique) est branche ---
cd "$MOBILE_DIR"
echo "==> Devices Flutter detectes :"
flutter devices || true
echo

if [[ -z "$DEVICE_ID" ]]; then
  echo "==> Aucun device precise (-d), Flutter choisira automatiquement s'il n'y en a qu'un."
  echo "    Sinon relancez avec : ./scripts/run-on-lan.sh -d <device-id>"
fi

echo "==> Lancement de l'app sur http://$LAN_IP:$BACKEND_PORT/api/v1 ..."
FLUTTER_ARGS=(run --dart-define=API_BASE_URL="http://$LAN_IP:$BACKEND_PORT/api/v1")
if [[ -n "$DEVICE_ID" ]]; then
  FLUTTER_ARGS+=(-d "$DEVICE_ID")
fi

flutter "${FLUTTER_ARGS[@]}"
