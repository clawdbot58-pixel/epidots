# Shared apply/unapply logic — sourced by install.sh and rice.
AFS_DIR="${AFS_DIR:-$HOME/afs}"
CONF="$AFS_DIR/.confs"
MANIFEST="$CONF/manifest.txt"
PROFILE="$CONF/nix-profile"

# Symlink dst -> src. Never clobber a real directory.
link() {
  src="$1"
  dst="$2"
  if [ -d "$dst" ] && [ ! -L "$dst" ]; then
    echo "epidots: skip $dst (real directory)" >&2
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
}

# Install packages from manifest.txt into the AFS profile (symlinks into
# /nix/store; a few KB in AFS). Re-runs only when the manifest changes.
ensure_profile() {
  [ -f "$MANIFEST" ] || return 0
  want=$(sha256sum "$MANIFEST" | cut -d' ' -f1)
  have=$(cat "$CONF/.manifest.sha" 2>/dev/null)
  [ "$want" = "$have" ] && return 0

  # shellcheck disable=SC2046
  set -- $(sed -e 's/#.*//' -e 's/[[:space:]]//g' "$MANIFEST" | grep -v '^$' | sed 's|^|nixpkgs#|')
  [ $# -eq 0 ] && { echo "$want" > "$CONF/.manifest.sha"; return 0; }

  echo "epidots: installing packages from manifest ($# packages, first run only)..."
  # Do NOT create $PROFILE itself: `nix profile install --profile` creates it
  # as a symlink (-> <name>-N-link). A plain directory makes nix fail with
  # "reading symbolic link ...: Invalid argument".
  mkdir -p "$(dirname "$PROFILE")"
  if nix profile install --profile "$PROFILE" "$@"; then
    # The profile generation resolves into /nix/store (immutable), so the
    # state file must live beside the manifest, not inside the profile.
    echo "$want" > "$CONF/.manifest.sha"
  else
    echo "epidots: nix profile install failed — will retry at next login" >&2
    return 1
  fi
}

# Restart i3 if we are inside a session (restart re-runs exec_always, so
# the daemons come back after 'rice on'); no-op at PAM login (no X yet).
reload_i3() {
  command -v i3-msg >/dev/null 2>&1 || return 0
  i3-msg restart >/dev/null 2>&1 || true
}

apply() {
  export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH"
  link "$CONF/bashrc" "$HOME/.bashrc"
  link "$CONF/bashrc" "$HOME/.profile"
  link "$CONF/zshrc" "$HOME/.zshrc"
  link "$CONF/tmux.conf" "$HOME/.tmux.conf"
  link "$CONF/config/i3/config" "$HOME/.config/i3/config"
  ensure_profile
  link "$PROFILE" "$HOME/.nix-profile"
  # vscodium state (extensions, settings) lives in AFS so it survives wipes
  mkdir -p "$CONF/vscode-oss" "$CONF/vscode-oss-config"
  link "$CONF/vscode-oss" "$HOME/.vscode-oss"
  link "$CONF/vscode-oss-config" "$HOME/.config/Code - OSS"
  mkdir -p "$HOME/Pictures"
  reload_i3
}

# Remove only symlinks that point into our AFS tree; leave everything else.
# Restores a true vanilla desktop: stock i3 config, no rice daemons.
unapply() {
  for f in .bashrc .profile .zshrc .tmux.conf .config/i3/config .nix-profile .vscode-oss ".config/Code - OSS"; do
    dst="$HOME/$f"
    if [ -L "$dst" ]; then
      case "$(readlink "$dst")" in
        "$AFS_DIR"/*) rm -f "$dst" ;;
      esac
    fi
  done
  # stop our daemons (picom, autolock, sleep-lock, notifications);
  # dunst renames its process to .dunst-wrapped, so match both names
  for p in picom xautolock xss-lock dunst .dunst-wrapped; do
    pkill -x "$p" 2>/dev/null
  done
  # there is no /etc/i3/config on this system: copy the stock default that
  # ships with the i3 package, so mod+d & friends work again after reload
  i3bin=$(command -v i3 2>/dev/null)
  if [ -n "$i3bin" ]; then
    i3def="$(dirname "$(readlink -f "$i3bin")")/../etc/i3/config"
    if [ -f "$i3def" ]; then
      mkdir -p "$HOME/.config/i3"
      cp -f "$i3def" "$HOME/.config/i3/config"
    fi
  fi
  reload_i3
}
