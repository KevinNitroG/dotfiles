# KEVINNITRO LINUX DOTFILES

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [TODO](#todo)
  - [Browser](#browser)
    - [Brave](#brave)
- [UTILS](#utils)
  - [Arch installation](#arch-installation)
  - [Rclone mount](#rclone-mount)
  - [Systemctl](#systemctl)
  - [XDG](#xdg)
  - [Fingerprint](#fingerprint)
  - [Tmux](#tmux)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

---

## TODO

### Browser

- Memory Saver
  ```
  www.youtube.com
  www.messenger.com
  ```

#### Brave

- Shield
  - Custom lists
    ```
    https://abpvn.com/vip/kev.txt?ublock
    https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt
    https://raw.githubusercontent.com/bogachenko/fuckfuckadblock/master/fuckfuckadblock.txt?_=rawlist
    https://raw.githubusercontent.com/bogachenko/fuckfuckadblock/master/fuckfuckadblock-mining.txt?_=rawlist
    ```
  - Custom filters: [custom filter](./dot_config/browser-data/adblock/custom_filters.txt)

---

## UTILS

### Arch installation

```sh
setfont ter-132n
```

### Rclone mount

> [!NOTE]
>
> Guide: https://github.com/rclone/rclone/wiki/Systemd-rclone-mount

- Create dir
  ```sh
  mkdir ~/<remote-name>
  ```
- Start service
  ```sh
  systemctl --user start rclone@<remote-name>
  ```
- Enable service _(auto start to mount)_
  ```sh
  systemctl --user enable rclone@<remote-name>
  ```

### Systemctl

- Clean services
  ```sh
  systemctl reset-failed
  ```

### XDG

- Set default application
  > Example for Brave
  ```sh
  xdg-settings set default-web-browser brave-browser.desktop
  xdg-mime default brave-browser.desktop x-scheme-handler/http
  xdg-mime default brave-browser.desktop x-scheme-handler/https
  xdg-mime default brave-browser.desktop x-scheme-handler/mailto
  ```

### Fingerprint

> [!NOTE]
>
> - Doc from ARCH: https://wiki.archlinux.org/title/fprint
> - Supported devices: https://fprint.freedesktop.org/supported-devices.html
> - My device _(Dell Vostro 14 5410)_: `27c6:639c	Goodix MOC Fingerprint Sensor`

### Tmux

- attach starting directory to current session ([Source](https://stackoverflow.com/a/54444853/23173098))
  ```tmux
  attach-session -t . -c /path/to/new/directory
  ```
