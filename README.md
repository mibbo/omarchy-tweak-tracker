# omarchy-tweak-tracker

Keeps a list of everything you change on your [Omarchy](https://omarchy.org) machines: what, where, why and how
to undo it. [Claude Code](https://claude.com/claude-code) updates the list while you tweak things, an audit
finds the changes you made by hand, and when you set up another Omarchy machine, Claude builds a setup script
from the list.

It's also a cleanup tool. Every entry has a status, so test installs and leftovers don't quietly pile up and
start conflicting.

## Two repos

| Repo | What's in it | Visibility |
|---|---|---|
| **omarchy-tweak-tracker** (this one) | The tool: Claude Code skill, audit, daily reminder, installer | Public |
| **my-omarchy-tweaks** (yours) | Your data: one `machines/<hostname>/TWEAKS.md` per machine, plus generated setup scripts | Private |

The installer creates your data repo on first run (or clones it, on your next machine). Only files named in
your list are ever copied into it, so secrets stay out.

## How it works

- **Logging:** a short rule in `~/.claude/CLAUDE.md` makes Claude log a tweak whenever it changes the system
  setup: packages, `/etc`, `/usr/local`, udev, systemd, `~/.config`, `~/.local/bin`, Claude Code settings.
  It costs about 50 tokens per session. The list itself is only opened when a tweak is made or you ask for
  it, so app work isn't affected. Claude fills in the fields and confirms in one line, e.g.
  `Logged in TWEAKS.md: Battery charge limit (keep, Framework 13, custom).` If the status is unclear, it asks.
- **Audit:** `tweaks-audit` compares the machine against a stock Omarchy install and against your list, so
  changes made without Claude show up too.
- **Reminder:** a daily user timer counts tweaks the list doesn't cover. If the machine was off or asleep at
  midnight, it runs at the next boot or wake. When the count goes up you get one desktop notification (click
  it to open Claude with "sync tweaks"), and new terminals show
  `⚠ Tweaks: 3 unlisted. Ask Claude to "sync tweaks".` until you sync. No Claude or tokens involved.

## Install

Needs Omarchy, Claude Code, and `gh` logged in (for the private data repo).

```
gh repo clone mibbo/omarchy-tweak-tracker ~/src/omarchy-tweak-tracker
~/src/omarchy-tweak-tracker/scripts/install
```

The installer:
- links the skill to `~/.claude/skills/tweaks` and `tweaks-audit` and `tweaks-check` to `~/.local/bin`
- links the fish reminder and the timer, and enables the timer
- asks for your data repo folder (default: `my-omarchy-tweaks` next to this repo). It clones your existing
  GitHub repo of that name, or creates one, private.
- saves the folder in `~/.config/omarchy-tweak-tracker/config`
- adds the logging rule to `~/.claude/CLAUDE.md`
- creates `machines/<hostname>/` with an empty list and a baseline

It's safe to run again. Then ask Claude to "show my tweaks": the first audit lists everything you've already
changed, and Claude helps you turn it into entries.

## Use

Ask Claude:

- **"show my tweaks"**: runs the audit and shows the list (see the example below)
- **"sync tweaks"**: catches up on things done outside Claude (pacman, AUR, uv, npm installs, hand edits). Claude
  drafts entries for everything unlisted, asks about unclear ones in a single question, moves removed things to
  `## Removed`, commits and pushes
- **"remove the pipes.sh tweak"**: runs the undo steps and moves the entry to `## Removed`
- **"make a setup script for my desktop"**: builds `machines/<target>/setup.sh` and `files/` from the entries
  that fit that machine

Or run the audit yourself:

```
tweaks-audit          # ✓ listed  ⚠ not listed  ❌ listed but missing
tweaks-audit --sudo   # also checks /etc/sudoers.d and /etc/polkit-1/rules.d
```

### Example: "show my tweaks"

For the sample list in [`examples/archbook/TWEAKS.md`](examples/archbook/TWEAKS.md), a Framework 13:

````
Audit: 0 unlisted, 0 missing, nothing uncommitted or unpushed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⚠  TO DECIDE  ·  3 tweaks need a decision
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| Added      | Tweak             | Status       | Source  | Scope | What it is                              |
|------------|-------------------|--------------|---------|-------|-----------------------------------------|
| 2026-06-20 | pipes.sh          | review       | AUR     | any   | Pipes animation, for one screenshot     |
| 2026-08-30 | Spotify (Flatpak) | remove-later | flatpak | any   | Replaced by spotify-player              |
| 2026-09-20 | ollama            | testing      | pacman  | any   | Local LLMs, testing for over 3 weeks    |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ALL TWEAKS  ·  19 in 5 groups
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Power and sleep (3)

| Added      | Tweak                     | Source       | Scope        | What it is                               |
|------------|---------------------------|--------------|--------------|------------------------------------------|
| 2026-03-02 | zram at half of RAM       | config       | any          | Compressed swap in RAM, zstd, 50%        |
| 2026-03-05 | Suspend, then hibernate   | config       | laptop       | Hibernates after 45 minutes asleep       |
| 2026-04-11 | Battery charge limit 80%  | AUR + custom | Framework 13 | framework_tool sets the limit at boot    |

Desktop (5)

| Added      | Tweak                     | Source          | Scope        | What it is                               |
|------------|---------------------------|-----------------|--------------|------------------------------------------|
| 2026-03-02 | Caps Lock as Esc and Ctrl | pacman + config | any          | keyd: tap for Esc, hold for Ctrl         |
| 2026-03-02 | Screen scaling 1.6x       | config          | Framework 13 | 2256×1504 panel, 1410×940 workspace      |
| 2026-05-18 | Floating calculator       | config          | any          | SUPER+C opens qalculate, floating        |
| 2026-06-03 | MX Master button mapping  | AUR + config    | any          | logiops: thumb button, gestures          |
| 2026-08-09 | Screenshot to clipboard   | config          | any          | SUPER+SHIFT+S, region to clipboard       |

Shell and dev tools (4)

| Added      | Tweak                     | Source          | Scope | What it is                              |
|------------|---------------------------|-----------------|-------|-----------------------------------------|
| 2026-03-02 | zsh with starship         | pacman + config | any   | zsh login shell, minimal prompt         |
| 2026-03-03 | paru instead of yay       | AUR             | any   | AUR helper with PKGBUILD review         |
| 2026-03-04 | Neovim config             | own repo        | any   | Own lazy.nvim setup instead of LazyVim  |
| 2026-07-15 | Rootless podman           | pacman + config | any   | No root daemon, docker alias to podman  |

Claude Code (2)

| Added      | Tweak                       | Source   | Scope | What it is                             |
|------------|-----------------------------|----------|-------|----------------------------------------|
| 2026-09-28 | Notify when Claude finishes | custom   | any   | Stop hook sends a desktop notification |
| 2026-10-10 | Tweak tracker               | own repo | any   | This list: skill, audit, reminder      |

Apps and packages (5)

| Added      | Tweak                | Source  | Scope | What it is                         |
|------------|----------------------|---------|-------|------------------------------------|
| 2026-03-02 | btop                 | pacman  | any   | Resource monitor                   |
| 2026-04-26 | Steam                | pacman  | any   | Gaming via Proton, multilib        |
| 2026-06-20 | pipes.sh ⏳          | AUR     | any   | Terminal pipes animation           |
| 2026-08-30 | Spotify (Flatpak) ⏳ | flatpak | any   | Spotify client                     |
| 2026-09-20 | ollama ⏳            | pacman  | any   | Local LLMs                         |

Overlaps
- hypr/bindings.lua holds shortcuts for Floating calculator and Screenshot to clipboard.
- zsh replaces Omarchy's bash setup, so Omarchy's shell aliases need porting.

Remove Spotify, decide on pipes.sh, or keep ollama?
````

In the terminal the tables render as boxes. ⏳ marks entries that are still in "To decide".

### Entry fields

| Field | Values |
|---|---|
| Status | `keep` (deliberate fix or preference) · `testing` (trying it out) · `remove-later` (planned to remove) · `review` (purpose unclear, decide) |
| Scope | Where it belongs when setting up another machine: `any` (any hardware) · `laptop` (any laptop) · the model, e.g. `Framework 13` |
| Source | `custom` (written for this machine) · `config` (a setting in an existing config file) · `own repo` (one of your repos) · `Omarchy` (an Omarchy optional setup) · package source: `pacman`, `AUR`, `uv`, `mise`, `npm`, `flatpak`, ... At most two, e.g. `AUR + custom` |
| Needs | External devices it depends on, e.g. `Logitech MX Master 3S`, so a setup script can check or adjust them |

Each entry also lists **Files**, **Packages** (`name` for pacman/AUR, `uv:name`, `npm:name`, `flatpak:id` and so
on for the rest), **Why**, **Undo** and optionally **Related**. See [`examples/archbook/TWEAKS.md`](examples/archbook/TWEAKS.md).

A setup script for another machine picks entries by scope: a desktop gets `any`, a laptop gets `any` + `laptop`,
and the same model also gets the model-scoped ones. Entries with **Needs** are checked or adjusted.

### What the audit compares

- **Packages**: `pacman -Qqe` (including AUR) minus Omarchy's package lists and packages installed before the baseline
- **Other installers**: uv tools, mise, npm/pnpm/bun globals, pipx, `pip --user`, cargo, `~/go/bin`, flatpak,
  desktop entries and AppImages
- **System files**: files in `/etc`, `/usr/local` and `/opt` that no package owns, changed after the baseline,
  plus package config files you've edited
- **Config**: `~/.bashrc` and `~/.config/{hypr,omarchy,fish,...}` against Omarchy's templates in
  `/usr/share/omarchy`, `~/.local/bin`, Claude Code skills, hooks and `CLAUDE.md`
- **Removed things**: every backticked path under **Files** and every package under **Packages** is checked,
  and missing ones are marked ❌

`machines/<hostname>/baseline` in your data repo is the end of the Omarchy install (first boot). Earlier changes
count as part of the install. Noise goes in `machines/<hostname>/audit-ignore`, one glob per line.

## New machine

```
gh repo clone mibbo/omarchy-tweak-tracker ~/src/omarchy-tweak-tracker
~/src/omarchy-tweak-tracker/scripts/install            # clones your my-omarchy-tweaks
~/src/my-omarchy-tweaks/machines/<hostname>/setup.sh   # if you built one for it
```

## Layout

```
skills/tweaks/SKILL.md          how Claude logs, syncs, shows, removes and replicates tweaks
skills/tweaks/scripts/          tweaks-audit, tweaks-check, tweaks-push, tweaks-env
systemd/                        daily tweaks-check timer (user unit)
fish/tweaks.fish                reminder line in new terminals
scripts/install                 setup, safe to run again
examples/archbook/TWEAKS.md     a sample list
```

The skill and scripts are symlinked into place, so `git pull` updates them immediately.

## License

[MIT](LICENSE)
