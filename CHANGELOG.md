# Changelog

Notable changes to epidots. **Requests and bugs → [GitHub issues](https://github.com/clawdbot58-pixel/epidots/issues).**

## [0.95] — 2026-10-02

### Added

- **Automatic updates** — at every i3 launch a silent background job checks
  GitHub (7-day gate, only pulls when something actually changed) and then
  installs new packages + config. Opt out: `touch ~/afs/.confs/no-autoupdate`.
- **fastfetch** — new manifest package; run `fastfetch` for a system-info dump.
- Screenshot viewer: `shot` opens the capture instantly in **feh** (lightweight).
- Screenshots persist: `~/Pictures` now links into AFS (`~/.confs/pictures`) —
  survives reboots and seat changes.
- `rice diag` — one-command health report (links, profile, i3 parse check, login hook).
- `rice update` and `rice uninstall`, plus `installer.sh` / `uninstall.sh` one-liners.
- Seat-switch self-heal: a nix profile built on another seat is detected and
  rebuilt automatically at the next login.
- `i3lock` entry in the Mod+d launcher; tmux pane/window binds keep the
  current working directory.

### Safety

- **Never-bricked**: the PAM login hook always exits 0 (a broken rice can't
  block a login); `rice update` refuses updates whose shell files don't parse
  or whose i3 config fails `i3 -C`; `apply` never restarts i3 onto a config
  that doesn't parse; `~/afs/rice off` is an instant vanilla escape hatch.

### Changed

- i3 exec lines moved into `.confs/bin/*` — old i3 versions mis-parse `;`
  inside exec strings (parse errors at session start are gone).
- `setopt CORRECT` removed from zsh — type `fuck` when you misspell a command.
- `.github-sha` marker is written only after the files have landed, so a
  failed copy can never look "up to date".

## [0.9] — 2026-10-01

### Added

- First public version: AFS-only rice, `rice on|off|status|sync` CLI, PAM
  auto-apply at every login, zsh as default shell, i3 config + daemons
  (picom, dunst, xss-lock/xautolock), manifest-driven nix profile,
  one-line `installer.sh`, wholesale `~/.config` merge
  (aligned with [tsunooky/epidots](https://github.com/tsunooky/epidots)),
  history + stock dotfiles kept in AFS.
