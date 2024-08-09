#!/bin/bash

### ALL
flatpak install --assumeyes --noninteractive io.github.spacingbat3.webcord org.telegram.desktop org.gimp.GIMP org.kde.krita org.blender.Blender org.inkscape.Inkscape com.spotify.Client org.mozilla.firefox

### GAMING
flatpak install --assumeyes --noninteractive io.github.lime3ds.Lime3DS com.valvesoftware.Steam com.heroicgameslauncher.hgl org.ryujinx.Ryujinx com.vysp3r.ProtonPlus

### GNOME
flatpak install --assumeyes --noninteractive ca.desrt.dconf-editor page.codeberg.libre_menu_editor.LibreMenuEditor com.github.tchx84.Flatseal com.mattjakeman.ExtensionManager io.missioncenter.MissionCenter 
flatpak install --assumeyes --noninteractive org.gnome.TextEditor io.github.nokse22.Exhibit com.usebottles.bottles io.github.amit9838.mousam org.gnome.Papers org.gnome.World.PikaBackup org.gnome.Calendar 
flatpak install --assumeyes --noninteractive io.github.celluloid_player.Celluloid com.transmissionbt.Transmission org.gnome.Loupe

### UPDATE
flatpak update --assumeyes --noninteractive
