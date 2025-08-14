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
declare -a SKIPPED_LIST=() # skipped directories

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

# Always ignore this script itself by name (if user copied it into root)
IGNORE["$SCRIPT_BASENAME"]=1

# -------------------- core --------------------
log_do() {
  # Print the command to be executed (or preview)
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    printf '%s\n' "$*"
    eval "$@"
  fi
}

link_one() {
  local src="$1" dst="$2"

  # Preview line
  printf 'ln -s "%s" "%s"\n' "$src" "$dst"

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ -L "$dst" ]]; then
      local existing; existing="$(readlink -- "$dst")"
      if [[ "$(canon "$existing")" == "$(canon "$src")" ]]; then
        echo "  -> ok (already linked)"
        return 0
      fi
    fi
    echo "  -> skip (destination exists and differs)"
    SKIPPED_LIST+=("$dst")
    return 0
  fi

  # Ensure parent exists and create the link
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] mkdir -p \"$(dirname -- "$dst")\""
    echo "[dry-run] ln -s -- \"$src\" \"$dst\""
  else
    mkdir -p -- "$(dirname -- "$dst")"
    ln -s -- "$src" "$dst"
    echo "  -> created"
  fi
}

echo "SRC_ROOT: $SRC_ROOT"
LINKMAP_COUNT=${#LINKMAP[@]}
IGNORE_COUNT=${#IGNORE[@]}

echo "linkmap: detected ($LINKMAP_COUNT entries)" && [[ ! -f "$LINKMAP_FILE" ]] && echo "linkmap: not provided (default ~/.config)"
echo "ignore:  detected ($IGNORE_COUNT entries)" && [[ ! -f "$IGNORE_FILE" ]] && echo "ignore:  not provided"
[[ $DRY_RUN -eq 1 ]] && echo "mode:    DRY-RUN (no changes)"
echo

# Directories
while IFS= read -r -d '' dir; do
  name="$(basename -- "$dir")"
  [[ ${IGNORE[$name]:-} ]] && continue
  target_root="${LINKMAP[$name]:-$CONFIG_HOME}"
  mkdir -p -- "$target_root"
  dst_path="${target_root}/${name}"
  link_one "$dir" "$dst_path"
  echo
done < <(find "$SRC_ROOT" -mindepth 1 -maxdepth 1 -type d -print0)

# Files
while IFS= read -r -d '' file; do
  base="$(basename -- "$file")"
  [[ ${IGNORE[$base]:-} ]] && continue
  target_root="${LINKMAP[$base]:-$CONFIG_HOME}"
  mkdir -p -- "$target_root"
  dst_path="${target_root}/${base}"
  link_one "$file" "$dst_path"
  echo
done < <(find "$SRC_ROOT" -mindepth 1 -maxdepth 1 -type f -print0)

if (( ${#SKIPPED_LIST[@]} > 0 )); then
  echo
  echo "Warning: The following items were skipped because destination exists and differs:"
  for item in "${SKIPPED_LIST[@]}"; do
    echo "  -  $item"
  done
  echo "If you want to replace them, remove the above items and re-run ./install.sh"
  echo
fi
echo "Done."
