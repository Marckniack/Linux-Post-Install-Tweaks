#!/bin/bash

### ALL
flatpak install --assumeyes --noninteractive io.github.spacingbat3.webcord org.telegram.desktop org.gimp.GIMP org.kde.krita org.blender.Blender org.inkscape.Inkscape com.spotify.Client org.mozilla.firefox

### KDE
flatpak install --assumeyes --noninteractive org.qbittorrent.qBittorrent org.kde.okular org.kde.gwenview io.github.f3d_app.f3d

### GAMING
flatpak install --assumeyes --noninteractive io.github.lime3ds.Lime3DS com.valvesoftware.Steam com.heroicgameslauncher.hgl org.ryujinx.Ryujinx

### UPDATE
flatpak update --assumeyes --noninteractive
