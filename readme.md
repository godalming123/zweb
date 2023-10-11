# Zweb
Imagine surf but:
- Works with wayland
- Upgraded to gtk4 and the latest version of webkit
- Rewritten in zig

This is what zweb aims to be.

## Features (still WIP)
- Display basic webpages
- Simple custom new tab page that works offline
- Basic keybindings - ctrl + ...:
  - [r]eload
  - go [h]ome
  - [<-] backwards in history
  - [->] forwards in history

## Installation
### 1. Get dependencys
 - `zig` at 0.11
 - `webkitgtk-6.0`
### 2. Build
Build zweb with `zig build`. This produces a binary which can be installed with `sudo cp zig-out/bin/zweb /bin/`.
### 3. Run
Run zweb with the command `zweb`.
