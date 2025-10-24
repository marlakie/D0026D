#!/usr/bin/env bash
set -euo pipefail

# === Konfig ===
SRC="$HOME/"                                       # allt i hemkatalogen på Pi
DEST_USER="marla"                               # användaren på datorn
DEST_HOST="192.168.214.165"                         # IP för dator
DEST_BASE="/home/marla/backups/pi_home"         # backupmål på datorn
DATE="$(date +%F_%H%M%S)"
LOG_DIR="$HOME/logs"
SSH_OPTS="-o BatchMode=yes -o StrictHostKeyChecking=accept-new"

mkdir -p "$LOG_DIR"

# Skapa målmappar på backupdatorn om de saknas
ssh $SSH_OPTS "${DEST_USER}@${DEST_HOST}" "mkdir -p '${DEST_BASE}/.deleted/${DATE}'"

# Kör rsync
rsync -avh \
  --delete \
  --backup --backup-dir="${DEST_BASE}/.deleted/${DATE}" \
  --exclude=".cache/" \
  --exclude="Trash/" \
  --exclude=".local/share/Trash/" \
  --exclude="*.tmp" \
  -e "ssh $SSH_OPTS" \
  "$SRC" "${DEST_USER}@${DEST_HOST}:${DEST_BASE}" | tee -a "$LOG_DIR/home_backup.log"

echo "Backup klar: ${DATE}" | tee -a "$LOG_DIR/home_backup.log"
