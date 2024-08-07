#!/bin/bash

# echo -e "line1\nline2" >> /tmp/file

################ DISABLE THE LINUX KERNEL WATCHDOG ################
echo -e "blacklist iTCO_wdt\nblacklist iTCO_vendor_support" >> /etc/modprobe.d/nowatchdog.conf

################ INTEL ################
pacman -Syu lib32-vulkan-intel intel-media-driver vulkan-intel --noconfirm || exit 1

################ NVIDIA ################
pacman -Syu nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader opencl-nvidia lib32-opencl-nvidia libva-nvidia-driver lib32-libvdpau nvidia-prime cuda --noconfirm || exit 1

# Nvidia Rules
echo -e "options nvidia \"NVreg_DynamicPowerManagement=0x03\" \noptions nvidia NVreg_PreserveVideoMemoryAllocations=1\noptions nvidia NVreg_TemporaryFilePath=/var/tmp\noptions nvidia NVreg_EnableGpuFirmware=0\noptions nvidia NVreg_UsePageAttributeTable=1\noptions nvidia_drm modeset=1 fbdev=1" >> /etc/modprobe.d/nvidia.conf

# Nvidia PM Rules
echo -e '# Remove NVIDIA USB xHCI Host Controller devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"

# Remove NVIDIA USB Type-C UCSI devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"

# Remove NVIDIA Audio devices, if present
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

# Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

# Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"' | sudo tee /etc/udev/rules.d/80-nvidia-pm.rules


# Enable nvidia services for suspension
systemctl enable nvidia-hibernate.service nvidia-suspend.service nvidia-persistenced.service nvidia-resume.service

########## ADDITIONAL PACKAGES ##########
pacman -Syu noto-fonts noto-fonts-cjk noto-fonts-emoji xdg-desktop-portal xdg-desktop-portal-gtk flatpak flatpak-xdg-utils power-profiles-daemon papirus-icon-theme ttf-dejavu --noconfirm || exit 1 
pacman -Syu ttf-droid distrobox podman pacman-contrib git curl wget bash-completion android-tools android-udev ntfs-3g nano acpid acpi acpi_call p7zip unarchiver unrar --noconfirm || exit 1 

########### KDE ############
pacman -Syu kdegraphics-thumbnailers ffmpegthumbs kdialog flatpak-kcm xdg-desktop-portal-kde spectacle switcheroo-control --noconfirm || exit 1

########### SERVICES ############
systemctl enable bluetooth.service paccache.service acpid.service switcheroo-control.service

########### LOGITECH USB UNIFIED PREVENT SLEEP FIX ############
echo -e "ACTION==\"add\", SUBSYSTEM==\"usb\", DRIVERS==\"usb\", ATTRS{idVendor}==\"046d\", ATTRS{idProduct}==\"c548\", ATTR{power/wakeup}=\"disabled\" \nACTION==\"add\", SUBSYSTEM==\"usb\", DRIVERS==\"usb\", ATTRS{idVendor}==\"046d\", ATTRS{idProduct}==\"0af7\", ATTR{power/wakeup}=\"disabled\"" >> /etc/udev/rules.d/90-usb-wakeup.rules

#####  ADD STEAM INPUT CONTROLLERS #####
wget https://raw.githubusercontent.com/ValveSoftware/steam-devices/master/60-steam-input.rules -O /etc/udev/rules.d/60-steam-input.rules

########### APDATIFIER  (KDE) ############
pacman -Syu pacman-contrib curl jq tar unzip xmlstarlet fzf --noconfirm || exit 1

########### SET EXPLICITY INSTALLED PACKAGES (Prevent from autoremove) ############
pacman -D --asexplicit kde-gtk-config sddm-kcm plasma-systemmonitor plasma-desktop oxygen-sounds kdeplasma-addons kgamma kwallet-pam kwrited plasma-browser-integration plasma-disks print-manager --noconfirm || exit 1

########### CONSISTENT KDE FILE DIALOG (KDE) ############
echo -e "GTK_USE_PORTAL=1\nXDG_CURRENT_DESKTOP=KDE" | tee -a /etc/environment

########### REMOVE UNUSED PACKAGES ############
pacman -R plasma-meta --noconfirm || exit 1
pacman -Rcns drkonqi htop vim discover krdp oxygen plasma-firewall plasma-thunderbolt plasma-vault plasma-welcome plasma-workspace-wallpapers --noconfirm || exit 1
pacman -Syu plasma-nm --noconfirm || exit 1
