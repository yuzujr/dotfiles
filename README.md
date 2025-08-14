# dotfiles

KDE + Hyprland personal dotfiles.

```bash
.
├── autostart
├── cava
├── fastfetch
├── fish
├── hypr
├── kitty
├── konsole
├── kwinrc
├── matugen
├── rofi
├── starship.toml
├── swaync
├── swaync 0.12
├── uwsm
├── waybar
├── wlogout
└── yakuakerc
```
> Install all software for these dotfiles according to your distro.

## install.sh

**Behaviour**

- Scan top-level directories and files under `SRC_ROOT` (default: script dir)
- `SRC_ROOT` base name must be `dotfiles` for safety
- Default link root is `~/.config` unless overridden by `linkmap.txt`
- Skip names listed in `ignore.txt`
- for every directory and file:
  1. created
  2. skip (destination exists and differs)
  3. ok (already linked)
- At end, lists all skipped items so user can remove them and re-run if desired

**Usage**

```bash
# In dotfiles root
./install.sh

# Specify a custom dotfiles path
./install.sh /path/to/dotfiles

# Preview only, no changes
./install.sh --dry-run
./install.sh -n
```

## uninstall.sh

**Behaviour**

- Scan top-level directories and files under `SRC_ROOT` (default: script dir)
- `SRC_ROOT` base name must be `dotfiles` for safety
- Default link root is `~/.config` unless overridden by `linkmap.txt`
- Skip names listed in `ignore.txt`
- for every symlink:
  1. removed (symlinks that point to matching items in `SRC_ROOT`)
  2. skip (not exist, non-symlinks or symlinks pointing elsewhere)

**Usage**

```bash
# In dotfiles root
./uninstall.sh

# Specify a custom dotfiles path
./uninstall.sh /path/to/dotfiles

# Preview only, no changes
./uninstall.sh --dry-run
./uninstall.sh -n
```
