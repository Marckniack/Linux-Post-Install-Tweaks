#!/bin/bash

# echo -e "line1\nline2" >> /tmp/file

### DISABLE THE LINUX KERNEL WATCHDOG ###
echo -e "blacklist iTCO_wdt\blacklist iTCO_vendor_support" >> /etc/modprobe.d/nowatchdog.conf

################ INTEL ################
pacman -Syu lib32-vulkan-intel intel-media-driver vulkan-intel --noconfirm

################ NVIDIA ################
pacman -Syu nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader opencl-nvidia lib32-opencl-nvidia libva-nvidia-driver lib32-libvdpau nvidia-prime --noconfirm

# NVIDIA Rules
echo -e 'options nvidia "NVreg_DynamicPowerManagement=0x03" NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp NVreg_EnableGpuFirmware=0 NVreg_UsePageAttributeTable=1\options nvidia_drm modeset=1 fbdev=1' >> /etc/modprobe.d/nvidia.conf

# Enable nvidia services for suspension
systemctl enable nvidia-hibernate.service nvidia-suspend.service nvidia-persistenced.service

########## ADDITIONAL PACKAGES ##########
pacman -Syu noto-fonts noto-fonts-cjk noto-fonts-emoji xdg-desktop-portal xdg-desktop-portal-gtk flatpak flatpak-xdg-utils power-profiles-daemon papirus-icon-theme ttf-dejavu ttf-droid distrobox podman --noconfirm

### KDE ###
pacman -Syu kdegraphics-thumbnailers ffmpegthumbs kdialog flatpak-kcm xdg-desktop-portal-kde spectacle --noconfirm

########### SERVICES ############
systemctl enable bluetooth

########### LOGITECH USB UNIFIED PREVENT SLEEP FIX ############
echo -e 'ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", ATTR{power/wakeup}="disabled"' >> /etc/udev/rules.d/90-usb-wakeup.rules

#####  APDATIFIER  (KDE) #####
pacman -Syu pacman-contrib curl jq tar unzip xmlstarlet fzf --noconfirm

########### SET EXPLICITY INSTALLED PACKAGES (Prevent from autoremove) ############
pacman -D --asexplicit kde-gtk-config sddm-kcm plasma-systemmonitor plasma-desktop oxygen-sounds kdeplasma-addons kgamma kwallet-pam kwrited plasma-browser-integration plasma-disks print-manager --noconfirm

########### CONSISTENT KDE FILE DIALOG (KDE) ############
echo "GTK_USE_PORTAL=1\XDG_CURRENT_DESKTOP=KDE" | tee -a /etc/environment
