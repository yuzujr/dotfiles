# dotfiles

Personal dotfiles for Niri and KDE Plasma, managed by [chezmoi](https://github.com/twpayne/chezmoi).

## Quick Start

```bash
./dot.sh apply
./dot.sh diff
./dot.sh managed
```

By default, `dot.sh` manages this repository only.
Default source resolution is:

1. current directory
2. extra sources listed in `.dot.sh.repos` (if present)

## Extra Sources (Optional)

If you want to apply multiple sources in order, create a local source list file
in your current directory:

```bash
cp .dot.sh.repos.example .dot.sh.repos
```

Then `./dot.sh apply` will apply:

1. current directory
2. each listed source

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
