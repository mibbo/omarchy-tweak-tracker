# omarchy-tweak-tracker

Keeps a list of everything you change on your [Omarchy](https://omarchy.org) machines: what, where, why and how
to undo it. [Claude Code](https://claude.com/claude-code) updates the list while you tweak things, an audit
finds the changes you made by hand, a daily reminder tells you when the list is out of date, and when you set
up another Omarchy machine, Claude builds a setup script from the list.

## Features

- **Automatic logging.** When Claude changes your system, it adds an entry to your list and says so in one line.
  It guesses the status and asks only when it can't tell.
- **One list per machine.** Each entry records status, scope, source, files, packages, why, undo steps and
  related tweaks.
- **Audit.** Compares the machine against a stock Omarchy install, so changes made without Claude show up too:
  packages from pacman, AUR, uv, npm, flatpak and more, system files, config edits, scripts and Claude Code
  hooks. Also flags listed things that have since disappeared.
- **Sync.** "sync tweaks" turns everything unlisted into entries in one go, then commits and pushes.
- **Daily reminder.** A background check (no Claude, no tokens) notifies you when unlisted tweaks appear, and
  new terminals show a reminder until you sync.
- **Cleanup help.** Statuses (`testing`, `remove-later`, `review`) keep test installs from piling up. The list
  view shows what needs a decision, tweaks that touch the same files, and things in `testing` for too long.
- **Clean removal.** Every entry has exact undo steps. Removed tweaks move to a Removed section with the reason,
  so you don't retry something that already failed.
- **Replication.** Claude builds a setup script for another machine from the entries that fit it. Laptop-only
  and model-specific tweaks stay off a desktop, and tweaks that depend on your devices are checked or adjusted.
- **Private by design.** The tool is public; your lists live in your own private repo. Only files named in a list
  are ever copied, never secrets.

## Two repos

| Repo | What's in it | Visibility |
|---|---|---|
| **omarchy-tweak-tracker** (this one) | The tool: Claude Code skill, audit, daily reminder, installer | Public |
| **my-omarchy-tweaks** (yours) | Your data: `machines/<hostname>/TWEAKS.md` for each machine, plus generated setup scripts | Private |

One data repo holds all your machines. The installer creates it on first run, or clones it on your next machine.

## Install

Needs Omarchy, Claude Code, git with your name and email set, and `gh` logged in (for the private data repo).

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

It's safe to run again. Then ask Claude to **"show my tweaks"**: the first audit lists everything you've already
changed, and "sync tweaks" turns it into entries.

## Logging tweaks

A short rule in `~/.claude/CLAUDE.md` tells Claude to log a tweak whenever it changes the system setup:
packages, `/etc`, `/usr/local`, udev, systemd, `~/.config`, `~/.local/bin`, Claude Code settings, hooks or skills.
App and project code don't count.

Claude fills in the entry, commits it to your data repo (without pushing), and confirms in one line:

```
Logged in TWEAKS.md: Battery charge limit (keep, Framework 13, custom).
```

If the status isn't obvious (a new tool: keeping it, or just trying it?), it asks one short question.

The rule costs about 50 tokens per session. The list itself is only opened when a tweak is made or you ask for it,
so app work isn't affected.

## Showing the list

Ask **"show my tweaks"**. Claude runs the audit, then shows:
1. the audit result
2. **To decide**: entries marked `review` or `remove-later`, and `testing` for more than about 3 weeks
3. **All tweaks**, one table per group, oldest first; ⏳ marks the undecided ones
4. **Overlaps**: tweaks that touch the same files or settings, so removing one doesn't break another

### Example

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

## Syncing and the daily reminder

Things you install or edit yourself (pacman, paru, uv, npm, hand-edited configs) aren't logged as you go.
Ask **"sync tweaks"** to catch up. Claude:
1. runs the audit
2. drafts entries for everything unlisted, grouping a package with its config files
3. shows the drafts as one list and asks about the unclear ones in a single question
4. moves deliberately removed things to `## Removed`
5. commits and pushes, then clears the reminder

You don't have to remember to sync. A daily user timer (`tweaks-check.timer`) runs the audit in the background:
- If the machine was off or asleep at midnight, it runs at the next boot or wake. Missed days don't pile up.
- When the number of unlisted tweaks goes **up**, you get one desktop notification. Clicking it opens a terminal
  with Claude running "sync tweaks".
- While anything is unlisted, new terminals show:
  `⚠ Tweaks: 3 unlisted. Ask Claude to "sync tweaks".`

It uses no Claude and no tokens, takes a few seconds, and runs at idle priority.

## Removing tweaks

Ask e.g. **"remove the pipes.sh tweak"**. Claude runs the entry's undo steps, checks the tweak is gone, and moves
the entry to `## Removed` with the date and reason:

```
### Waybar config
- **Status:** keep · **Scope:** any · **Source:** config · **Added:** 2026-03-03
- **Removed:** 2026-05-02, Omarchy moved to its own shell bar; the old config did nothing anymore.
```

The history stays, so six months later you know you already tried it.

If you uninstall something by hand, the audit marks its entry ❌ and the next sync moves it.

## Replicating to another machine

Ask e.g. **"make a setup script for my desktop"**. Claude:
1. runs the audit, so the list is complete
2. picks entries by scope, then asks you to confirm:
   - a desktop gets `any`
   - a laptop gets `any` + `laptop`
   - the same laptop model also gets the model-specific ones; for other models Claude asks, since they usually
     need adjusting
3. for entries with **Needs** (e.g. a specific mouse or monitor), asks whether those devices are used there and
   adjusts IDs or models
4. copies the current versions of the listed files into `machines/<target>/files/`. Only files named in the
   list, never secrets, `~/.ssh`, browser profiles or `gh` config.
5. writes `machines/<target>/setup.sh`: installs packages, puts files in place (sudo only for system paths),
   enables services and reloads udev or systemd. It's safe to run again. For files you also edit on the new
   machine, like `hypr/bindings.lua`, it merges only the tweak's lines instead of overwriting.
6. uses the installers of tweaks that come from their own repo (source `own repo`) instead of copying them
7. starts `machines/<target>/TWEAKS.md` with the chosen entries, then commits and pushes

On the new machine, after a fresh Omarchy install:

```
gh repo clone mibbo/omarchy-tweak-tracker ~/src/omarchy-tweak-tracker
~/src/omarchy-tweak-tracker/scripts/install            # clones your my-omarchy-tweaks
~/src/my-omarchy-tweaks/machines/<hostname>/setup.sh
```

## Entry fields

| Field | Values |
|---|---|
| Status | `keep` (deliberate fix or preference) · `testing` (trying it out) · `remove-later` (planned to remove) · `review` (purpose unclear, decide) |
| Scope | Where it belongs when setting up another machine: `any` (any hardware) · `laptop` (any laptop) · the model, e.g. `Framework 13` |
| Source | `custom` (written for this machine) · `config` (a setting in an existing config file) · `own repo` (one of your repos) · `Omarchy` (an Omarchy optional setup) · package source: `pacman`, `AUR`, `uv`, `mise`, `npm`, `flatpak`, ... At most two, e.g. `AUR + custom` |
| Needs | External devices it depends on, e.g. `Logitech MX Master 3S`, so a setup script can check or adjust them |
| Files | Every changed path, in backticks |
| Packages | `name` for pacman/AUR, `uv:name`, `npm:name`, `flatpak:id` and so on for the rest |
| Why · Undo · Related | What it does and why, exact commands to remove it, other entries touching the same thing |

See [`examples/archbook/TWEAKS.md`](examples/archbook/TWEAKS.md) for a full list.

## The audit

```
tweaks-audit          # ✓ listed  ⚠ not listed  ❌ listed but missing
tweaks-audit --sudo   # also checks /etc/sudoers.d and /etc/polkit-1/rules.d
```

It compares:
- **Packages**: `pacman -Qqe` (including AUR) minus Omarchy's package lists and packages installed before the baseline
- **Other installers**: uv tools, mise, npm/pnpm/bun globals, pipx, `pip --user`, cargo, `~/go/bin`, flatpak,
  desktop entries and AppImages
- **System files**: files in `/etc`, `/usr/local` and `/opt` that no package owns, changed after the baseline,
  plus package config files you've edited
- **Config**: `~/.bashrc` and `~/.config/{hypr,omarchy,fish,...}` against Omarchy's templates in
  `/usr/share/omarchy`, `~/.local/bin`, Claude Code skills, hooks and `CLAUDE.md`
- **Removed things**: every path under **Files** and every package under **Packages** in active entries

`machines/<hostname>/baseline` in your data repo is the end of the Omarchy install (first boot). Earlier changes
count as part of the install. Noise goes in `machines/<hostname>/audit-ignore`, one glob per line.

## Commits and pushes

Logging a tweak commits to your data repo but doesn't push. "sync tweaks" and replication push. `tweaks-audit`
shows uncommitted and unpushed counts.

Pushing uses `skills/tweaks/scripts/tweaks-push`. If SSH can't reach your key (Claude Code's shell has no SSH
agent), it falls back to HTTPS with your `gh` login.

## Updating and uninstalling

Everything is symlinked into place, so `git pull` in this repo updates the skill and scripts immediately. Run
`scripts/install` again after an update that adds new files.

To uninstall:

```
systemctl --user disable --now tweaks-check.timer
rm ~/.claude/skills/tweaks ~/.local/bin/tweaks-{audit,check} ~/.config/fish/conf.d/tweaks.fish \
   ~/.config/systemd/user/tweaks-check.{service,timer}
rm -r ~/.config/omarchy-tweak-tracker ~/.cache/omarchy-tweak-tracker
```

Then delete the `omarchy-tweak-tracker` block in `~/.claude/CLAUDE.md`. Your data repo stays untouched.

## Limitations

- The terminal reminder is for fish. In bash or zsh you still get the desktop notification.
- Claude can occasionally forget to log a tweak during a long task. The audit and the daily reminder catch it.
- Without `--sudo`, the audit can't look inside `/etc/sudoers.d` and `/etc/polkit-1/rules.d`.
- Config checks cover the folders Omarchy ships templates for, plus fish, systemd, mise and git. Other apps'
  settings show up only if a tweak lists them.

## Layout

```
skills/tweaks/SKILL.md          how Claude logs, syncs, shows, removes and replicates tweaks
skills/tweaks/scripts/          tweaks-audit, tweaks-check, tweaks-push, tweaks-env
systemd/                        daily tweaks-check timer (user unit)
fish/tweaks.fish                reminder line in new terminals
scripts/install                 setup, safe to run again
examples/archbook/TWEAKS.md     a sample list
```

## License

[MIT](LICENSE)
