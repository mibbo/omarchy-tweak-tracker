# Show tweaks that TWEAKS.md doesn't cover yet (counted daily by tweaks-check.timer)
status is-interactive; or return
set -l state ~/.cache/omarchy-tweak-tracker/status
test -r $state; or return
read -l unlisted missing <$state
test "$unlisted" -gt 0 -o "$missing" -gt 0 2>/dev/null; or return

set -l parts
test "$unlisted" -gt 0; and set -a parts "$unlisted unlisted"
test "$missing" -gt 0; and set -a parts "$missing missing"
set_color yellow
echo "⚠ Tweaks: "(string join ", " $parts)". Ask Claude to \"sync tweaks\"."
set_color normal
