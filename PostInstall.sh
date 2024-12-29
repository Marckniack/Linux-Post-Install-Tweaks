#!/bin/bash

############# HOW TO USE #############
# curl -sL https://raw.githubusercontent.com/Marckniack/Linux-Post-Install-Tweaks/main/PostInstall.sh | bash -s kde
# curl -sL https://raw.githubusercontent.com/Marckniack/Linux-Post-Install-Tweaks/main/PostInstall.sh | bash -s gnome
# curl -sL https://raw.githubusercontent.com/Marckniack/Linux-Post-Install-Tweaks/main/PostInstall.sh | bash -s kde_flatpak
# curl -sL https://raw.githubusercontent.com/Marckniack/Linux-Post-Install-Tweaks/main/PostInstall.sh | bash -s gnome_flatpak
# curl -sL https://raw.githubusercontent.com/Marckniack/Linux-Post-Install-Tweaks/main/PostInstall.sh | bash -s kde_post
# curl -sL https://raw.githubusercontent.com/Marckniack/Linux-Post-Install-Tweaks/main/PostInstall.sh | bash -s gnome_post
######################################

base_common()
{
	################ DISABLE THE LINUX KERNEL WATCHDOG ################
echo -e "blacklist iTCO_wdt\nblacklist iTCO_vendor_support" >> /etc/modprobe.d/nowatchdog.conf

	########### INTEL WIFI RULES ############
echo -e '# Disable 11n functionality, bitmap: 1: full, 2: disable agg TX, 4: disable agg RX, 8 enable agg TX (uint)
options iwlwifi 11n_disable=1 swcrypto=1

# Enable WiFi power management (default: disable) (bool)
options iwlwifi power_save=0

# Fix Wifi Disconnect on suspend
# Power management scheme: 1-active, 2-balanced, 3-low power, default: 2 (int)
options iwlmvm power_scheme=1' | sudo tee /etc/modprobe.d/wifi.conf

	################ INTEL ################
	pacman -Syu lib32-vulkan-intel intel-media-driver vulkan-intel --noconfirm || exit 1

	################ NVIDIA MKINITCPIO ################
 	sed -i "/etc/mkinitcpio.conf" -e "s|MODULES=(|MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm |"
  	sed -i "/etc/mkinitcpio.conf" -e "s/\ kms//g"

	################ NVIDIA ################
	pacman -Syu nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader opencl-nvidia lib32-opencl-nvidia libva-nvidia-driver lib32-libvdpau nvidia-prime cuda --noconfirm || exit 1

	# Nvidia Rules
echo -e 'options nvidia "NVreg_DynamicPowerManagement=0x03"
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
options nvidia NVreg_EnableGpuFirmware=0
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_EnableResizableBar=1
options nvidia_drm fbdev=1
options nvidia_drm modeset=1' | sudo tee /etc/modprobe.d/nvidia.conf


	# Drivers Blacklist
echo -e 'blacklist nvidiafb
blacklist rivafb
blacklist i2c_nvidia_gpu
blacklist nouveau' | sudo tee /etc/modprobe.d/drivers-blacklist.conf

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
	# nvidia-powerd.service work only with Mobile GPUs
	systemctl enable nvidia-hibernate.service nvidia-suspend.service nvidia-persistenced.service nvidia-resume.service
	
	########## ADDITIONAL PACKAGES ##########
	pacman -Syu noto-fonts noto-fonts-cjk noto-fonts-emoji flatpak flatpak-xdg-utils power-profiles-daemon papirus-icon-theme ttf-dejavu fwupd gamemode lib32-gamemode system-config-printer bluez-obex --noconfirm || exit 1
	pacman -Syu ttf-droid distrobox podman pacman-contrib git curl wget bash-completion android-tools android-udev ntfs-3g nano acpid acpi acpi_call p7zip zip unarchiver unrar switcheroo-control --noconfirm || exit 1

 	# Webcam DKMS
 	pacman -Syu v4l2loopback-dkms
	
	########### USB PREVENT SLEEP FIX ############
echo -e '# Prevent USB Devices from waking up pc
ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", ATTR{power/wakeup}="disabled", ATTR{driver/1-10/power/wakeup}="disabled"
ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0af7", ATTR{power/wakeup}="disabled", ATTR{driver/1-9/power/wakeup}="disabled"' | sudo tee /etc/udev/rules.d/50-usb-wakeup.rules
	
	########### USB PREVENT SLEEP FIX ############
echo -e 'w+ /proc/acpi/wakeup - - - - XHCI' | sudo tee /etc/tmpfiles.d/disable-usb-wake.conf

	########### GAMEMODE ENV ############
echo -e 'GAMEMODERUNEXEC="env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only"' | tee -a /etc/environment
	
	#####  ADD STEAM INPUT CONTROLLERS #####
	wget https://raw.githubusercontent.com/ValveSoftware/steam-devices/master/60-steam-input.rules -O /etc/udev/rules.d/60-steam-input.rules

}

kde()
{
	# Setup common packages and settings
	base_common

	echo "Setup KDE";
	
	########### KDE ############
	pacman -Syu kdegraphics-thumbnailers ffmpegthumbs kdialog flatpak-kcm xdg-desktop-portal-kde spectacle xdg-desktop-portal-gtk partitionmanager --noconfirm || exit 1
	pacman -Syu dolphin-plugins --noconfirm || exit 1


	########### APDATIFIER  (KDE) ############
	pacman -Syu pacman-contrib curl jq tar unzip xmlstarlet fzf --noconfirm || exit 1
	
	########### SET EXPLICITY INSTALLED PACKAGES (Prevent from autoremove) ############
	pacman -D --asexplicit kde-gtk-config sddm-kcm plasma-systemmonitor plasma-desktop oxygen-sounds kdeplasma-addons kgamma kwallet-pam kwrited plasma-browser-integration plasma-disks print-manager --noconfirm || exit 1

	########### CONSISTENT KDE FILE DIALOG (KDE) ############
echo -e "GTK_USE_PORTAL=1\nXDG_CURRENT_DESKTOP=KDE" | tee -a /etc/environment

	########### SPELL CHECK ############
	pacman -Syu sonnet hunspell hunspell-en_us hunspell-it --noconfirm || exit 1
	
	########### REMOVE UNUSED PACKAGES ############
	pacman -R plasma-meta --noconfirm || exit 1
	pacman -Rcns drkonqi htop vim discover krdp oxygen plasma-firewall plasma-thunderbolt plasma-vault plasma-welcome plasma-workspace-wallpapers --noconfirm || exit 1
	pacman -Syu plasma-nm --noconfirm || exit 1

		########### MOUNT DISK WITHOUT PASS ############
echo -e 'polkit.addRule(function(action, subject) {
    if (subject.isInGroup("wheel")) {
        if (action.id.startsWith("org.freedesktop.udisks2.")) {
            return polkit.Result.YES;
        }
    }
});' | sudo tee /etc/polkit-1/rules.d/50-udisks.rules

}

gnome()
{
	# Setup common packages and settings
	base_common

	echo "Setup GNOME";
	
	########### GNOME ############
	pacman -Syu webp-pixbuf-loader gst-plugin-pipewire gst-plugins-good ffmpegthumbnailer gnome-themes-extra adw-gtk-theme --noconfirm || exit 1
	
	# FORCE ENABLE WAYLAND ####
	ln -s /dev/null /etc/udev/rules.d/61-gdm.rules

	# USE ADW-GTK3 DARK THEME ####
 	gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	
	########### REMOVE UNUSED PACKAGES ############
	pacman -Rcns gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-connections gnome-contacts gnome-font-viewer gnome-logs gnome-maps --noconfirm || exit 1
	pacman -Rcns gnome-software gnome-shell-extensions gnome-remote-desktop gnome-tour gnome-weather totem gnome-music vim htop yelp baobab --noconfirm || exit 1
}

base_flatpak()
{
	### BASE
	flatpak install --assumeyes --noninteractive org.mozilla.firefox
	
 	### GAMING
 	flatpak install --assumeyes --noninteractive org.ryujinx.Ryujinx com.valvesoftware.Steam
  
  	### GRAPHICS
 	flatpak install --assumeyes --noninteractive org.blender.Blender org.gimp.GIMP org.inkscape.Inkscape org.kde.krita
  
  	### SOUND & VIDEO
 	flatpak install --assumeyes --noninteractive com.spotify.Client
  
  	### COMMUNICATION
 	flatpak install --assumeyes --noninteractive org.telegram.desktop io.github.spacingbat3.webcord 
  
  	### OTHERS
 	flatpak install --assumeyes --noninteractive org.localsend.localsend_app org.bleachbit.BleachBit com.freerdp.FreeRDP
}

kde_flatpak()
{
	### BASE
	base_flatpak
	
	### MISC
	flatpak install --assumeyes --noninteractive org.kde.skanlite org.qbittorrent.qBittorrent org.kde.okular io.github.f3d_app.f3d org.gitfourchette.gitfourchette org.kde.gwenview org.winehq.Wine org.kde.klevernotes io.gpt4all.gpt4all com.borgbase.Vorta
	
	### GAMING
	flatpak install --assumeyes --noninteractive com.heroicgameslauncher.hgl

  	### SOUND & VIDEO
 	#flatpak install --assumeyes --noninteractive org.kde.kdenlive com.obsproject.Studio

	### UPDATE
	flatpak update --assumeyes --noninteractive
}

gnome_flatpak()
{
	### BASE
	base_flatpak
	
	### GNOME
	flatpak install --assumeyes --noninteractive org.gnome.Calendar org.gnome.Loupe org.gnome.Papers

	### INTERNET
	flatpak install --assumeyes --noninteractive de.haeckerfelix.Fragments

	### SYSTEM
	flatpak install --assumeyes --noninteractive page.codeberg.libre_menu_editor.LibreMenuEditor org.gnome.World.PikaBackup io.missioncenter.MissionCenter com.github.tchx84.Flatseal ca.desrt.dconf-editor com.mattjakeman.ExtensionManager

	### UTILITY
	flatpak install --assumeyes --noninteractive com.github.flxzt.rnote

	### DEV
	flatpak install --assumeyes --noninteractive com.jeffser.Alpaca

	### GRAPHICS
	flatpak install --assumeyes --noninteractive io.github.celluloid_player.Celluloid io.github.nokse22.Exhibit

	### GAMES & WINDOWS
	flatpak install --assumeyes --noninteractive com.vysp3r.ProtonPlus org.gnome.Boxes com.usebottles.bottles
 
 	### THEMES
 	flatpak install --assumeyes --noninteractive org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
 
	### UPDATE
	flatpak update --assumeyes --noninteractive
}

base_post()
{

	########### SERVICES ############
	systemctl enable bluetooth.service paccache.service switcheroo-control.service power-profiles-daemon.service paccache.timer upower.service

	########### INSTALL YAY ###########
	git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

 	########### BOOT FLAGS ###########
	# sudo nano /boot/loader/entries/arch.conf
	# quiet loglevel=2 systemd.show_status=no console=ttyS0,115200 console=tty0 vt.global_cursor_default=0

	########### XPADNEO ###########
	# git clone https://github.com/atar-axis/xpadneo.git && cd xpadneo && sudo ./install.sh
	
 	### USE .LOCAL/BIN FOLDER ###
 	echo -e 'export PATH="$PATH:$HOME/.local/bin/"' | tee -a ~/.bash_profile
}

kde_post()
{
	### BASE
	base_post

  	########### APDATIFIER ###########
  	# Download .plasmoid from https://github.com/exequtic/apdatifier/releases
  	# Install with kpackagetool6 -i apdatifier_X.plasmoid
  	# Logout and systemctl --user restart plasma-plasmashell.service
	#curl -fsSL https://raw.githubusercontent.com/exequtic/apdatifier/main/package/contents/tools/tools.sh | sh -s install

	########### BREEZE PAPIRUS ICON THEME ###########
	cd /usr/share/icons && sudo curl -sL https://raw.githubusercontent.com/Marckniack/Linux-Post-Install-Tweaks/main/KDE/PapirusBreeze.tar.gz | tar zx
}

gnome_post()
{
	### BASE
	base_post
}

spotify_adblock()
{

	### INSTALL
 	flatpak install --assumeyes --noninteractive com.spotify.Client

 	### MASK
 	flatpak mask com.spotify.Client

  	########### SpotX-Bash (Spotify Adblock) ###########
	bash <(curl -sSL https://spotx-official.github.io/run.sh) -hflc

}


# Check if the function exists (bash specific)
if declare -f "$1" > /dev/null
then
  # call arguments verbatim
  "$@"
else
  # Show a helpful error
  echo "'$1' is not a known function name." >&2
  exit 1
fi

