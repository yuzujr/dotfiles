#!/usr/bin/env bash

# 10分钟锁屏，30分钟熄屏
exec swayidle \
  timeout 600 'qs -c noctalia-shell ipc call lockScreen lock' \
  timeout 1800 'niri msg action power-off-monitors' \
  resume 'niri msg action power-on-monitors'
