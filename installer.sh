#!/bin/sh
# One-line installer (same style as tsunooky/epidots):
#   curl -L https://raw.githubusercontent.com/clawdbot58-pixel/epidots/main/installer.sh | sh
# Merges into ~/afs/.confs (stock EPITA files like gitconfig/ssh are kept),
# then flips the rice on immediately.
REPO_URL="https://github.com/clawdbot58-pixel/epidots.git"

echo ":: Cloning epidots..."
TMP=$(mktemp -d) || exit 1
if ! git clone --depth 1 "$REPO_URL" "$TMP/epidots" >/dev/null 2>&1; then
  echo "install: git clone failed (network? git not installed?)" >&2
  rm -rf "$TMP"
  exit 1
fi

mkdir -p "$HOME/afs/.confs"
# cp of `src/.` merges: overwrites our files, keeps everything else
cp -r "$TMP/epidots/.confs/." "$HOME/afs/.confs/"
cp "$TMP/epidots/rice" "$HOME/afs/rice"
chmod +x "$HOME/afs/rice" "$HOME/afs/.confs/install.sh"
rm -rf "$TMP"

"$HOME/afs/rice" on
echo ":: Done. The rice is active now and re-applies itself at every login."
