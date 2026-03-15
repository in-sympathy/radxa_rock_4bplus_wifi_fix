# ROCK Pi 4B+ WiFi Fix (AW‑NB197SM / BCM43430)

Fixes WiFi not appearing after boot on **Radxa ROCK Pi 4B+** running
**Radxa OS (Debian Bookworm)**.

This script resolves a common issue where the onboard WiFi module
**AW‑NB197SM (Broadcom BCM43430)** fails to initialize during boot.

------------------------------------------------------------------------

# Problem

On some Radxa OS builds, the WiFi driver (`brcmfmac`) loads **too early
during the boot process**, before the SDIO WiFi device is fully
initialized.

As a result:

-   WiFi works **after manually reloading the driver**
-   but **disappears after reboot**

Typical symptom:

`wlan0` missing after boot

but WiFi appears if you run:

modprobe -r brcmfmac\
modprobe brcmfmac

------------------------------------------------------------------------

# Root Cause

The kernel loads the `brcmfmac` module during early boot.

At that moment the **SDIO WiFi chip is not ready**, so firmware loading
fails and the driver never retries.

------------------------------------------------------------------------

# Hardware

This fix targets the onboard WiFi module used on:

**Radxa ROCK Pi 4B+**

Module:

AzureWave AW‑NB197SM

Chipset:

Broadcom / Cypress BCM43430

Specifications:

  Feature     Value
  ----------- --------------
  Interface   SDIO
  WiFi        2.4GHz only
  Standards   802.11 b/g/n
  Bluetooth   4.1

⚠️ **Important:** This module does **NOT support 5GHz WiFi**.

------------------------------------------------------------------------

# Solution

The fix delays loading the WiFi driver until **after the system finishes
booting**.

This ensures:

-   SDIO bus is initialized
-   firmware is accessible
-   WiFi starts correctly

The script does this by:

1.  Preventing the kernel from loading the driver early
2.  Creating a **systemd service** that loads the driver after boot

------------------------------------------------------------------------

# Installation

Download the script:

curl -O
https://raw.githubusercontent.com/`<repo>`{=html}/rockpi_wifi_fix.sh

Make it executable:

chmod +x rockpi_wifi_fix.sh

Run the fix:

sudo ./rockpi_wifi_fix.sh

Reboot:

sudo reboot

------------------------------------------------------------------------

# After Reboot

Verify WiFi:

ip a

You should see:

wlan0

or

wlp\*

------------------------------------------------------------------------

# What the Script Does

1.  Blacklists early driver loading

Creates:

/etc/modprobe.d/blacklist-brcmfmac.conf

2.  Creates a systemd service

/etc/systemd/system/rockpi-wifi.service

3.  Loads the driver after boot

modprobe brcmfmac

------------------------------------------------------------------------

# Compatibility

Tested on:

-   ROCK Pi 4B+
-   Radxa OS Bookworm
-   Kernel 6.1.x

------------------------------------------------------------------------

# Reverting the Fix

To restore the original behavior:

sudo rm /etc/modprobe.d/blacklist-brcmfmac.conf\
sudo rm /etc/systemd/system/rockpi-wifi.service\
sudo systemctl daemon-reload\
sudo reboot

------------------------------------------------------------------------

# License

MIT License
