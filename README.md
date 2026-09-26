# epidots

Functionality-first NixOS/EPITA rice that lives **entirely in AFS** (`~/afs`).
The system stays vanilla — home is wiped on every boot, so everything is
re-applied automatically at login.

## Install (school machine)

```sh
git clone https://github.com/clawdbot58-pixel/epidots.git /tmp/epidots
cp -r /tmp/epidots/.confs /tmp/epidots/rice ~/afs/
chmod +x ~/afs/rice ~/afs/.confs/install.sh
~/afs/rice on
```

Note: `.confs` is a dotfile — `cp -r /tmp/epidots/*` will NOT copy it.

That's it. Log out / in once and the rice applies itself from then on.

## On / off switch

```sh
~/afs/rice on      # apply (also auto-applies at every login from now on)
~/afs/rice off     # remove everything we added — back to vanilla, takes effect immediately
~/afs/rice status  # what's enabled, what's linked, profile state
~/afs/rice sync    # force re-install packages (after editing manifest.txt)
```

`rice on` / `rice off` restart i3 right away — no logout needed.

## Keyboard shortcuts

`Mod` = the Windows/Super key. Bindings live in `.confs/config/i3/config`.

### Launch

| Keys | Action |
|---|---|
| `Mod+Return` | terminal (alacritty) |
| `Mod+d` | app launcher (rofi) |
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
| `Print` / `Mod+Shift+s` | region screenshot → `~/Pictures/` |
| `Mod+Shift+c` | reload i3 config |
| `Mod+Shift+r` | restart i3 (picks up daemons too) |
| Volume keys | volume up / down / mute |

## Terminal tips

- **zsh is your shell** — login shells hand over to it automatically (no
  `chsh` needed; `/etc/passwd` is reset at every boot anyway). Plain `bash`
  stays vanilla if you start it yourself.
- **suggestions**: type a command → grey suggestion appears → `→` to accept;
  syntax highlighting turns valid commands green; a mistyped command gets a
  `correct` prompt (say `y`).
- **fuck**: typo in the last command? `fuck` fixes and re-runs it
  (pay-respects, the maintained thefuck alternative).
- **fzf**: `Ctrl+R` fuzzy history · `Ctrl+T` fuzzy file pick · `Alt+C` fuzzy cd
- **zoxide**: `z dir` jumps to a directory you use often (after `cd`ing there)
- **eza**: `ll`, `la`, `lt` (tree), plain `ls` grouped by directory
- **bat**: `cat` now pages with syntax highlighting
- **ranger**: file manager in the terminal (arrow keys, `q` to quit, `?` help)
- **tmux**: mouse on — click panes, drag status bar, scroll with the wheel;
  `tmux` to start

## What you get

- **rofi** launcher, **alacritty** terminal, **thunar** file manager
- **VSCodium** with Python extension (dot-completions, no Pylance needed)
- **zsh** as the default shell (autosuggestions, syntax highlighting,
  typo-correction, completions), **fzf**, **pay-respects** (`fuck`)
- **eza / bat / fd / ripgrep / zoxide / starship / ranger**
- **tmux**, **btop**, **dunst** notifications, **xss-lock + xautolock** (5 min)
- **picom** with vsync (no tearing when moving windows)
- The vanilla EPITA wallpaper stays untouched (stealth mode). To use your own:
  `echo /path/to/img > ~/afs/.confs/wallpaper`

## Adding / removing packages

Edit `.confs/manifest.txt` (one package per line), then:

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
    └── config/i3/config # -> ~/.config/i3/config
```

## Uninstall

`~/afs/rice off` — or, for full stock EPITA defaults:

```sh
rm -rf ~/afs/.confs ~/afs/rice
cp -r /afs/cri.epita.fr/resources/confs/* ~/afs/.confs/
```
