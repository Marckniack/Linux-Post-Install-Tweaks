#!/bin/bash

function setup_common()
{
	################ DISABLE THE LINUX KERNEL WATCHDOG ################
	echo -e "blacklist iTCO_wdt\nblacklist iTCO_vendor_support" >> /etc/modprobe.d/nowatchdog.conf

	########### INTEL WIFI RULES ############
	echo -e '# Enable antenna aggregation
	options iwlwifi 11n_disable=8

	# Disable Power Save
	options iwlwifi power_save=0' | sudo tee /etc/modprobe.d/wifi.conf

	################ INTEL ################
	pacman -Syu lib32-vulkan-intel intel-media-driver vulkan-intel --noconfirm || exit 1

	################ NVIDIA ################
	pacman -Syu nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader opencl-nvidia lib32-opencl-nvidia libva-nvidia-driver lib32-libvdpau nvidia-prime cuda --noconfirm || exit 1

	# Nvidia Rules
	echo -e 'options nvidia "NVreg_DynamicPowerManagement=0x03"
	options nvidia NVreg_PreserveVideoMemoryAllocations=1
	options nvidia NVreg_TemporaryFilePath=/var/tmp
	options nvidia NVreg_EnableGpuFirmware=0
	options nvidia NVreg_UsePageAttributeTable=1
	options nvidia_drm modeset=1 fbdev=1' | sudo tee /etc/modprobe.d/nvidia.conf

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
	pacman -Syu noto-fonts noto-fonts-cjk noto-fonts-emoji flatpak flatpak-xdg-utils power-profiles-daemon papirus-icon-theme ttf-dejavu --noconfirm || exit 1
	pacman -Syu ttf-droid distrobox podman pacman-contrib git curl wget bash-completion android-tools android-udev ntfs-3g nano acpid acpi acpi_call p7zip unarchiver unrar --noconfirm || exit 1 

	########### SERVICES ############
	systemctl enable bluetooth.service paccache.service acpid.service switcheroo-control.service
	
	########### USB PREVENT SLEEP FIX ############
	echo -e '# Prevent USB Devices from waking up pc
	ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", ATTR{power/wakeup}="disabled", ATTR{driver/1-10/power/wakeup}="disabled"
	ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0af7", ATTR{power/wakeup}="disabled", ATTR{driver/1-9/power/wakeup}="disabled"' | sudo tee /etc/udev/rules.d/50-usb-wakeup.rules
	
	########### USB PREVENT SLEEP FIX ############
	echo -e 'w+ /proc/acpi/wakeup - - - - XHCI' | sudo tee /etc/tmpfiles.d/disable-usb-wake.conf
	
	#####  ADD STEAM INPUT CONTROLLERS #####
	wget https://raw.githubusercontent.com/ValveSoftware/steam-devices/master/60-steam-input.rules -O /etc/udev/rules.d/60-steam-input.rules

}

function setup_kde()
{
	echo "Setup KDE";
	
	########### KDE ############
	pacman -Syu kdegraphics-thumbnailers ffmpegthumbs kdialog flatpak-kcm xdg-desktop-portal-kde spectacle switcheroo-control xdg-desktop-portal-gtk --noconfirm || exit 1

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
}

function setup_gnome()
{
	echo "Setup GNOME";
	
	########### GNOME ############
	pacman -Syu webp-pixbuf-loader gst-plugin-pipewire gst-plugins-good ffmpegthumbnailer switcheroo-control gnome-themes-extra --noconfirm || exit 1
	
	#### FORCE ENABLE WAYLAND ####
	ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
	
	########### REMOVE UNUSED PACKAGES ############
	pacman -Rcns gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-connections gnome-contacts gnome-font-viewer gnome-logs gnome-maps --noconfirm || exit 1
	pacman -Rcns gnome-software gnome-shell-extensions gnome-remote-desktop gnome-tour gnome-weather totem gnome-music vim htop yelp baobab --noconfirm || exit 1
	pacman -Rcns epiphany evince gnome-system-monitor loupe tracker3-miners network-manager-applet --noconfirm || exit 1
}

function menu()
{
	PS3='Select Options: '
	options=("Setup KDE" "Setup GNOME" "Quit")
	select opt in "${options[@]}"
	do
		  case $opt in
		      "Setup KDE")
		          setup_kde
		          break
		          ;;
		      "Setup GNOME")
		          setup_gnome
		          break
		          ;;
		      "Quit")
		          break
		          ;;
		      *) echo "invalid option $REPLY";;
		  esac
	done
}

# Setup common packages and settings
setup_common

# Run Menu
menu


