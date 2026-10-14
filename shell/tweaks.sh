# Show tweaks that TWEAKS.md doesn't cover yet (counted daily by tweaks-check.timer).
# Sourced from ~/.bashrc and ~/.zshrc by omarchy-tweak-tracker's scripts/install. POSIX sh, so it works in both.

case $- in
  *i*) ;;
  *) return 0 ;;
esac

__tweaks_state="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-tweak-tracker/status"
if [ -r "$__tweaks_state" ]; then
  read -r __tweaks_unlisted __tweaks_missing <"$__tweaks_state"
  case "$__tweaks_unlisted$__tweaks_missing" in
    '' | *[!0-9]*) ;;
    *)
      __tweaks_parts=
      [ "$__tweaks_unlisted" -gt 0 ] && __tweaks_parts="$__tweaks_unlisted unlisted"
      [ "$__tweaks_missing" -gt 0 ] && __tweaks_parts="${__tweaks_parts:+$__tweaks_parts, }$__tweaks_missing missing"
      [ -n "$__tweaks_parts" ] &&
        printf '\033[33m⚠ Tweaks: %s. Ask Claude to "sync tweaks".\033[0m\n' "$__tweaks_parts"
      ;;
  esac
fi
unset __tweaks_state __tweaks_unlisted __tweaks_missing __tweaks_parts
