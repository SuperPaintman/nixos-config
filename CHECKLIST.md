# Checklist

This is a checklist with task to do after system installaction.

I think many of them should be replaced with a script.

## TODO

- [ ] Copy or generate a SSH key. `ssh-keygen -t rsa -b 4096`.

  - [ ] Add this key into your Github profile. `cat ~/.ssh/id_rsa.pub | pbcopy`.

- [ ] Update remote hosts in cloned repos (on the installation).

  - [ ] Dotfiles: `(cd ~/Projects/github.com/SuperPaintman/dotfiles && git remote set-url origin git@github.com:SuperPaintman/dotfiles.git)`.
  - [ ] NixOS Configuration: `(cd ~/Projects/github.com/SuperPaintman/nixos-config && git remote set-url origin git@github.com:SuperPaintman/nixos-config.git)`.

- [ ] Create token for **telethon** (using in `telegramstatus`).

  1. Login on <https://my.telegram.org/apps>.
  2. Create the config file and paste yout `api_id` and `api_hash`.

  ```sh
  $ mkdir -p ~/.telethon
  $ read -s API_ID
  $ read -s API_HASH
  $ cat << EOF > ~/.telethon/session.json
  {
    "api_id": $API_ID,
    "api_hash": "$API_HASH"
  }
  EOF
  ```

  3. Run `telegramstatus` and follow the instructions.

- [ ] Download the wallpaper. `curl -sL http://localhost -o ~/.wallpaper`.

- [ ] Setup Firefox.

  - [ ] Set the default search engine. `firefox about:preferences#search`.
