#!/bin/sh
# Called by PAM (pam_epita) at every login and screen unlock, as the user,
# with AFS_DIR set. Applies the rice only if enabled. Never breaks a login.
export PATH="/run/current-system/sw/bin:$PATH"
AFS_DIR="${AFS_DIR:-$HOME/afs}"
CONF="$AFS_DIR/.confs"

[ -f "$CONF/enabled" ] || exit 0
[ -f "$CONF/lib.sh" ] || exit 0

. "$CONF/lib.sh"
apply
exit 0
