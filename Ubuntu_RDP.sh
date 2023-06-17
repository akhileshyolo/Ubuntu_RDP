#!/bin/bash
################################################################################
#                                                                              #
# Copyright (c) 2023 Díwash(Diwash0007)                                        #
#                                                                              #
# Licensed under the Apache License, Version 2.0 (the "License");              #
# you may not use this file except in compliance with the License.             #
# You may obtain a copy of the License at                                      #
#                                                                              #
#     http://www.apache.org/licenses/LICENSE-2.0                               #
#                                                                              #
# Unless required by applicable law or agreed to in writing, software          #
# distributed under the License is distributed on an "AS IS" BASIS,            #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.     #
# See the License for the specific language governing permissions and          #
# limitations under the License.                                               #
#                                                                              #
################################################################################

# *******************************************************************************
# - Script to install Chrome Remote Desktop and a desktop environment.
# - Installs Chrome Remote Desktop package and a desktop environment i.e. xfce
# - Sends Remote Desktop at http://remotedesktop.google.com/ to access `xfce` instance.
# - Author: Díwash (Diwash0007)
# - Version: generic:0.1
# - Date: 13 April 2023
#
#       Changes for V0.99 (20230614) - make it clear that `xfce` desktop environment is not ready.
#       Changes for V1 ((20230615) - `xfce` desktop environment is now ready.
#
# ********************************************************************************

# ******************************* Create Host and, User **************************

# Enter Username and Password
hostname="${hostname}";
username="${username}";
password="${password}";

create_user() {
  echo "----------------------------------------------";
  echo "-- Creating Host, User and Setting them up ...";
  echo "----------------------------------------------";
  sudo hostname $hostname; # Creation of host
  sudo useradd -m $username; # Creation of user
  sudo adduser $username sudo; # Add user to sudo group
  echo "$username:$password" | sudo chpasswd; # Set password of user to 'root'
  sudo sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd; # Change default shell from sh to bash
  echo "-- Host, User created and configured having hostname "$hostname", username "$username" and password "$password".";
}

# *********************************************************************************

# ********************************** RDP ******************************************

# Enter a Pin (more or equal to 6 digits)
Pin="${Pin}";

# Visit http://remotedesktop.google.com/headless and copy the command after Authentication
CRP="${CRP}";

install_CRD() {
  echo "---------------------------------------";
  echo "-- Installing Chrome Remote Desktop ...";
  echo "---------------------------------------";
  curl -L -o chrome-remote-desktop_current_amd64.deb \
      https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb;
  sudo DEBIAN_FRONTEND=noninteractive \
      apt-get install --assume-yes ./chrome-remote-desktop_current_amd64.deb;
}

install_Desktop_Environment() {
  echo "-------------------------------------";
  echo "-- Installing Desktop Environment ...";
  echo "-------------------------------------";
  sudo DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes xfce4 desktop-base dbus-x11 xscreensaver;
  sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session';
  sudo apt-get install --assume-yes xfce4-terminal;
  sudo apt-get remove --assume-yes gnome-terminal;
  if ! dpkg -s lightdm &> /dev/null; then
      echo "-- Installing LightDM ...";
      sudo apt-get install lightdm;
  else
      echo "-- LightDM is already installed."
  fi
  sudo systemctl disable lightdm.service;
}

install_Google_Chorme() {
  echo "-------------------------------";
  echo "-- Installing Google Chrome ...";
  echo "-------------------------------";
  curl -L -o google-chrome-stable_current_amd64.deb \
      https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb;
  sudo apt-get install --assume-yes ./google-chrome-stable_current_amd64.deb;
}

finish() {
  echo "-----------------";
  echo "-- Finalizing ...";
  echo "-----------------";
  if ! getent group chrome-remote-desktop >/dev/null; then
      echo "-- Creating group called as 'chrome-remote-desktop'.";
      sudo groupadd chrome-remote-desktop;
      echo "-- Group named as 'chrome-remote-desktop' created.";
  else
      echo "-- Group called as 'chrome-remote-desktop' already exists.";
  fi
  sudo adduser $username chrome-remote-desktop;
  command="$CRP --pin=$Pin";
  sudo -u $(whoami) bash -c "$command";
  sudo systemctl restart chrome-remote-desktop@$(whoami);
  echo "--------------------------";
  echo "-- Finished Succesfully --";
  echo "--------------------------";
}

# ****************************************************************************************

# ***************************************** If error ? ***********************************

# print message and quit
abort() {
  echo "$@";
  exit 1;
}

check() {
  if [ "$CRP" = "" ]; then
    abort "-- Please enter authcode from the given link.";
  fi
  
  if [ "${#Pin}" -lt "6" ]; then
    abort "-- Enter a pin more or equal to 6 digits.";
  fi

  if [ "$hostname" = "" ]; then
    abort "-- 'hostname' variable not found, Create a host first.";
  fi

  if [ "$username" = "" ]; then
    abort "-- 'username' variable not found, Create a user first.";
  fi
}

# ****************************************************************************************

# ********************************** do all the work! ************************************

CRD() {
    local SCRIPT_VERSION="20230614";
    echo "--------------------";
    echo "$0, v$SCRIPT_VERSION";
    echo "--------------------";
    local START=$(date);
    check "$@";
    create_user;
    echo "-----------------------------------------";
    echo "-- It takes 4-5 minutes for installation.";
    echo "-----------------------------------------";
    sudo apt-get update;
    install_CRD;
    install_Desktop_Environment;
    install_Google_Chorme;
    finish;
    local STOP=$(date);
    echo "-- Start time = $START --";
    echo "-- Stop time = $STOP --";
    echo "----------------------------------------------------------------------------------";
    echo "-- RDP created and succesfully moved to 'https://remotedesktop.google.com/access'.";
    echo "----------------------------------------------------------------------------------";
    exit 0;
}

# --- main() ---
CRD "$@";
# --- end main() ---
