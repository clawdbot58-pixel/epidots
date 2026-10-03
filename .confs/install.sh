#!/bin/sh
# Called by PAM (pam_epita) at every login and screen unlock, as the user,
# with AFS_DIR set. Applies the rice only if enabled.
# SAFETY: all work runs in a subshell and this script ALWAYS exits 0 —
# a broken rice can annoy a session but can NEVER block a login.
export PATH="/run/current-system/sw/bin:$PATH"
AFS_DIR="${AFS_DIR:-$HOME/afs}"
CONF="$AFS_DIR/.confs"

(
  [ -f "$CONF/lib.sh" ] || exit 0
  # dash aborts the whole script when sourcing a file that doesn't parse —
  # pre-check so a broken lib.sh degrades to "no rice today", not "no login"
  sh -n "$CONF/lib.sh" 2>/dev/null || exit 0
  . "$CONF/lib.sh" || exit 0

  # rice off (or not installed yet): still link the stock EPITA dotfiles
  # (gitconfig, ssh, …) so replacing the stock install.sh never breaks them.
  if [ ! -f "$CONF/enabled" ]; then
    link_stock_dots
    exit 0
  fi
  apply
)
exit 0
