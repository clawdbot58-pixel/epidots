#!/bin/sh
# epidots uninstall — works even if the rice itself is broken:
#   curl -L https://raw.githubusercontent.com/clawdbot58-pixel/epidots/main/uninstall.sh | sh
# Fetches the latest rice into a temp dir and runs its `uninstall`
# (removes rice links/files from ~/afs, restores the vanilla desktop;
# stock EPITA dotfiles are kept).
TMP=$(mktemp -d) || exit 1
if ! git clone --depth 1 https://github.com/clawdbot58-pixel/epidots.git "$TMP/e" >/dev/null 2>&1; then
  echo "uninstall: git clone failed (network? git?)" >&2
  rm -rf "$TMP"
  exit 1
fi
chmod +x "$TMP/e/rice"
sh "$TMP/e/rice" uninstall
rc=$?
rm -rf "$TMP"
exit $rc
