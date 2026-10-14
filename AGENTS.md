# omarchy-tweak-tracker

A public tool that keeps a list of system tweaks on Omarchy machines, maintained by Claude Code. See README.md
for the design. Users' tweak lists live in their own private data repo (default `my-omarchy-tweaks`), never here.

- Entry format and the logging, sync, show, remove and replicate procedures live in `skills/tweaks/SKILL.md`.
  Change them there, not in copies. Keep `examples/archbook/TWEAKS.md` and the README example in step with it.
- Scripts in `skills/tweaks/scripts/` are bash, find the data repo through `tweaks-env` (which reads
  `~/.config/omarchy-tweak-tracker/config`), and run without root except `tweaks-audit --sudo`.
- `tweaks-audit` must stay fast (a few seconds); it runs daily from the timer. It matches ledger entries by
  backticked paths and package names, so keep that convention in the skill and the examples.
- `scripts/install` must stay safe to run again and must work for other users: no hardcoded user names, hosts,
  hardware or paths. Personal data never goes into this repo, not even in examples.
- `skills/tweaks`, `tweaks-audit`, `tweaks-check`, the fish file and the systemd units are symlinked into place
  by `scripts/install`, so edits are live immediately.
- Use `gh` for GitHub operations.
