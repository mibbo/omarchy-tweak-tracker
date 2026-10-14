# Tweaks on archbook

Model: Framework Laptop 13 (AMD Ryzen 7040), installed 2026-03-01.

Status: `keep` · `testing` (trying it out) · `remove-later` (planned to remove) · `review` (purpose unclear, decide).
Scope: `any` (any hardware) · `laptop` (any laptop) · the model, e.g. `Framework 13` (this laptop model).
Source: `custom` · `config` · `own repo` · `Omarchy` · package source (`pacman`, `AUR`, `uv`, `mise`, ...).
Needs: external devices a tweak depends on, so a setup script can check or adjust them.

## Power and sleep

### zram at half of RAM
- **Status:** keep · **Scope:** any · **Source:** config · **Added:** 2026-03-02
- **Files:** `/etc/systemd/zram-generator.conf`
- **Why:** Compressed swap in RAM, sized to 50% of memory (`zram-size = ram / 2`, zstd), so big builds don't hit the disk swapfile.
- **Undo:** `sudo rm /etc/systemd/zram-generator.conf && sudo systemctl daemon-reload && sudo systemctl restart systemd-zram-setup@zram0`

### Suspend, then hibernate after 45 minutes
- **Status:** keep · **Scope:** laptop · **Source:** config · **Added:** 2026-03-05
- **Files:** `/etc/systemd/logind.conf.d/lid.conf`, `/etc/systemd/sleep.conf.d/hibernate-delay.conf`
- **Why:** Closing the lid suspends; after 45 minutes asleep it hibernates, so a forgotten laptop doesn't drain overnight.
- **Undo:** `sudo rm /etc/systemd/logind.conf.d/lid.conf /etc/systemd/sleep.conf.d/hibernate-delay.conf && sudo systemctl kill -s HUP systemd-logind`

### Battery charge limit 80%
- **Status:** keep · **Scope:** Framework 13 · **Source:** AUR + custom · **Added:** 2026-04-11
- **Files:** `/etc/systemd/system/charge-limit.service`
- **Packages:** `framework-system`
- **Why:** Sets the EC charge limit to 80% at boot with `framework_tool --charge-limit 80`, since the laptop is plugged in most of the day.
- **Undo:** `sudo systemctl disable --now charge-limit.service && sudo rm /etc/systemd/system/charge-limit.service && sudo framework_tool --charge-limit 100`

## Desktop

### Caps Lock as Esc and Ctrl
- **Status:** keep · **Scope:** any · **Source:** pacman + config · **Added:** 2026-03-02
- **Files:** `/etc/keyd/default.conf`
- **Packages:** `keyd`
- **Why:** Tap Caps Lock for Esc, hold it for Ctrl (`capslock = overload(control, esc)`). Works in every app and the TTY.
- **Undo:** `sudo systemctl disable --now keyd && sudo rm /etc/keyd/default.conf && sudo pacman -Rns keyd`

### Screen scaling 1.6x
- **Status:** keep · **Scope:** Framework 13 · **Source:** config · **Added:** 2026-03-02
- **Files:** `~/.config/hypr/monitors.lua`
- **Why:** The 2256×1504 panel at 1.6x gives a 1410×940 workspace.
- **Undo:** Delete the `eDP-1` line in monitors.lua.

### Floating calculator
- **Status:** keep · **Scope:** any · **Source:** config · **Added:** 2026-05-18
- **Files:** `~/.config/hypr/hyprland.lua`, `~/.config/hypr/bindings.lua`
- **Why:** SUPER+C opens qalculate-gtk as a small centered floating window.
- **Undo:** Delete the qalculate window rule in hyprland.lua and the SUPER+C binding.
- **Related:** Screenshot to clipboard (same bindings file)

### MX Master button mapping
- **Status:** keep · **Scope:** any · **Source:** AUR + config · **Added:** 2026-06-03
- **Files:** `/etc/logid.cfg`
- **Packages:** `logiops`
- **Needs:** `Logitech MX Master 3S`
- **Why:** Thumb button switches workspaces, gesture button opens the overview, smooth scrolling on.
- **Undo:** `sudo systemctl disable --now logid && sudo rm /etc/logid.cfg && paru -Rns logiops`

### Screenshot region to clipboard
- **Status:** keep · **Scope:** any · **Source:** config · **Added:** 2026-08-09
- **Files:** `~/.config/hypr/bindings.lua`
- **Why:** SUPER+SHIFT+S selects a region and copies it straight to the clipboard, no file saved.
- **Undo:** Delete the SUPER+SHIFT+S binding.
- **Related:** Floating calculator (same bindings file)

## Shell and dev tools

### zsh with a minimal starship prompt
- **Status:** keep · **Scope:** any · **Source:** pacman + config · **Added:** 2026-03-02
- **Files:** `~/.zshrc`, `~/.config/starship.toml`
- **Packages:** `zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`
- **Why:** zsh as login shell (`chsh -s /usr/bin/zsh`), starship trimmed to directory, git branch and exit code.
- **Undo:** `chsh -s /bin/bash`, restore starship.toml with `omarchy refresh config starship.toml`, then remove the packages.

### paru instead of yay
- **Status:** keep · **Scope:** any · **Source:** AUR · **Added:** 2026-03-03
- **Packages:** `paru`
- **Why:** Prefer paru's PKGBUILD review flow for AUR packages.
- **Undo:** `sudo pacman -Rns paru`

### Neovim config
- **Status:** keep · **Scope:** any · **Source:** own repo · **Added:** 2026-03-04
- **Files:** `~/.config/nvim`
- **Why:** Own lazy.nvim setup replacing Omarchy's LazyVim. Repo: `~/src/nvim-config`, linked with its `install.sh`.
- **Undo:** `rm ~/.config/nvim` and `omarchy refresh config nvim`

### Rootless podman with docker alias
- **Status:** keep · **Scope:** any · **Source:** pacman + config · **Added:** 2026-07-15
- **Files:** `/etc/subuid`, `/etc/subgid`, `~/.config/containers/registries.conf`
- **Packages:** `podman`, `podman-docker`
- **Why:** Containers without a root daemon; `docker` commands go to podman.
- **Undo:** `sudo pacman -Rns podman-docker podman` and remove the user's lines from /etc/subuid and /etc/subgid.

## Claude Code

### Notify when Claude finishes
- **Status:** keep · **Scope:** any · **Source:** custom · **Added:** 2026-09-28
- **Files:** `~/.claude/hooks/notify-done.sh`, `~/.claude/settings.json` (Stop hook)
- **Why:** Desktop notification when a long Claude task finishes and the terminal isn't focused.
- **Undo:** Remove the Stop hook from settings.json and delete the script.

### Tweak tracker (this list)
- **Status:** keep · **Scope:** any · **Source:** own repo · **Added:** 2026-10-10
- **Files:** `~/.claude/skills/tweaks`, `~/.local/bin/tweaks-audit`, `~/.local/bin/tweaks-check`, `~/.claude/CLAUDE.md`
- **Why:** omarchy-tweak-tracker: logs tweaks, audits for unlisted ones, daily reminder.
- **Undo:** `systemctl --user disable --now tweaks-check.timer`, remove the links, delete the block in CLAUDE.md.

## Apps and packages

### btop
- **Status:** keep · **Scope:** any · **Source:** pacman · **Added:** 2026-03-02
- **Packages:** `btop`
- **Why:** Resource monitor, with a theme matching the desktop.
- **Undo:** `sudo pacman -Rns btop`

### Steam
- **Status:** keep · **Scope:** any · **Source:** pacman · **Added:** 2026-04-26
- **Packages:** `steam`
- **Why:** Gaming via Proton. Needed the multilib repo enabled in /etc/pacman.conf.
- **Undo:** `sudo pacman -Rns steam`

### pipes.sh
- **Status:** review · **Scope:** any · **Source:** AUR · **Added:** 2026-06-20
- **Packages:** `pipes.sh`
- **Why:** Animated terminal pipes. Installed for a screenshot, probably not needed.
- **Undo:** `paru -Rns pipes.sh`

### Spotify (Flatpak)
- **Status:** remove-later · **Scope:** any · **Source:** flatpak · **Added:** 2026-08-30
- **Packages:** `flatpak:com.spotify.Client`
- **Why:** Replaced by spotify-player in the terminal.
- **Undo:** `flatpak uninstall com.spotify.Client`

### ollama
- **Status:** testing · **Scope:** any · **Source:** pacman · **Added:** 2026-09-20
- **Packages:** `ollama`
- **Why:** Local LLMs, trying it for offline code completion.
- **Undo:** `sudo systemctl disable --now ollama && sudo pacman -Rns ollama && rm -rf ~/.ollama`

## Removed

### Waybar config
- **Status:** keep · **Scope:** any · **Source:** config · **Added:** 2026-03-03
- **Removed:** 2026-05-02, Omarchy moved to its own shell bar; the old config did nothing anymore.
