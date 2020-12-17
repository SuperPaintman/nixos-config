# Checklist

This is a checklist with task to do after system installaction.

I think many of them should be replaced with a script.

## TODO

- [ ] Copy or generate a SSH key. `ssh-keygen -t rsa -b 4096`.
  - [ ] Add this key into your Github profile. `cat ~/.ssh/id_rsa.pub | pbcopy`.
- [ ] Update remote hosts in cloned repos (on the installation).
  - [ ] Dotfiles: `(cd ~/Projects/github.com/SuperPaintman/dotfiles && git remote set-url origin git@github.com:SuperPaintman/dotfiles.git)`.
  - [ ] NixOS Configuration: `(cd ~/Projects/github.com/SuperPaintman/nixos-config && git remote set-url origin git@github.com:SuperPaintman/nixos-config.git)`.
