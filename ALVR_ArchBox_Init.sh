#!/bin/bash

### Create Box
# distrobox create --pull --image docker.io/archlinux/archlinux:latest --name arch --home /home/marco/.local/share/containers/boxes/arch/ --nvidia --pre-init-hooks "pacman -Syy reflector --noconfirm && reflector --country 'Canada,United States,France,Germany,Australia' --latest 5 --sort rate --save /etc/pacman.d/mirrorlist"

# Renaming xdg-open from container because it will run host applications (like steam) instead of internal ones
sudo mv /usr/local/bin/xdg-open /usr/local/bin/xdg-open2

# Setting up arch
echo "[multilib]" | sudo tee -a /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
sudo pacman-key --init || exit 1
echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf
echo "LC_ALL=en_US.UTF-8" | sudo tee /etc/locale.conf

sudo pacman -q -Syu glibc lib32-glibc xdg-utils at-spi2-core lib32-at-spi2-core tar wget --noconfirm || exit 1
# sudo pacman -q qt5-tools qt5-multimedia  --noconfirm || exit 1
sudo pacman -q -Syu git vim base-devel noto-fonts xdg-user-dirs fuse libx264 sdl2 libva-utils xorg-server nano ffmpeg --noconfirm || exit 1
sudo pacman -q -Syu nvidia-prime --noconfirm --assume-installed nvidia-utils || exit 1
sudo pacman -q -Syu libva-mesa-driver vulkan-intel lib32-vulkan-intel intel-media-driver lib32-libva-intel-driver libva-intel-driver --noconfirm || exit 1
sudo pacman -q -Syu lib32-pipewire pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber --noconfirm || exit 1
sudo pacman -q -Syu steam --noconfirm --assume-installed vulkan-driver --assume-installed lib32-vulkan-driver || exit 1

git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd || exit 1

mkdir ~/.config || exit 1

xdg-mime default steam.desktop x-scheme-handler/steam
steam steam://install/250820 &>/dev/null &
while [ ! -f "$HOME/.steam/steam/steamapps/common/SteamVR/bin/vrwebhelper/linux64/vrwebhelper.sh" ]; do
   sleep 5
done
sleep 3

distrobox-host-exec pkexec setcap CAP_SYS_NICE+ep "$HOME/.steam/steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher" || exit 1

# patching steamvr (without it, steamvr might lag to hell)
sh "$HOME//patch_bindings_spam.sh" || exit 1

# C# Development
sudo pacman -q -Syu dotnet-sdk dotnet-host dotnet-runtime --noconfirm || exit 1
yay -q -Sy jetbrains-toolbox --noconfirm || exit 1
