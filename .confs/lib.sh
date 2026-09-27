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

# Stock EPITA dotfiles that a school seat seeds into ~/afs/.confs
# (gitconfig, ssh, signature, …). Same list as the stock install.sh and
# tsunooky/epidots — we link them too so a real seat keeps working.
# Only linked when the file exists: a bare clone has none of these.
STOCK_DOTS="gitconfig gitignore signature ssh Xdefaults gdbinit emacs thunderbird mozilla vim"
link_stock_dots() {
  for f in $STOCK_DOTS; do
    [ -e "$CONF/$f" ] && link "$CONF/$f" "$HOME/.$f"
  done
  return 0
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
  # `install` on older nix, `add` on newer — same fallback as tsunooky/epidots
  if nix profile install --profile "$PROFILE" "$@" ||
     nix profile add --profile "$PROFILE" "$@"; then
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
  link "$CONF/profile" "$HOME/.profile"
  link "$CONF/zshrc" "$HOME/.zshrc"
  link "$CONF/vimrc" "$HOME/.vimrc"
  link "$CONF/tmux.conf" "$HOME/.tmux.conf"
  link_stock_dots
  # ~/.config: stock EPITA and tsunooky/epidots keep the whole tree in AFS.
  # On a fresh login (normal case) the dir doesn't exist yet → link it.
  # (guard on $CONF/config: a truncated conf must not leave a broken ~/.config)
  if [ ! -e "$HOME/.config" ] && [ -d "$CONF/config" ]; then
    link "$CONF/config" "$HOME/.config"
  fi
  # i3 config is only needed when .config is a real dir (legacy/VM state);
  # if ~/.config IS our AFS tree the file already lives at the right path.
  if [ ! -L "$HOME/.config" ] || [ "$(readlink "$HOME/.config")" != "$CONF/config" ]; then
    link "$CONF/config/i3/config" "$HOME/.config/i3/config"
  fi
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
  # .config MUST come before its children: when ~/.config is our AFS
  # symlink, rm -f on an inner path would resolve through it and delete
  # the real file in AFS. After the parent link is gone the inner entries
  # are no-ops.
  for f in .bashrc .profile .zshrc .vimrc .tmux.conf .config .config/i3/config .nix-profile .vscode-oss ".config/Code - OSS"; do
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
  # Restore the EPITA default config (Windows key = mod). The stock sample
  # shipped with the i3 package uses Mod1 (Alt) and is only a fallback for
  # systems without X; on EPITA the first-login i3-config-wizard writes the
  # real Mod4 default. Regenerate it the same way, headless: wizard only
  # writes when no config exists yet (we just removed our symlink).
  i3bin=$(command -v i3 2>/dev/null)
  if [ -n "$i3bin" ]; then
    i3def="$(dirname "$(readlink -f "$i3bin")")/../etc/i3/config"
    mkdir -p "$HOME/.config/i3"
    wiz="$(command -v i3-config-wizard 2>/dev/null)"
    if [ -n "$wiz" ] && [ ! -e "$HOME/.config/i3/config" ]; then
      XDG_CONFIG_HOME="$HOME/.config" "$wiz" -m win >/dev/null 2>&1 \
        || [ -f "$HOME/.config/i3/config" ]
    fi
    # fallback: wizard unavailable/failed → patch the stock sample
    if [ ! -f "$HOME/.config/i3/config" ] && [ -f "$i3def" ]; then
      sed 's/Mod1/Mod4/g' "$i3def" > "$HOME/.config/i3/config"
    fi
  fi
  reload_i3
}
