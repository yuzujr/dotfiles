#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${SOURCE_DIR:-${REPO:-$PWD}}"
DOT_REPOS="${DOT_REPOS:-}"
DOT_REPOS_FILE="${DOT_REPOS_FILE:-$PWD/.dot.sh.repos}"

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

expand_home() {
  local path="$1"
  if [[ $path == "~" ]]; then
    path="$HOME"
  elif [[ $path == "~/"* ]]; then
    path="$HOME/${path#\~/}"
  fi
  printf '%s' "$path"
}

contains_item() {
  local needle="$1"
  shift || true
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

source_has_files() {
  local src="$1"
  [[ -d "$src" ]] || return 1
  find "$src" -mindepth 1 \( -type f -o -type l \) -print -quit | grep -q .
}

print_home_target() {
  local src="$1"
  if [[ ! -d "$src" ]]; then
    echo "  home: missing ($src)"
    return 0
  fi
  if source_has_files "$src"; then
    echo "  home: $src -> \$HOME"
  else
    echo "  home: empty ($src, skip)"
  fi
}

print_root_target() {
  local src="$1"
  if [[ ! -d "$src" ]]; then
    echo "  root: missing ($src)"
    return 0
  fi
  if source_has_files "$src"; then
    echo "  root: $src -> /"
  else
    echo "  root: empty ($src, skip)"
  fi
}

run_home_source() {
  local src="$1"
  local action="$2"
  local label="$3"

  echo "=== home: $label ==="
  if [[ ! -d "$src" ]]; then
    echo "(skip: missing $src)"
    echo
    return 0
  fi

  if ! source_has_files "$src"; then
    echo "(skip: empty $src)"
    echo
    return 0
  fi

  chezmoi -S "$src" "$action"
  echo
}

run_root_source() {
  local src="$1"
  local action="$2"
  local label="$3"

  echo "=== root: $label -> / ==="
  if [[ ! -d "$src" ]]; then
    echo "(skip: missing $src)"
    echo
    return 0
  fi

  if ! source_has_files "$src"; then
    echo "(skip: empty $src)"
    echo
    return 0
  fi

  sudo chezmoi -S "$src" -D / "$action"
  echo
}

show_targets() {
  local path="$1"

  if [[ ! -e "$path" ]]; then
    echo "source: $path"
    echo "  missing: $path"
    return 0
  fi

  if [[ -d "$path/home" || -d "$path/root" ]]; then
    echo "source: $path"
    print_home_target "$path/home"
    print_root_target "$path/root"
    return 0
  fi

  echo "source: $path"
  print_home_target "$path"
}

run_source_spec() {
  local spec="$1"
  local action="$2"
  local mode="auto"
  local path="$spec"

  if [[ "$spec" == home:* ]]; then
    mode="home"
    path="${spec#home:}"
  elif [[ "$spec" == root:* ]]; then
    mode="root"
    path="${spec#root:}"
  fi

  path="$(expand_home "$path")"

  if [[ -z "$path" ]]; then
    echo "skip empty source in spec: $spec" >&2
    return 0
  fi

  case "$mode" in
  home)
    run_home_source "$path" "$action" "$path"
    ;;
  root)
    run_root_source "$path" "$action" "$path"
    ;;
  auto)
    if [[ -d "$path/home" || -d "$path/root" ]]; then
      run_home_source "$path/home" "$action" "$path/home"
      if [[ -d "$path/root" ]]; then
        run_root_source "$path/root" "$action" "$path/root"
      fi
    else
      run_home_source "$path" "$action" "$path"
    fi
    ;;
  *)
    echo "invalid mode in spec: $spec" >&2
    return 2
    ;;
  esac
}

resolve_specs() {
  local -n out_ref=$1
  shift

  local spec
  local -a tmp=()

  if [[ "$#" -gt 0 ]]; then
    tmp=("$@")
  elif [[ -n "$DOT_REPOS" ]]; then
    IFS=':' read -r -a tmp <<<"$DOT_REPOS"
  else
    tmp+=("$SOURCE_DIR")

    if [[ -f "$DOT_REPOS_FILE" ]]; then
      while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="$(trim "$line")"
        [[ -z "$line" ]] && continue
        tmp+=("$line")
      done <"$DOT_REPOS_FILE"
    fi
  fi

  out_ref=()
  for spec in "${tmp[@]}"; do
    spec="$(trim "$spec")"
    [[ -z "$spec" ]] && continue
    if ! contains_item "$spec" "${out_ref[@]}"; then
      out_ref+=("$spec")
    fi
  done
}

usage() {
  cat <<'EOF'
Usage: dot.sh <cmd> [source ...]

cmd:
  apply    Apply sources
  diff     Show source diffs
  re-add   Re-add changes from targets
  managed  List managed paths from targets
  list     Print resolved targets without running chezmoi

source:
  /path/to/repo          repo with optional home/ and root/ subdirs
  /path/to/source        plain chezmoi source (home target)
  home:/path/to/source   explicit home target
  root:/path/to/source   explicit / target (sudo)

When [source ...] is omitted:
  1) use SOURCE_DIR (default: current directory)
  2) append each non-empty line from DOT_REPOS_FILE (if it exists)

Env:
  SOURCE_DIR=... default source path (fallback: REPO, then current directory)
  REPO=... alias of SOURCE_DIR for compatibility
  DOT_REPOS=... colon-separated source list (overrides SOURCE_DIR + DOT_REPOS_FILE)
  DOT_REPOS_FILE=... optional source list file (default: $PWD/.dot.sh.repos)
EOF
}

cmd="${1:-}"
if [[ $# -gt 0 ]]; then
  shift
fi

declare -a specs=()
resolve_specs specs "$@"

case "$cmd" in
apply)
  for spec in "${specs[@]}"; do
    run_source_spec "$spec" apply
  done
  ;;
diff)
  for spec in "${specs[@]}"; do
    run_source_spec "$spec" diff
  done
  ;;
re-add)
  for spec in "${specs[@]}"; do
    run_source_spec "$spec" re-add
  done
  ;;
managed)
  for spec in "${specs[@]}"; do
    run_source_spec "$spec" managed
  done
  ;;
list)
  for spec in "${specs[@]}"; do
    local_mode="auto"
    local_path="$spec"
    if [[ "$spec" == home:* ]]; then
      local_mode="home"
      local_path="${spec#home:}"
    elif [[ "$spec" == root:* ]]; then
      local_mode="root"
      local_path="${spec#root:}"
    fi

    local_path="$(expand_home "$local_path")"
    case "$local_mode" in
    home)
      echo "source: $local_path [home-only]"
      print_home_target "$local_path"
      ;;
    root)
      echo "source: $local_path [root-only]"
      print_root_target "$local_path"
      ;;
    auto)
      show_targets "$local_path"
      ;;
    esac
    echo
  done
  ;;
-h | --help | help | "")
  usage
  exit 0
  ;;
*)
  echo "Unknown cmd: $cmd" >&2
  usage >&2
  exit 2
  ;;
esac
