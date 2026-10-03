# epidots

Functionality-first NixOS/EPITA rice that lives **entirely in AFS** (`~/afs`).
The system stays vanilla — home is wiped on every boot, so everything is
re-applied automatically at login.

**Version `v0.95`** — patch notes: [CHANGELOG.md](CHANGELOG.md) ·
releases: [GitHub Releases](https://github.com/clawdbot58-pixel/epidots/releases) ·
requests: [GitHub issues](https://github.com/clawdbot58-pixel/epidots/issues)

## Install (school machine)

One line (same idea as [tsunooky/epidots](https://github.com/tsunooky/epidots)):

```sh
curl -L https://raw.githubusercontent.com/clawdbot58-pixel/epidots/main/installer.sh | sh
```

Manual equivalent:

```sh
git clone --depth 1 https://github.com/clawdbot58-pixel/epidots.git /tmp/epidots
mkdir -p ~/afs/.confs
cp -r /tmp/epidots/.confs/. ~/afs/.confs/   # merges — stock files (gitconfig, ssh, …) are kept
cp /tmp/epidots/rice ~/afs/rice
chmod +x ~/afs/rice ~/afs/.confs/install.sh
~/afs/rice on
```

Note: `.confs` is a dotfile — `cp -r /tmp/epidots/*` will NOT copy it.

That's it — nothing else. The login hook that re-applies the rice
(`pam_epita` running `~/afs/.confs/install.sh` at every login/unlock) is a
**stock nixpie feature**, exactly the mechanism tsunooky/epidots relies on,
and everything lives in `~/afs` + symlinks in your home — the system itself
is never modified. The stock EPITA dotfiles seeded in `~/afs/.confs`
(gitconfig, ssh, signature, …) keep working whether the rice is on or off.
Log out / in once and the rice applies itself from then on.

## On / off switch

```sh
~/afs/rice on      # apply (also auto-applies at every login from now on)
~/afs/rice off     # remove everything we added — back to vanilla, takes effect immediately
~/afs/rice status  # what's enabled, what's linked, profile state
~/afs/rice sync    # re-apply + reinstall packages (after editing manifest.txt)
~/afs/rice update  # self-update: pull the latest rice from GitHub and re-apply
~/afs/rice diag    # read-only diagnostic report (paste it when something breaks)
~/afs/rice uninstall  # remove the rice, restore vanilla desktop
```

`rice on` / `rice off` restart i3 right away — no logout needed (also works
from a plain SSH terminal: the display is picked up from your session).

## Keyboard shortcuts

`Mod` = the Windows/Super key. Bindings live in `.confs/config/i3/config`.

### Launch

| Keys | Action |
|---|---|
| `Mod+Return` | terminal (alacritty) |
| `Mod+d` | app launcher (rofi; includes a **Lock screen** entry) |
| `Mod+t` | editor (VSCodium, Python out of the box) |

### Windows

| Keys | Action |
|---|---|
| `Mod+Shift+q` | close window |
| `Mod+Shift+space` | pop window out of the layout (floating) / back in |
| `Mod+space` | focus the other window (mode toggle) |
| `Mod+f` | fullscreen toggle |
| `Mod+a` | focus parent container |
| `Mod+left-drag` | move window (floating or tiled) |
| `Mod+right-drag` | resize window |
| `Mod+Shift+e` | exit i3 (confirmation bar) |

### Focus / move

| Keys | Action |
|---|---|
| `Mod+j/k/l/;` | focus left / down / up / right |
| `Mod+arrows` | same, with arrow keys |
| `Mod+Shift+j/k/l/;` or `Mod+Shift+arrows` | move window in that direction |

### Layout & workspaces

| Keys | Action |
|---|---|
| `Mod+h` / `Mod+v` | split horizontal / vertical |
| `Mod+s` / `Mod+w` / `Mod+e` | stacking / tabbed / toggle split |
| `Mod+1..0` | switch to workspace 1–10 |
| `Mod+Shift+1..0` | move window to workspace 1–10 |
| `Mod+r` then `j/k/l/;` | resize mode (Enter/Esc to exit) |

### Session

| Keys | Action |
|---|---|
| `Mod+Ctrl+l` | lock now (also locks automatically after 5 min idle) |
| `Print` / `Mod+Shift+s` | region screenshot → `~/Pictures/`, **opens instantly in feh** (lightweight viewer) |
| `Mod+Shift+c` | reload i3 config |
| `Mod+Shift+r` | restart i3 (picks up daemons too) |
| Volume keys | volume up / down / mute |

`~/Pictures` is a link into AFS — screenshots survive reboots and seat
changes (clear old ones occasionally, they count against the 10 GB quota).

## Terminal tips

- **zsh is your shell** — login shells hand over to it automatically (no
  `chsh` needed; `/etc/passwd` is reset at every boot anyway). Plain `bash`
  stays vanilla if you start it yourself.
- **suggestions**: type a command → grey suggestion appears → `→` to accept;
  syntax highlighting turns valid commands green. No auto correction popups —
  corrections are **manual**: type the bad command, then run `fuck`.
- **fuck** (pay-respects, the maintained thefuck): typed a wrong command?
  `fuck` (or just `f`) shows the fix → `Enter` runs it. `ff` runs the best
  fix without asking. `Ctrl+X` `Ctrl+X` fixes the line in place without
  running it (`git comit` → `git commit`, `cd payrespe` → the full path).
- **fzf**: `Ctrl+R` fuzzy history · `Ctrl+T` fuzzy file pick · `Alt+C` fuzzy cd
- **zoxide**: `z dir` jumps to a directory you use often (after `cd`ing there)
- **eza**: `ll`, `la`, `lt` (tree), plain `ls` grouped by directory
- **bat**: `cat` now pages with syntax highlighting
- **vim**: ships with syntax highlighting, line numbers, mouse support
  (system `vim`, config in `.confs/vimrc`)
- **ranger**: file manager in the terminal (arrow keys, `q` to quit, `?` help)
- **tmux**: mouse on — click panes, drag status bar, scroll with the wheel;
  `tmux` to start; new windows/panes (`prefix c`, `prefix %`, `prefix "`)
  always open in the **current pane's directory**, never $HOME

## What you get

- **rofi** launcher, **alacritty** terminal, **thunar** file manager
- **VSCodium** with Python extension (dot-completions, no Pylance needed)
- **zsh** as the default shell (autosuggestions, syntax highlighting,
  completions), **fzf**, **pay-respects** (`fuck`)
- **eza / bat / fd / ripgrep / zoxide / starship / ranger**
- **vim** with syntax highlighting (`.confs/vimrc`)
- **tmux**, **btop**, **dunst** notifications, **xss-lock + xautolock** (5 min)
- **picom** with vsync (no tearing when moving windows)
- The vanilla EPITA wallpaper stays untouched (stealth mode). To use your own:
  `echo /path/to/img > ~/afs/.confs/wallpaper`

## Adding / removing packages

Edit `.confs/manifest.txt` (one package per line), then:

```sh
~/afs/rice sync     # installs new/changed packages (hash-based)
```

To fully drop a package that is no longer in the manifest:

```sh
rm -rf ~/afs/.confs/nix-profile   # force a full re-install
~/afs/rice sync
```

Binaries live in `/nix/store`, profile symlinks in AFS — a few KB each,
well under the 10 GB quota.

## How it works

- nixpie's PAM (`pam_epita`) runs `~/afs/.confs/install.sh` at **every login**
  (GUI, SSH, screen unlock). It does nothing unless `~/afs/.confs/enabled` exists.
- `install.sh` symlinks dotfiles from `.confs/` into `$HOME` and keeps
  `~/.nix-profile` pointed at `.confs/nix-profile` (a profile full of symlinks
  into `/nix/store` — a few KB of AFS).
- The **stock EPITA dotfiles** a school seat seeds into `~/afs/.confs`
  (gitconfig, gitignore, ssh, signature, …) are linked too — same list as
  the stock `install.sh` / tsunooky/epidots — so nothing regresses on a real
  seat, whether the rice is on or off. `~/.config` is linked wholesale into
  `.confs/config` (stock behaviour) when the home is fresh.
- Shell **history lives in AFS** (`.confs/.zsh_history`) and survives reboots.
- Packages come from `.confs/manifest.txt` and are installed with
  `nix profile install --profile` only when the manifest changes (so logins
  stay fast).
- `rice off` deletes the `enabled` flag, removes only symlinks pointing into
  `~/afs`, regenerates the stock EPITA i3 config (Windows key = mod, via
  `i3-config-wizard`), and stops the daemons — your home is vanilla again
  and nothing runs at next login.

## How the pieces fit together

```text
login (PAM) ──▶ install.sh ──▶ lib.sh apply() ──▶ symlinks + nix profile
                     │                                │
                     │                                ├─ .profile   ─▶ hands login shell to zsh
                     │                                ├─ .bashrc    ─▶ vanilla fallback
                     │                                ├─ .zshrc     ─▶ suggestions, fuck, fzf…
                     │                                ├─ .tmux.conf ─▶ mouse on
                     │                                └─ i3 config  ─▶ Mod+Return, rofi…
                     └─ only if ~/afs/.confs/enabled exists

rice on  = create enabled, apply, restart i3
rice off = delete enabled, unlink AFS symlinks, EPITA default i3, stop daemons
```

## Layout

```
~/afs/
├── rice                 # the on/off switch
└── .confs/
    ├── enabled          # flag: rice is on (created by `rice on`)
    ├── install.sh       # PAM entry point (runs at every login)
    ├── lib.sh           # apply/unapply logic
    ├── manifest.txt     # package list (edit + `rice sync`)
    ├── nix-profile/     # nix profile (symlinks to /nix/store; ~KB)
    ├── bashrc           # -> ~/.bashrc (vanilla fallback)
    ├── profile          # -> ~/.profile (hands login shell to zsh)
    ├── zshrc            # -> ~/.zshrc
    ├── tmux.conf        # -> ~/.tmux.conf
    ├── picom.conf       # vsync compositor config
    ├── wallpaper        # optional: path to an image
    ├── pictures/        # screenshots (~/Pictures -> here, survives wipes)
    ├── bin/             # helper scripts (shot, daemons, menu, autoupdate, ...)
    ├── local-share/     # i3lock launcher entry, etc.
    └── config/i3/config # -> ~/.config/i3/config
```

## Update / self-repair

**Automatic**: at every i3 launch a quiet background job checks GitHub
(only every 7 days, only pulls when something actually changed) and
re-applies. Opt out with:

```sh
touch ~/afs/.confs/no-autoupdate
```

Manual:

```sh
~/afs/rice update   # git-pull the latest rice into ~/afs and re-apply
~/afs/rice diag     # read-only report: links, profile health, i3 parse check, login hook
```

Note: auto-update refreshes `.confs` from GitHub — local edits to
`manifest.txt`/configs get overwritten (re-apply them upstream, or opt out).

No git? The installer one-liner from the top of this README also updates:

```sh
curl -L https://raw.githubusercontent.com/clawdbot58-pixel/epidots/main/installer.sh | sh
```

### Switching computers (rofi/zsh "disappeared", `rice sync` seemed to do nothing)

The nix profile lives in AFS (shared between seats) but `/nix/store` is
**per-seat** — binaries installed on one computer don't resolve on another.
`rice` detects this (manifest hash matches but binaries don't run) and
reinstalls **automatically** — on the first login on a new seat, or any time
you run `rice sync` / `rice on`. To see what's happening:

```sh
~/afs/rice diag     # shows the "profile unusable" line + the fix
~/afs/rice sync     # forces the reinstall for THIS computer now
```

## Never-bricked by design

Auto-updates are safe by construction:

- **Login can never be blocked.** The PAM hook (`install.sh`) always exits 0 —
  a broken rice degrades to "no rice today", never "no session".
- **Broken updates are refused.** `rice update` syntax-checks every shell
  file and parse-checks the i3 config (`i3 -C`) *before* installing;
  anything that fails keeps your current working version.
- **i3 never restarts onto a bad config.** If the config on disk doesn't
  parse, `apply` skips the reload and your current session stays up.
- **Instant escape hatch**, works even with everything else broken:

```sh
~/afs/rice off      # vanilla desktop immediately
curl -L https://raw.githubusercontent.com/clawdbot58-pixel/epidots/main/installer.sh | sh   # restore
```

## Uninstall

```sh
~/afs/rice uninstall
```

Or without any rice installed (fetches it first):

```sh
curl -L https://raw.githubusercontent.com/clawdbot58-pixel/epidots/main/uninstall.sh | sh
```

This removes the rice's links and files, stops the daemons and restores the
vanilla EPITA desktop. Stock EPITA dotfiles (`~/afs/.confs/gitconfig`, `ssh`,
…), your shell history and VS Code state are kept. Installed packages are
kept too (they cost a few KB of AFS symlinks); to remove them as well:

```sh
rm -rf ~/afs/.confs/nix-profile
```
