---
name: tweaks
description: The user's ledger of everything changed on this Omarchy machine (TWEAKS.md). Use it to log a tweak right after changing the system setup (packages, /etc, /usr/local, udev, systemd, ~/.config, ~/.local/bin, Claude Code settings, hooks or skills), for "sync tweaks" (catch up on changes made outside Claude), to remove a tweak, to show or audit the tweak list ("what have I tweaked/installed", bloat or conflict check), and to build a setup script that replicates the tweaks on another Omarchy machine. Not for app or project code.
---

# Tweaks ledger

Part of [omarchy-tweak-tracker](https://github.com/mibbo/omarchy-tweak-tracker). The tweak lists live in the
user's private data repo: `<data>` is `DATA_DIR` in `~/.config/omarchy-tweak-tracker/config`, and this machine's
ledger is `<data>/machines/$(hostname)/TWEAKS.md` (`scripts/tweaks-audit` prints it on its first line).
Scripts are in this skill's `scripts/` folder. Keep the user-facing side minimal: one line when logging, no lectures.

## Logging a tweak (the common case)

After changing the system setup, before finishing the turn:

1. Add or update an entry in TWEAKS.md under the fitting `##` group. Use the groups already in the file; a new
   list starts with Power and sleep, Desktop, Shell and dev tools, Claude Code, Apps and packages. Add a group
   only if none fits, and keep it to about five. Groups are in date order, so a new entry goes last in its
   group. Format:

   ```
   ### Short name of what it does
   - **Status:** keep · **Scope:** laptop · **Source:** custom · **Added:** YYYY-MM-DD
   - **Files:** `/full/path`, `~/home/path`
   - **Packages:** `name` (only if packages were installed)
   - **Needs:** devices it depends on, e.g. `Logitech receiver 046d:c52b` (only if any)
   - **Why:** what it does and why, 1-3 sentences
   - **Undo:** exact commands to remove it completely
   - **Related:** other entries touching the same thing (only if any)
   ```

   - Put every changed path in backticks under **Files**, and every package in backticks under **Packages**:
     `name` for pacman/yay, `<manager>:name` for the rest (`uv:`, `mise:`, `npm:`, `pnpm:`, `bun:`, `pipx:`,
     `pip:`, `cargo:`, `go:`, `flatpak:`). The audit matches on these and flags removed ones.
   - Changing an existing tweak: update its entry; don't add a second one.
   - One entry per feature, not per file.
2. Guess the fields:
   - **Status:** `keep` (a fix or a deliberate preference), `testing` (trying a tool or idea), `remove-later`
     (the user said it's temporary or didn't work), `review` (unknown).
   - **Scope** (where it belongs if another machine is set up): `any` (any hardware), `laptop` (any laptop:
     lid, battery, touchpad), or the laptop model as named at the top of TWEAKS.md, e.g. `Framework 13` (this
     model's panel, sensors, vendor battery controls). Nothing is tied to the single unit.
   - **Source:** `custom` (script, rule or hook written for this machine), `config` (a setting changed in an
     existing config file), `own repo` (from one of the user's GitHub repos), `Omarchy` (an Omarchy optional
     setup), or the package source `pacman`, `AUR`, `uv`, `mise`, `npm`, `flatpak`, ... At most two, joined
     with ` + ` (e.g. `pacman + custom`).
   - **Needs:** external devices with their IDs or models (keyboard receiver, monitor, keyboard), so a setup
     script can check or adjust them. Not a scope.
3. If the status is genuinely unclear (e.g. a new tool: kept or just tried?), ask one short question. Otherwise don't ask.
4. Commit only the ledger: `git -C <data> add machines/ && git -C <data> commit -qm "Log: <name>" -- machines/`.
   Don't push here; "sync tweaks" pushes.
5. Tell the user in one line, e.g. `Logged in TWEAKS.md: Battery charge limit (keep, Framework 13, custom).`

Not tweaks: project code, files inside a repo's own folder, temporary files, one-off commands that leave nothing behind.

## Syncing ("sync tweaks")

Catches up on everything done outside Claude (manual pacman, yay, uv, npm installs, hand edits). A daily timer
reminds the user with a notification and a line in new terminals.

1. Run `scripts/tweaks-audit`.
2. For every `⚠`: group related findings into entries (e.g. a package with its config files) and draft them
   with a guessed status. For `❌`: if a package or file was deliberately removed, move its entry to Removed;
   if only part of it is gone, update the entry.
3. Show the drafts as one short list (name, guessed status, scope, source) and ask only about the unclear ones,
   all in a single question. Omarchy noise goes into `audit-ignore` instead.
4. Write the entries, run the audit again until it reports `0 unlisted, 0 missing`, then commit as
   `Sync: <n> tweaks`.
5. Push with `scripts/tweaks-push` (falls back to gh's HTTPS login when SSH has no agent).
6. Run `scripts/tweaks-check --quiet` so the terminal reminder clears. Report in one or two lines.

## Removing a tweak

Run its **Undo**, check it's gone, then move the entry under `## Removed` with
`- **Removed:** YYYY-MM-DD, <reason>`. Commit as `Remove: <name>`.

## Showing the list or auditing

Run `scripts/tweaks-audit` (in this skill's folder). It compares the machine against Omarchy's defaults
(package lists, unowned files in /etc and /usr/local, ~/.config against Omarchy's templates, ~/.local/bin,
Claude Code setup) and against the ledger:

- `⚠` found but not listed: ask whether to add it to the ledger (draft the entry) or remove it from the system.
  If it's Omarchy noise, add a glob to `machines/<hostname>/audit-ignore`.
- `❌` listed but missing: fix the entry or move it to Removed.
- Root-only folders (sudoers.d, polkit rules) need `tweaks-audit --sudo`, which the user runs with `! tweaks-audit --sudo`.

Then show the ledger in exactly this layout:

````
Audit: 0 unlisted, 0 missing, nothing uncommitted or unpushed.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⚠  TO DECIDE  ·  5 tweaks need a decision
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

| Added | Tweak | Status | Source | Scope | What it is |
|---|---|---|---|---|---|
| 2026-09-24 | ollama | testing | pacman | any | Local LLMs, trying it for code completion |

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ALL TWEAKS  ·  19 in 5 groups
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Power and sleep (3)

| Added | Tweak | Source | Scope | What it is |
|---|---|---|---|---|
| 2026-09-26 | Battery charge limit | custom | Framework 13 | Stops charging at 80% to reduce battery wear |

**Overlaps**
- `hypr/bindings.lua` holds shortcuts for Floating calculator and Screenshot to clipboard.
````

Rules:
- Audit line: unlisted, missing, uncommitted and unpushed counts in one sentence.
- **To decide** lists `review`, `remove-later` and `testing` older than ~3 weeks, oldest first. With none, the
  banner reads `✓  TO DECIDE  ·  nothing` and there's no table.
- **All tweaks** has one `###` table per ledger group, in the ledger's order, with the entry count in the
  heading, rows oldest first, and every entry including the undecided ones. No Status column there; append
  ` ⏳` to the name of undecided entries instead.
- Keep `What it is` to about 50 characters so tables don't wrap or get cut off.
- **Overlaps:** entries touching the same files or settings, one line each. Skip the section if none.
- End with one short question offering the next step (e.g. remove the remove-later items, go through review).

## Replicating on another machine

1. Run the audit first so the ledger is complete.
2. Ask which entries to include. Default: status `keep`, filtered by scope: a desktop gets `any`; a laptop
   gets `any` + `laptop`; the same model also gets the model-scoped ones. Ask about model-scoped entries for
   other laptops, since they usually need adjusting. For entries with **Needs**, ask whether those devices are
   used there and adjust IDs or models in the copied files.
3. Create `<data>/machines/<target-hostname>/`: copy the chosen entries' current files from this machine into
   `machines/<target>/files/` with their full paths (`files/etc/udev/...`, `files/home/.config/...`).
   Copy only files named in the ledger. Never copy secrets, tokens, `~/.ssh`, browser profiles or `gh` config.
   For tweaks that come from their own repo (source `own repo`), clone and run that repo's installer instead.
4. Write `machines/<target>/setup.sh`: idempotent bash that installs packages (`omarchy pkg add`, `omarchy pkg aur add`),
   copies files into place (sudo only for system paths), enables services, reloads udev or systemd, and prints what it did.
   For files the user also edits on the target (e.g. `hypr/bindings.lua`), merge only the tweak's lines; don't overwrite.
5. Copy the chosen entries into `machines/<target>/TWEAKS.md`, so the new machine starts with its own ledger.
6. Commit and push (`scripts/tweaks-push`). On the new machine the user clones omarchy-tweak-tracker, runs its
   `scripts/install` (which clones the data repo), then runs `<data>/machines/<target>/setup.sh`.
