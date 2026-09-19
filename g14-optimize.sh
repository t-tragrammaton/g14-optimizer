#!/usr/bin/env bash
# G14 (Zephyrus, Ryzen + GTX 1650 hybrid) optimization for CachyOS.
# Review each section before running — comment out anything you don't want.
# Run with: chmod +x g14-optimize.sh && sudo ./g14-optimize.sh

set -e

echo "==> Installing/confirming core ASUS + power tooling"
sudo pacman -S --needed --noconfirm asusctl supergfxctl power-profiles-daemon \
  zram-generator irqbalance

echo "==> Enabling core services"
sudo systemctl enable --now asusd
sudo systemctl enable --now supergfxd
sudo systemctl enable --now power-profiles-daemon
sudo systemctl enable --now irqbalance

echo "==> GPU mode: Hybrid (confirmed correct from earlier tonight)"
supergfxctl -m Hybrid || true

echo "==> Setting up zram (helps with the fragmentation/OOM issues you hit tonight)"
sudo tee /etc/systemd/zram-generator.conf > /dev/null <<'EOF'
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF
sudo systemctl daemon-reload
sudo systemctl restart systemd-zram-setup@zram0.service || true

echo "==> Reducing swappiness (prefer RAM over swap/zram until actually needed)"
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-g14-swappiness.conf
sudo sysctl --system

echo "==> Fan curve: balanced default via asusctl (edit profile name if you use Performance/Quiet)"
asusctl profile -P Balanced || true

echo "==> Battery charge limit (extends battery lifespan — set to 80 if this stays plugged in a lot)"
asusctl -c 80 || true

echo "==> Power profile defaults: balanced on battery, performance on AC handled by power-profiles-daemon"
powerprofilesctl set balanced || true

echo "==> Confirming nvidia-drm.modeset is still in the Limine cmdline (should already be set from tonight)"
grep -q "nvidia-drm.modeset=1" /etc/limine.conf 2>/dev/null \
  || echo "WARNING: nvidia-drm.modeset=1 not found in /etc/limine.conf — re-check your kernel cmdline"

echo "==> Done. Reboot to apply zram + sysctl cleanly."
