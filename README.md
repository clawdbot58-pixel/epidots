# epidots

Functionality-first NixOS/EPITA rice that lives **entirely in AFS** (`~/afs`).
The system stays vanilla — home is wiped on every boot, so everything is
re-applied automatically at login.

## On / off switch

```sh
~/afs/rice on      # apply (also auto-applies at every login from now on)
~/afs/rice off     # remove everything we added — back to vanilla
~/afs/rice status  # what's enabled, what's linked, profile state
~/afs/rice sync    # force re-apply (after editing manifest.txt)
```

## How it works

- nixpie's PAM (`pam_epita`) runs `~/afs/.confs/install.sh` at **every login**
  (GUI, SSH, screen unlock). It does nothing unless `~/afs/.confs/enabled` exists.
- `install.sh` symlinks dotfiles from `.confs/` into `$HOME` and keeps
  `~/.nix-profile` pointed at `.confs/nix-profile` (a profile full of symlinks
  into `/nix/store` — a few KB of AFS, well under the 10 GB quota).
- Packages come from `.confs/manifest.txt` and are installed with
  `nix profile install --profile` only when the manifest changes (so logins
  stay fast). Binaries live in `/nix/store`, **not** in AFS.
- `rice off` deletes the `enabled` flag and removes only symlinks that point
  into `~/afs` — your home is vanilla again and nothing runs at next login.

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
    ├── bashrc           # -> ~/.bashrc and ~/.profile
    ├── zshrc            # -> ~/.zshrc
    ├── tmux.conf        # -> ~/.tmux.conf
    ├── wallpaper        # optional: path to an image (else solid color)
    └── config/i3/config # -> ~/.config/i3/config
```

## What you get

- **rofi** launcher (`Mod+d`), **alacritty** (`Mod+Return`), **thunar** file manager
- **zsh** with autosuggestions, syntax highlighting, completions; **fzf** (Ctrl-R / Ctrl-T / Alt-C)
- **eza / bat / fd / ripgrep / zoxide / starship** aliases and prompt
- **tmux** (mouse on), **btop**, **ncdu**, **htop** (last two are already on nixpie)
- **dunst** notifications, **xss-lock** auto-lock, region screenshots (`Print`)
- solid dark background (`#1e1e2e`) instead of the EPITA image; set an image with
  `echo /path/to/img > ~/afs/.confs/wallpaper`

## Fresh install (school machine)

```sh
git clone https://github.com/clawdbot58-pixel/epidots.git /tmp/epidots
cp -r /tmp/epidots/.confs /tmp/epidots/rice ~/afs/
chmod +x ~/afs/rice ~/afs/.confs/install.sh
~/afs/rice on
```

Note: `.confs` is a dotfile — `cp -r /tmp/epidots/*` will NOT copy it.

## Uninstall

`~/afs/rice off` — or, for full stock EPITA defaults:

```sh
rm -rf ~/afs/.confs ~/afs/rice
cp -r /afs/cri.epita.fr/resources/confs/* ~/afs/.confs/
```
