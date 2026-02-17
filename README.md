# dotfiles

Personal dotfiles for Niri and KDE Plasma, managed by **chezmoi**.

## Quick Start

```bash
./dot.sh apply
./dot.sh diff
./dot.sh managed
```

By default, `dot.sh` manages this repository only.

## Local Private Overlay (Optional)

If you also keep a private dotfiles repo locally, create a local source list
file in this repo root:

```bash
cp .dot.sh.repos.example .dot.sh.repos
```

Then `./dot.sh apply` will apply:

1. This public repo
2. Your private repo

`.dot.sh.repos` is intentionally local-only and ignored by git.

## dot.sh Interface

```bash
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
```

Examples:

```bash
./dot.sh apply ~/Templates/dotfiles-private
./dot.sh apply ~/Templates/dotfiles ~/Templates/dotfiles-private
./dot.sh apply home:/tmp/alt-home-source root:/tmp/alt-root-source
./dot.sh list
```
