#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

# Exit on any failure, treat unset substitution variables as errors
set -eu

# Configure MATE
sudo dkms autoinstall

# Configure the MATE theme and panel layout (aka desktop layout)
# https://lauri.xn--vsandi-pxa.com/2015/03/dconf.html
sudo mkdir -p /etc/dconf/profile
sudo cp -f /var/tmp/config/mate/user /etc/dconf/profile

sudo mkdir -p /etc/dconf/db/site.d
sudo cp -f /var/tmp/config/mate/panel /etc/dconf/db/site.d
sudo cp -f /var/tmp/config/mate/theme /etc/dconf/db/site.d
sudo rm -f /etc/dconf/db/site
sudo dconf update

# Configure the MATE default menus for all users
# https://developer.gnome.org/menu-spec/
sudo cp -f /var/tmp/config/mate/mate-applications.menu /etc/xdg/menus
sudo mkdir -p /usr/share/applications
# See this: https://help.ubuntu.com/community/UnityLaunchersAndDesktopFiles
sudo cp -f /var/tmp/config/desktop/*.desktop /usr/share/applications
sudo cp -f /var/tmp/config/mate/mate-matlab.directory /usr/share/mate/desktop-directories
sudo mkdir -p /etc/skel/Desktop

# Configure MATLAB icon on desktop
sudo cp -f /var/tmp/config/desktop/matlab.desktop /etc/skel/Desktop
sudo chmod a+x /etc/skel/Desktop/matlab.desktop
sudo sed -Ei "s/Name=MATLAB/Name=MATLAB $RELEASE/" /etc/skel/Desktop/matlab.desktop
sudo mkdir /home/ubuntu/Desktop
sudo cp -f /etc/skel/Desktop/matlab.desktop /home/ubuntu/Desktop/
dbus-launch gio set /home/ubuntu/Desktop/matlab.desktop metadata::trusted true

# Fix ubuntu user permissions
sudo chown -R ubuntu:ubuntu /home/ubuntu

# Configure the MATLAB icon
sudo mkdir -p /usr/share/matlab
sudo cp -f /var/tmp/config/matlab/icons/matlab32.png /usr/share/matlab
sudo cp -f /var/tmp/config/matlab/icons/matlab64.png /usr/share/matlab
sudo ln -sf /usr/share/matlab/matlab32.png /usr/share/icons/hicolor/32x32/apps/matlab.png
sudo ln -sf /usr/share/matlab/matlab64.png /usr/share/icons/hicolor/64x64/apps/matlab.png
sudo ln -sf /usr/share/matlab/matlab64.png /usr/share/icons/hicolor/128x128/apps/matlab.png

# Refresh the icon cache
sudo update-icon-caches /usr/share/icons/*
sudo dconf update
sudo mkdir -p /home/ubuntu/.config/
sudo cp /var/tmp/config/mate/user-dirs.dirs /home/ubuntu/.config/user-dirs.dirs
