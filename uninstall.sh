#!/usr/bin/env bash

set -u

# -------------------- args --------------------
DRY_RUN=0
ARGS=()
for a in "$@"; do
  case "$a" in
    --dry-run|-n) DRY_RUN=1 ;;
    *) ARGS+=("$a") ;;
  esac
done

SCRIPT_PATH="$(readlink -f -- "${BASH_SOURCE[0]}")"
SCRIPT_BASENAME="$(basename -- "$SCRIPT_PATH")"
SCRIPT_DIR="$(cd -- "$(dirname -- "$SCRIPT_PATH")" &>/dev/null && pwd)"
SRC_ROOT_RAW="${ARGS[0]:-$SCRIPT_DIR}"
SRC_ROOT="$(readlink -f -- "$SRC_ROOT_RAW")"

if [[ ! -d "$SRC_ROOT" ]]; then
  echo "ERROR: Source directory not found: $SRC_ROOT" >&2
  exit 1
fi

# Safety guard: root directory name must be exactly 'dotfiles'
if [[ "$(basename -- "$SRC_ROOT")" != "dotfiles" ]]; then
  echo "ERROR: SRC_ROOT basename must be 'dotfiles' (got '$(basename -- "$SRC_ROOT")'). Abort." >&2
  exit 1
fi

CONFIG_HOME="${HOME}/.config"
mkdir -p "$CONFIG_HOME"

declare -A LINKMAP  # name -> target root
declare -A IGNORE   # name -> 1

# -------------------- helpers --------------------
canon() {
  if command -v realpath >/dev/null 2>&1; then
    realpath -m -- "$1"
  else
    readlink -f -- "$1" 2>/dev/null || printf '%s' "$1"
  fi
}

expand_path() {
  local p="$1"
  [[ "$p" == "~"* ]] && p="${p/#\~/$HOME}"
  p="${p//\$HOME/$HOME}"
  printf '%s' "$p"
}

# -------------------- linkmap --------------------
LINKMAP_FILE="${SRC_ROOT}/linkmap.txt"
if [[ -f "$LINKMAP_FILE" ]]; then
  while IFS= read -r raw; do
    raw="${raw%$'\r'}"
    line="$(echo "$raw" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    name="" target_root=""
    if [[ "$line" == \"*\"*\"* ]]; then
      tmp="${line#\"}"; name="${tmp%%\"*}"; rest="${tmp#*\"}"
      target_root="$(echo "$rest" | sed -e 's/^[[:space:]]*//')"
    else
      name="${line%%[[:space:]]*}"
      target_root="${line#"$name"}"; target_root="$(echo "$target_root" | sed -e 's/^[[:space:]]*//')"
    fi
    [[ -z "$name" || -z "$target_root" ]] && continue

    name="$(echo "$name" | xargs)"
    target_root="$(expand_path "$target_root")"
    LINKMAP["$name"]="$target_root"
  done < "$LINKMAP_FILE"
fi

# -------------------- ignore --------------------
IGNORE_FILE="${SRC_ROOT}/ignore.txt"
if [[ -f "$IGNORE_FILE" ]]; then
  while IFS= read -r raw; do
    raw="${raw%$'\r'}"
    line="$(echo "$raw" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    if [[ "$line" == \"*\"*\"* ]]; then
      tmp="${line#\"}"; name="${tmp%%\"*}"
    else
      name="$line"
    fi
    name="$(echo "$name" | xargs)"
    IGNORE["$name"]=1
  done < "$IGNORE_FILE"
fi

# Always ignore this script by name (if placed in root)
IGNORE["$SCRIPT_BASENAME"]=1

# -------------------- core --------------------
remove_if_matches() {
  local src="$1" dst="$2"

  # Show intended action
  printf 'rm -v -- "%s"\n' "$dst"

  if [[ -L "$dst" ]]; then
    local existing; existing="$(readlink -- "$dst")"
    if [[ "$(canon "$existing")" == "$(canon "$src")" ]]; then
      if [[ $DRY_RUN -eq 1 ]]; then
        echo "[dry-run] would remove"
      else
        rm -v -- "$dst"
      fi
    else
      echo "  -> skip (symlink points elsewhere: $(canon "$existing"))"
    fi
  else
    if [[ -e "$dst" ]]; then
      echo "  -> skip (not a symlink)"
    else
      echo "  -> skip (destination not found)"
    fi
  fi
}

echo "SRC_ROOT: $SRC_ROOT"
[[ -f "$LINKMAP_FILE" ]] && echo "linkmap: detected" || echo "linkmap: not provided (default ~/.config)"
[[ -f "$IGNORE_FILE" ]] && echo "ignore:  detected" || echo "ignore:  not provided"
[[ $DRY_RUN -eq 1 ]] && echo "mode:     DRY-RUN (no changes)"
echo

# Directories
while IFS= read -r -d '' dir; do
  name="$(basename -- "$dir")"
  [[ ${IGNORE[$name]:-} ]] && continue
  target_root="${LINKMAP[$name]:-$CONFIG_HOME}"
  dst="${target_root}/${name}"
  remove_if_matches "$dir" "$dst"
  echo
done < <(find "$SRC_ROOT" -mindepth 1 -maxdepth 1 -type d -print0)

# Files
while IFS= read -r -d '' file; do
  base="$(basename -- "$file")"
  [[ ${IGNORE[$base]:-} ]] && continue
  target_root="${LINKMAP[$base]:-$CONFIG_HOME}"
  dst="${target_root}/${base}"
  remove_if_matches "$file" "$dst"
  echo
done < <(find "$SRC_ROOT" -mindepth 1 -maxdepth 1 -type f -print0)

echo "Done."
