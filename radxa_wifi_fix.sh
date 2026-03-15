#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root:"
  echo "sudo $0"
  exit 1
fi

echo "=== Fixing ROCK Pi 4B+ BCM43430 WiFi boot timing ==="

echo "[1] Blacklisting early driver load"
cat >/etc/modprobe.d/blacklist-brcmfmac.conf <<BL
blacklist brcmfmac
blacklist brcmutil
BL

echo "[2] Creating systemd loader service"

cat >/etc/systemd/system/rockpi-wifi.service <<SRV
[Unit]
Description=Load Broadcom WiFi driver
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/sbin/modprobe brcmfmac

[Install]
WantedBy=multi-user.target
SRV

echo "[3] Enabling service"
systemctl daemon-reload
systemctl enable rockpi-wifi.service

echo "[4] Reloading driver now"
modprobe -r brcmfmac brcmutil cfg80211 2>/dev/null || true
sleep 2
modprobe brcmfmac

echo
echo "WiFi should now work and persist after reboot."
